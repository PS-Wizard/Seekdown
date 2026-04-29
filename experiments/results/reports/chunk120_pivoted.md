# chunk120_pivoted

## Configuration

| field | value |
|---|---|
| mode | chunk |
| model | pivoted |
| chunk_size | 120 |

## Full-corpus retrieval effectiveness

| metric | value |
|---|---|
| MAP | 0.1591 |
| MRR | 0.9458 |
| P@10 | 0.8233 |
| nDCG@10 | 0.7442 |
| Recall@10 | 0.1746 |

Raw `trec_eval` output:
- `experiments/results/eval/raw/chunk120_pivoted.txt`

## Query performance across corpus sizes

| corpus | indexed_docs | build_ms | mean_ms | median_ms | p95_ms | qps | wall_ms |
|---|---:|---:|---:|---:|---:|---:|---:|
| subset_2500 | 19469 | 334.1570 | 1.0694 | 1.1447 | 1.2691 | 935.10 | 1629.2667 |
| subset_5000 | 38105 | 647.8300 | 2.4554 | 2.5629 | 3.2765 | 407.27 | 3614.8552 |
| subset_7500 | 56579 | 959.5063 | 4.3211 | 4.4268 | 6.9631 | 231.42 | 6174.5197 |
| subset_10000 | 74887 | 1266.4368 | 6.6232 | 6.7871 | 10.3514 | 150.98 | 9256.3013 |
| full | 83580 | 1394.7606 | 7.8769 | 8.1559 | 11.7789 | 126.95 | 10888.8192 |

Raw benchmark outputs:
- `experiments/results/benchmarks/raw/chunk120_pivoted_subset_2500.txt`
- `experiments/results/benchmarks/raw/chunk120_pivoted_subset_5000.txt`
- `experiments/results/benchmarks/raw/chunk120_pivoted_subset_7500.txt`
- `experiments/results/benchmarks/raw/chunk120_pivoted_subset_10000.txt`
- `experiments/results/benchmarks/raw/chunk120_pivoted_full.txt`

