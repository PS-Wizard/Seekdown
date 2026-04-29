#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"

./scripts/build_benchmark_corpora.sh
cargo build --release >/dev/null

python - <<'PY'
import csv
import re
import subprocess
import time
from pathlib import Path

BINARY = Path('target/release/seekdown')
QUERIES = Path('tests/queries/queries.csv')
SYSTEMS = Path('experiments/systems/full_corpus_systems.csv')
RAW_DIR = Path('experiments/results/benchmarks/raw')
OUT = Path('experiments/results/benchmarks/benchmark_matrix.csv')
REPEAT = 20
TOP_K = 10

RAW_DIR.mkdir(parents=True, exist_ok=True)
OUT.parent.mkdir(parents=True, exist_ok=True)

corpora = [
    ('subset_2500', Path('experiments/corpora/subset_2500')),
    ('subset_5000', Path('experiments/corpora/subset_5000')),
    ('subset_7500', Path('experiments/corpora/subset_7500')),
    ('subset_10000', Path('experiments/corpora/subset_10000')),
    ('full', Path('dataset')),
]

line1 = re.compile(r'documents=(\d+) queries=(\d+) repeat=(\d+) total=(\d+) build=([0-9.]+)ms')
line2 = re.compile(r'mean=([0-9.]+)ms median=([0-9.]+)ms p95=([0-9.]+)ms qps=([0-9.]+)')
rows = []

with SYSTEMS.open(newline='') as f:
    systems = list(csv.DictReader(f))

for system in systems:
    system_id = system['system_id']
    mode = system['mode']
    model = system['model']
    chunk_size = system['chunk_size']

    for corpus_id, dataset_path in corpora:
        cmd = [
            str(BINARY), 'bench', str(dataset_path), str(QUERIES),
            '--mode', mode,
            '--model', model,
            '--top-k', str(TOP_K),
            '--repeat', str(REPEAT),
        ]
        if mode == 'chunk':
            cmd += ['--chunk-size', chunk_size]

        start = time.perf_counter()
        result = subprocess.run(cmd, check=True, text=True, capture_output=True)
        wall_ms = (time.perf_counter() - start) * 1000.0

        raw_path = RAW_DIR / f'{system_id}_{corpus_id}.txt'
        raw_path.write_text(result.stdout)
        lines = [line.strip() for line in result.stdout.splitlines() if line.strip()]
        if len(lines) < 2:
            raise SystemExit(f'unexpected benchmark output for {system_id} {corpus_id}: {result.stdout}')

        match1 = line1.fullmatch(lines[0])
        match2 = line2.fullmatch(lines[1])
        if not match1 or not match2:
            raise SystemExit(f'unexpected benchmark output for {system_id} {corpus_id}: {result.stdout}')

        rows.append({
            'system_id': system_id,
            'mode': mode,
            'model': model,
            'chunk_size': chunk_size,
            'corpus_id': corpus_id,
            'dataset_path': dataset_path.as_posix(),
            'documents': match1.group(1),
            'queries': match1.group(2),
            'repeat': match1.group(3),
            'total_runs': match1.group(4),
            'build_ms': match1.group(5),
            'mean_ms': match2.group(1),
            'median_ms': match2.group(2),
            'p95_ms': match2.group(3),
            'qps': match2.group(4),
            'wall_ms': f'{wall_ms:.4f}',
        })
        print(f'benchmarked {system_id} on {corpus_id}')

with OUT.open('w', newline='') as f:
    writer = csv.DictWriter(
        f,
        fieldnames=[
            'system_id', 'mode', 'model', 'chunk_size', 'corpus_id', 'dataset_path',
            'documents', 'queries', 'repeat', 'total_runs', 'build_ms',
            'mean_ms', 'median_ms', 'p95_ms', 'qps', 'wall_ms',
        ],
    )
    writer.writeheader()
    writer.writerows(rows)

print(f'wrote {len(rows)} benchmark rows to {OUT}')
PY
