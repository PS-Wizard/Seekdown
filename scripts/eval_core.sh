#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"

DATASET=./dataset
QUERIES=./tests/queries/queries.csv
QRELS=./target/qrels_core.txt
TREC=./tools/trec_eval-bin
RUNS=./target/runs_core
RUNS_SHORT=./target/runs_core_short
EVAL=./target/eval_core
TOP_K=5

mkdir -p "$RUNS" "$RUNS_SHORT" "$EVAL"

if [[ ! -x "$TREC" ]]; then
  echo "missing trec_eval binary at $TREC" >&2
  exit 1
fi

for mode in section chunk; do
  for model in boolean tfidf bm25 bm25plus pivoted; do
    run_name="${mode}_${model}"
    cargo run -- run "$DATASET" "$QUERIES" \
      --out "$RUNS/${run_name}.run" \
      --name "$run_name" \
      --mode "$mode" \
      --model "$model" \
      --top-k "$TOP_K"
  done
done

python - <<'PY'
from pathlib import Path

qrels = Path('target/qrels_core.txt')
runs_dir = Path('target/runs_core')
out_runs = Path('target/runs_core_short')
out_eval = Path('target/eval_core')
out_runs.mkdir(exist_ok=True)
out_eval.mkdir(exist_ok=True)

all_docids = []
seen = set()
for line in qrels.read_text().splitlines():
    parts = line.split()
    if len(parts) >= 4:
        doc_id = parts[2]
        if doc_id not in seen:
            seen.add(doc_id)
            all_docids.append(doc_id)
for run in runs_dir.glob('*.run'):
    for line in run.read_text().splitlines():
        parts = line.split()
        if len(parts) >= 6:
            doc_id = parts[2]
            if doc_id not in seen:
                seen.add(doc_id)
                all_docids.append(doc_id)

mapping = {doc_id: f'D{idx:06d}' for idx, doc_id in enumerate(all_docids, 1)}

with open(out_eval / 'docid_map.csv', 'w') as f:
    f.write('short_id,doc_id\n')
    for doc_id in all_docids:
        f.write(f"{mapping[doc_id]},{doc_id}\n")

with open(out_eval / 'qrels_core_short.txt', 'w') as f:
    for line in qrels.read_text().splitlines():
        parts = line.split()
        if len(parts) >= 4:
            parts[2] = mapping[parts[2]]
            f.write(' '.join(parts) + '\n')

for run in runs_dir.glob('*.run'):
    out = out_runs / run.name
    with open(out, 'w') as f:
        for line in run.read_text().splitlines():
            parts = line.split()
            if len(parts) >= 6:
                parts[2] = mapping[parts[2]]
                f.write(' '.join(parts) + '\n')
PY

for run in "$RUNS_SHORT"/*.run; do
  base=$(basename "$run" .run)
  "$TREC" -m map -m recip_rank -m P.5 -m ndcg_cut.5 "$EVAL/qrels_core_short.txt" "$run" > "$EVAL/${base}.txt"
done

python - <<'PY'
from pathlib import Path
rows=[]
for p in sorted(Path('target/eval_core').glob('*.txt')):
    if p.name == 'qrels_core_short.txt':
        continue
    vals={}
    for line in p.read_text().splitlines():
        parts=line.split()
        if len(parts)==3 and parts[1]=='all':
            vals[parts[0]]=parts[2]
    rows.append((p.stem, vals.get('map',''), vals.get('recip_rank',''), vals.get('P_5',''), vals.get('ndcg_cut_5','')))
with open('target/eval_core/summary.csv','w') as f:
    f.write('run,map,mrr,p5,ndcg5\n')
    for r in rows:
        f.write(','.join(r)+'\n')
for r in rows:
    print('\t'.join(r))
PY
