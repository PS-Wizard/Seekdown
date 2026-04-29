#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"

DATASET=./dataset
OUT_ROOT=./experiments/corpora
META_ROOT=./experiments/results/benchmarks/corpus_manifests
SIZES=(2500 5000 7500 10000)
SEED=seekdown-benchmark-v1

mkdir -p "$OUT_ROOT" "$META_ROOT"

python - <<'PY'
import csv
import hashlib
import os
import shutil
from collections import defaultdict
from pathlib import Path

DATASET = Path('dataset')
OUT_ROOT = Path('experiments/corpora')
META_ROOT = Path('experiments/results/benchmarks/corpus_manifests')
SIZES = [2500, 5000, 7500, 10000]
SEED = 'seekdown-benchmark-v1'

all_files = []
by_source = defaultdict(list)
for path in sorted(DATASET.rglob('*')):
    if not path.is_file():
        continue
    if path.suffix.lower() not in {'.md', '.markdown'}:
        continue
    rel = path.relative_to(DATASET).as_posix()
    source = rel.split('/', 1)[0]
    by_source[source].append(rel)
    all_files.append(rel)

total = len(all_files)
if total == 0:
    raise SystemExit('no markdown files found under dataset/')

for source, paths in by_source.items():
    paths.sort(key=lambda rel: hashlib.sha256(f'{SEED}:{rel}'.encode()).hexdigest())

summary_rows = []

def allocate(target_size: int):
    raw = []
    floor_total = 0
    for source, paths in sorted(by_source.items()):
        exact = len(paths) * target_size / total
        floor_value = int(exact)
        raw.append([source, floor_value, exact - floor_value, len(paths)])
        floor_total += floor_value

    remaining = target_size - floor_total
    raw.sort(key=lambda item: (-item[2], item[0]))
    index = 0
    while remaining > 0:
        source, floor_value, frac, available = raw[index]
        if floor_value < available:
            raw[index][1] += 1
            remaining -= 1
        index = (index + 1) % len(raw)

    quotas = {source: floor_value for source, floor_value, _, _ in raw}
    return quotas

for size in SIZES:
    subset_dir = OUT_ROOT / f'subset_{size}'
    if subset_dir.exists():
        shutil.rmtree(subset_dir)
    subset_dir.mkdir(parents=True, exist_ok=True)

    quotas = allocate(size)
    selected = []
    counts_path = META_ROOT / f'subset_{size}_counts.csv'
    files_path = META_ROOT / f'subset_{size}_files.txt'

    with counts_path.open('w', newline='') as counts_file:
        writer = csv.writer(counts_file)
        writer.writerow(['source', 'selected_files', 'available_files'])
        for source in sorted(by_source):
            chosen = by_source[source][:quotas[source]]
            writer.writerow([source, len(chosen), len(by_source[source])])
            selected.extend(chosen)

    selected.sort()
    with files_path.open('w') as files_file:
        for rel in selected:
            files_file.write(rel + '\n')
            src = DATASET / rel
            dst = subset_dir / rel
            dst.parent.mkdir(parents=True, exist_ok=True)
            try:
                os.link(src, dst)
            except OSError:
                shutil.copy2(src, dst)

    summary_rows.append((f'subset_{size}', size, len(selected)))

summary_path = META_ROOT / 'subset_summary.csv'
with summary_path.open('w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['corpus_id', 'target_files', 'actual_files'])
    for row in summary_rows:
        writer.writerow(row)
    writer.writerow(['full', total, total])

print(f'created subsets for sizes: {", ".join(str(size) for size in SIZES)}')
print(f'full corpus markdown files: {total}')
PY
