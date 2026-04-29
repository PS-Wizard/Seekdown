# chunk80_boolean

## Configuration

| field | value |
|---|---|
| mode | chunk |
| model | boolean |
| chunk_size | 80 |

## Full-corpus retrieval effectiveness

| metric | value |
|---|---|
| MAP | 0.1395 |
| MRR | 0.8647 |
| P@10 | 0.7533 |
| nDCG@10 | 0.6476 |
| Recall@10 | 0.1616 |

Raw `trec_eval` output:
- `experiments/results/eval/raw/chunk80_boolean.txt`

## Query performance across corpus sizes

| corpus | indexed_docs | build_ms | mean_ms | median_ms | p95_ms | qps | wall_ms |
|---|---:|---:|---:|---:|---:|---:|---:|
| subset_2500 | 28521 | 321.3597 | 1.6417 | 1.7367 | 2.1276 | 609.12 | 2306.6262 |
| subset_5000 | 55797 | 662.3916 | 4.8787 | 4.8704 | 7.9975 | 204.97 | 6547.2012 |
| subset_7500 | 82851 | 984.2466 | 9.3344 | 9.3590 | 16.2660 | 107.13 | 12225.9799 |
| subset_10000 | 109624 | 1407.0711 | 15.9469 | 15.7842 | 25.2304 | 62.71 | 20593.4575 |
| full | 122359 | 1512.8676 | 18.2305 | 18.3270 | 28.0627 | 54.85 | 23454.3016 |

Raw benchmark outputs:
- `experiments/results/benchmarks/raw/chunk80_boolean_subset_2500.txt`
- `experiments/results/benchmarks/raw/chunk80_boolean_subset_5000.txt`
- `experiments/results/benchmarks/raw/chunk80_boolean_subset_7500.txt`
- `experiments/results/benchmarks/raw/chunk80_boolean_subset_10000.txt`
- `experiments/results/benchmarks/raw/chunk80_boolean_full.txt`

