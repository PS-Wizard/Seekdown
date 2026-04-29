# chunk200_boolean

## Configuration

| field | value |
|---|---|
| mode | chunk |
| model | boolean |
| chunk_size | 200 |

## Full-corpus retrieval effectiveness

| metric | value |
|---|---|
| MAP | 0.1274 |
| MRR | 0.8451 |
| P@10 | 0.7283 |
| nDCG@10 | 0.6488 |
| Recall@10 | 0.1475 |

Raw `trec_eval` output:
- `experiments/results/eval/raw/chunk200_boolean.txt`

## Query performance across corpus sizes

| corpus | indexed_docs | build_ms | mean_ms | median_ms | p95_ms | qps | wall_ms |
|---|---:|---:|---:|---:|---:|---:|---:|
| subset_2500 | 12234 | 323.3804 | 0.7834 | 0.8223 | 0.9490 | 1276.47 | 1276.4498 |
| subset_5000 | 23997 | 636.0035 | 1.7589 | 1.8053 | 2.3975 | 568.54 | 2767.2553 |
| subset_7500 | 35688 | 931.7027 | 2.8774 | 2.9952 | 4.0023 | 347.53 | 4411.1709 |
| subset_10000 | 47240 | 1235.9405 | 4.0915 | 4.1797 | 6.4325 | 244.41 | 6180.2987 |
| full | 52709 | 1377.8311 | 5.2292 | 5.2430 | 8.6676 | 191.24 | 7691.7872 |

Raw benchmark outputs:
- `experiments/results/benchmarks/raw/chunk200_boolean_subset_2500.txt`
- `experiments/results/benchmarks/raw/chunk200_boolean_subset_5000.txt`
- `experiments/results/benchmarks/raw/chunk200_boolean_subset_7500.txt`
- `experiments/results/benchmarks/raw/chunk200_boolean_subset_10000.txt`
- `experiments/results/benchmarks/raw/chunk200_boolean_full.txt`

