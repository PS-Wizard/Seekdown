#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"

TREC=./tools/trec_eval-bin
QRELS=./experiments/qrels/full_corpus_qrels_trec.txt
RUNS=./experiments/results/runs/full_corpus_trec
SYSTEMS=./experiments/systems/full_corpus_systems.csv
RAW=./experiments/results/eval/raw
OUT=./experiments/results/eval/full_corpus_metrics.csv

mkdir -p "$RAW" ./experiments/results/eval

if [[ ! -x "$TREC" ]]; then
  echo "missing trec_eval binary at $TREC" >&2
  exit 1
fi

python - <<'PY'
import csv
import subprocess
from pathlib import Path

TREC = Path('tools/trec_eval-bin')
QRELS = Path('experiments/qrels/full_corpus_qrels_trec.txt')
RUNS = Path('experiments/results/runs/full_corpus_trec')
SYSTEMS = Path('experiments/systems/full_corpus_systems.csv')
RAW = Path('experiments/results/eval/raw')
OUT = Path('experiments/results/eval/full_corpus_metrics.csv')

metrics = ['map', 'recip_rank', 'P.10', 'ndcg_cut.10', 'recall.10']
rows = []

with SYSTEMS.open(newline='') as f:
    reader = csv.DictReader(f)
    systems = list(reader)

for system in systems:
    system_id = system['system_id']
    run_path = RUNS / f'{system_id}.run'
    raw_path = RAW / f'{system_id}.txt'
    cmd = [str(TREC), '-m', 'map', '-m', 'recip_rank', '-m', 'P.10', '-m', 'ndcg_cut.10', '-m', 'recall.10', str(QRELS), str(run_path)]
    result = subprocess.run(cmd, check=True, text=True, capture_output=True)
    raw_path.write_text(result.stdout)

    parsed = {}
    for line in result.stdout.splitlines():
        parts = line.split()
        if len(parts) == 3 and parts[1] == 'all':
            parsed[parts[0]] = parts[2]

    rows.append({
        'system_id': system_id,
        'mode': system['mode'],
        'model': system['model'],
        'chunk_size': system['chunk_size'],
        'map': parsed.get('map', ''),
        'mrr': parsed.get('recip_rank', ''),
        'p10': parsed.get('P_10', ''),
        'ndcg10': parsed.get('ndcg_cut_10', ''),
        'recall10': parsed.get('recall_10', ''),
    })

with OUT.open('w', newline='') as f:
    writer = csv.DictWriter(f, fieldnames=['system_id', 'mode', 'model', 'chunk_size', 'map', 'mrr', 'p10', 'ndcg10', 'recall10'])
    writer.writeheader()
    writer.writerows(rows)

print(f'wrote metrics for {len(rows)} systems to {OUT}')
PY
