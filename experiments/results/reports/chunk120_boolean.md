# chunk120_boolean

## Configuration

| field | value |
|---|---|
| mode | chunk |
| model | boolean |
| chunk_size | 120 |

## Full-corpus retrieval effectiveness

| metric | value |
|---|---|
| MAP | 0.1372 |
| MRR | 0.8637 |
| P@10 | 0.7667 |
| nDCG@10 | 0.6656 |
| Recall@10 | 0.1633 |

Raw `trec_eval` output:
- `experiments/results/eval/raw/chunk120_boolean.txt`

## Query performance across corpus sizes

| corpus | indexed_docs | build_ms | mean_ms | median_ms | p95_ms | qps | wall_ms |
|---|---:|---:|---:|---:|---:|---:|---:|
| subset_2500 | 19469 | 371.6940 | 1.3207 | 1.3321 | 1.9874 | 757.15 | 1969.5840 |
| subset_5000 | 38105 | 624.7680 | 2.8696 | 2.9160 | 4.2513 | 348.48 | 4092.5738 |
| subset_7500 | 56579 | 1005.3096 | 5.2375 | 5.2478 | 8.2543 | 190.93 | 7325.2111 |
| subset_10000 | 74887 | 1284.5326 | 9.0376 | 9.0566 | 14.9553 | 110.65 | 12174.9489 |
| full | 83580 | 1452.0673 | 10.0201 | 9.7809 | 16.0809 | 99.80 | 13517.4217 |

Raw benchmark outputs:
- `experiments/results/benchmarks/raw/chunk120_boolean_subset_2500.txt`
- `experiments/results/benchmarks/raw/chunk120_boolean_subset_5000.txt`
- `experiments/results/benchmarks/raw/chunk120_boolean_subset_7500.txt`
- `experiments/results/benchmarks/raw/chunk120_boolean_subset_10000.txt`
- `experiments/results/benchmarks/raw/chunk120_boolean_full.txt`

