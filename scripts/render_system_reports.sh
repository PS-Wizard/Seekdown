#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"

python - <<'PY'
import csv
from pathlib import Path

SYSTEMS = Path('experiments/systems/full_corpus_systems.csv')
EVAL = Path('experiments/results/eval/full_corpus_metrics.csv')
BENCH = Path('experiments/results/benchmarks/benchmark_matrix.csv')
REPORTS = Path('experiments/results/reports')
REPORTS.mkdir(parents=True, exist_ok=True)

with SYSTEMS.open(newline='') as f:
    systems = {row['system_id']: row for row in csv.DictReader(f)}
with EVAL.open(newline='') as f:
    eval_rows = {row['system_id']: row for row in csv.DictReader(f)}
with BENCH.open(newline='') as f:
    bench_rows = list(csv.DictReader(f))

order = {'subset_2500': 0, 'subset_5000': 1, 'subset_7500': 2, 'subset_10000': 3, 'full': 4}

for system_id, system in systems.items():
    eval_row = eval_rows[system_id]
    system_bench = [row for row in bench_rows if row['system_id'] == system_id]
    system_bench.sort(key=lambda row: order[row['corpus_id']])

    chunk_size = system['chunk_size'] or 'n/a'
    lines = []
    lines.append(f'# {system_id}')
    lines.append('')
    lines.append('## Configuration')
    lines.append('')
    lines.append('| field | value |')
    lines.append('|---|---|')
    lines.append(f"| mode | {system['mode']} |")
    lines.append(f"| model | {system['model']} |")
    lines.append(f"| chunk_size | {chunk_size} |")
    lines.append('')
    lines.append('## Full-corpus retrieval effectiveness')
    lines.append('')
    lines.append('| metric | value |')
    lines.append('|---|---|')
    lines.append(f"| MAP | {eval_row['map']} |")
    lines.append(f"| MRR | {eval_row['mrr']} |")
    lines.append(f"| P@10 | {eval_row['p10']} |")
    lines.append(f"| nDCG@10 | {eval_row['ndcg10']} |")
    lines.append(f"| Recall@10 | {eval_row['recall10']} |")
    lines.append('')
    lines.append('Raw `trec_eval` output:')
    lines.append(f"- `experiments/results/eval/raw/{system_id}.txt`")
    lines.append('')
    lines.append('## Query performance across corpus sizes')
    lines.append('')
    lines.append('| corpus | indexed_docs | build_ms | mean_ms | median_ms | p95_ms | qps | wall_ms |')
    lines.append('|---|---:|---:|---:|---:|---:|---:|---:|')
    for row in system_bench:
        lines.append(
            f"| {row['corpus_id']} | {row['documents']} | {row['build_ms']} | {row['mean_ms']} | {row['median_ms']} | {row['p95_ms']} | {row['qps']} | {row['wall_ms']} |"
        )
    lines.append('')
    lines.append('Raw benchmark outputs:')
    for row in system_bench:
        lines.append(f"- `experiments/results/benchmarks/raw/{system_id}_{row['corpus_id']}.txt`")
    lines.append('')

    (REPORTS / f'{system_id}.md').write_text('\n'.join(lines) + '\n')

index_lines = []
index_lines.append('# System Reports')
index_lines.append('')
index_lines.append('| system | mode | model | chunk_size | MAP | MRR | P@10 | nDCG@10 | report |')
index_lines.append('|---|---|---|---:|---:|---:|---:|---:|---|')
for system_id in sorted(systems):
    system = systems[system_id]
    eval_row = eval_rows[system_id]
    chunk_size = system['chunk_size'] or 'n/a'
    index_lines.append(
        f"| {system_id} | {system['mode']} | {system['model']} | {chunk_size} | {eval_row['map']} | {eval_row['mrr']} | {eval_row['p10']} | {eval_row['ndcg10']} | [{system_id}]({system_id}.md) |"
    )
(REPORTS / 'INDEX.md').write_text('\n'.join(index_lines) + '\n')

print(f'wrote {len(systems)} system reports to {REPORTS}')
PY
