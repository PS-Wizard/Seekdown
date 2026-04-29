#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"

POOL=./experiments/annotated/full_corpus_pool_candidates_labeled.csv
QRELS_RAW=./experiments/qrels/full_corpus_qrels.txt
QRELS_TREC=./experiments/qrels/full_corpus_qrels_trec.txt
DOCID_MAP=./experiments/qrels/full_corpus_docid_map.csv
RUNS_RAW=./experiments/results/runs/full_corpus
RUNS_TREC=./experiments/results/runs/full_corpus_trec

mkdir -p "$RUNS_TREC" ./experiments/qrels

cargo run --release -- qrels "$POOL" --out "$QRELS_RAW"

python - <<'PY'
import csv
from pathlib import Path

qrels_raw = Path('experiments/qrels/full_corpus_qrels.txt')
docid_map_path = Path('experiments/qrels/full_corpus_docid_map.csv')
qrels_trec_path = Path('experiments/qrels/full_corpus_qrels_trec.txt')
runs_raw_dir = Path('experiments/results/runs/full_corpus')
runs_trec_dir = Path('experiments/results/runs/full_corpus_trec')
runs_trec_dir.mkdir(parents=True, exist_ok=True)

all_docids = []
seen = set()

def add_docid(doc_id: str):
    if doc_id not in seen:
        seen.add(doc_id)
        all_docids.append(doc_id)

def parse_qrels_line(line: str):
    parts = line.split()
    if len(parts) < 4:
        raise SystemExit(f'invalid raw qrels line: {line}')
    qid = parts[0]
    zero = parts[1]
    rel = parts[-1]
    doc_id = ' '.join(parts[2:-1])
    return qid, zero, doc_id, rel

def parse_run_line(line: str):
    parts = line.split()
    if len(parts) < 6:
        raise SystemExit(f'invalid raw run line: {line}')
    qid = parts[0]
    q0 = parts[1]
    run_name = parts[-1]
    score = parts[-2]
    rank = parts[-3]
    doc_id = ' '.join(parts[2:-3])
    return qid, q0, doc_id, rank, score, run_name

for line in qrels_raw.read_text().splitlines():
    if line.strip():
        _, _, doc_id, _ = parse_qrels_line(line)
        add_docid(doc_id)

for run_path in sorted(runs_raw_dir.glob('*.run')):
    for line in run_path.read_text().splitlines():
        if line.strip():
            _, _, doc_id, _, _, _ = parse_run_line(line)
            add_docid(doc_id)

mapping = {doc_id: f'D{idx:06d}' for idx, doc_id in enumerate(all_docids, 1)}

with docid_map_path.open('w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['short_id', 'doc_id'])
    for doc_id in all_docids:
        writer.writerow([mapping[doc_id], doc_id])

qrels_rows = {}
for line in qrels_raw.read_text().splitlines():
    if not line.strip():
        continue
    qid, zero, doc_id, rel = parse_qrels_line(line)
    key = (qid, doc_id)
    rel_value = int(rel)
    if key not in qrels_rows or rel_value > qrels_rows[key][2]:
        qrels_rows[key] = (qid, zero, rel_value)

with qrels_trec_path.open('w') as out:
    for qid, doc_id in sorted(qrels_rows, key=lambda item: (item[0], mapping[item[1]])):
        _, zero, rel_value = qrels_rows[(qid, doc_id)]
        out.write(f'{qid} {zero} {mapping[doc_id]} {rel_value}\n')

for run_path in sorted(runs_raw_dir.glob('*.run')):
    out_path = runs_trec_dir / run_path.name
    deduped_rows = []
    seen = set()
    for line in run_path.read_text().splitlines():
        if not line.strip():
            continue
        qid, q0, doc_id, rank, score, run_name = parse_run_line(line)
        key = (qid, doc_id)
        if key in seen:
            continue
        seen.add(key)
        deduped_rows.append((qid, q0, doc_id, score, run_name))

    per_query_rank = {}
    with out_path.open('w') as out:
        for qid, q0, doc_id, score, run_name in deduped_rows:
            rank = per_query_rank.get(qid, 0) + 1
            per_query_rank[qid] = rank
            out.write(f'{qid} {q0} {mapping[doc_id]} {rank} {score} {run_name}\n')

print(f'wrote {len(all_docids)} docid mappings to {docid_map_path}')
print(f'wrote TREC-safe qrels to {qrels_trec_path}')
print(f'wrote {len(list(runs_raw_dir.glob("*.run")))} TREC-safe runs to {runs_trec_dir}')
PY
