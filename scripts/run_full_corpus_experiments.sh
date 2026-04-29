#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"

DATASET=./dataset
QUERIES=./tests/queries/queries.csv
SYSTEMS=./experiments/systems/full_corpus_systems.csv
RUNS=./experiments/results/runs/full_corpus
TOP_K=10

mkdir -p "$RUNS" ./experiments/results/eval ./experiments/qrels ./experiments/annotated

while IFS=, read -r system_id mode model chunk_size; do
  if [[ "$system_id" == "system_id" ]]; then
    continue
  fi

  echo "running $system_id"

  args=(cargo run --release -- run "$DATASET" "$QUERIES" \
    --out "$RUNS/${system_id}.run" \
    --name "$system_id" \
    --mode "$mode" \
    --model "$model" \
    --top-k "$TOP_K")

  if [[ "$mode" == "chunk" ]]; then
    args+=(--chunk-size "$chunk_size")
  fi

  "${args[@]}"
done < "$SYSTEMS"

echo "wrote runs to $RUNS"
