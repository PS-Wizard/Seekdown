#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"

DATASET=./dataset
QUERIES=./tests/queries/queries.csv
TOP_K=10
MODELS=boolean,tfidf,bm25,bm25plus,pivoted
PARTS=./experiments/results/pools/parts
OUT=./experiments/annotated/full_corpus_pool_candidates.csv

mkdir -p "$PARTS" ./experiments/results/pools ./experiments/annotated ./experiments/qrels ./experiments/results/eval

cargo run --release -- pool "$DATASET" "$QUERIES" \
  --out "$PARTS/section.csv" \
  --modes section \
  --models "$MODELS" \
  --top-k "$TOP_K" \
  --chunk-size 120

for chunk_size in 80 120 200; do
  cargo run --release -- pool "$DATASET" "$QUERIES" \
    --out "$PARTS/chunk${chunk_size}.csv" \
    --modes chunk \
    --models "$MODELS" \
    --top-k "$TOP_K" \
    --chunk-size "$chunk_size"
done

python - <<'PY'
import csv
from collections import OrderedDict
from pathlib import Path

parts = [
    (Path('experiments/results/pools/parts/section.csv'), 'section'),
    (Path('experiments/results/pools/parts/chunk80.csv'), 'chunk80'),
    (Path('experiments/results/pools/parts/chunk120.csv'), 'chunk120'),
    (Path('experiments/results/pools/parts/chunk200.csv'), 'chunk200'),
]
out_path = Path('experiments/annotated/full_corpus_pool_candidates.csv')
rows = OrderedDict()

for path, source_prefix in parts:
    with path.open(newline='') as f:
        reader = csv.DictReader(f)
        for row in reader:
            key = (row['query_id'], row['doc_id'])
            source_items = [item for item in row['sources'].split('|') if item]
            if source_prefix.startswith('chunk'):
                source_items = [item.replace('chunk:', f'{source_prefix}:') for item in source_items]

            if key not in rows:
                rows[key] = {
                    'query_id': row['query_id'],
                    'query_text': row['query_text'],
                    'doc_id': row['doc_id'],
                    'path': row['path'],
                    'title': row['title'],
                    'score': row['score'],
                    'snippet': row['snippet'],
                    'sources': set(source_items),
                    'relevance': '',
                }
            else:
                if float(row['score']) > float(rows[key]['score']):
                    rows[key]['score'] = row['score']
                rows[key]['sources'].update(source_items)

with out_path.open('w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['query_id', 'query_text', 'doc_id', 'path', 'title', 'score', 'snippet', 'sources', 'relevance'])
    for row in rows.values():
        writer.writerow([
            row['query_id'],
            row['query_text'],
            row['doc_id'],
            row['path'],
            row['title'],
            row['score'],
            row['snippet'],
            '|'.join(sorted(row['sources'])),
            row['relevance'],
        ])

print(f'wrote {len(rows)} pooled rows to {out_path}')
PY
