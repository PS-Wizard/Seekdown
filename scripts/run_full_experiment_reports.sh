#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"

./scripts/prepare_full_corpus_trec_inputs.sh
./scripts/run_full_corpus_trec_eval.sh
./scripts/run_scalability_benchmarks.sh
./scripts/render_system_reports.sh
