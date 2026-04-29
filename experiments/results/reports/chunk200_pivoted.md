# chunk200_pivoted

## Configuration

| field | value |
|---|---|
| mode | chunk |
| model | pivoted |
| chunk_size | 200 |

## Full-corpus retrieval effectiveness

| metric | value |
|---|---|
| MAP | 0.1585 |
| MRR | 0.9435 |
| P@10 | 0.8217 |
| nDCG@10 | 0.7524 |
| Recall@10 | 0.1780 |

Raw `trec_eval` output:
- `experiments/results/eval/raw/chunk200_pivoted.txt`

## Query performance across corpus sizes

| corpus | indexed_docs | build_ms | mean_ms | median_ms | p95_ms | qps | wall_ms |
|---|---:|---:|---:|---:|---:|---:|---:|
| subset_2500 | 12234 | 329.9581 | 0.6611 | 0.7131 | 0.7537 | 1512.67 | 1134.8549 |
| subset_5000 | 23997 | 632.4677 | 1.4899 | 1.5718 | 1.8929 | 671.19 | 2441.1169 |
| subset_7500 | 35688 | 937.9068 | 2.4227 | 2.5251 | 3.3659 | 412.75 | 3871.4458 |
| subset_10000 | 47240 | 1242.3442 | 3.6726 | 3.7469 | 5.7323 | 272.28 | 5680.6157 |
| full | 52709 | 1372.3808 | 4.2923 | 4.3712 | 7.0373 | 232.98 | 6557.4099 |

Raw benchmark outputs:
- `experiments/results/benchmarks/raw/chunk200_pivoted_subset_2500.txt`
- `experiments/results/benchmarks/raw/chunk200_pivoted_subset_5000.txt`
- `experiments/results/benchmarks/raw/chunk200_pivoted_subset_7500.txt`
- `experiments/results/benchmarks/raw/chunk200_pivoted_subset_10000.txt`
- `experiments/results/benchmarks/raw/chunk200_pivoted_full.txt`

