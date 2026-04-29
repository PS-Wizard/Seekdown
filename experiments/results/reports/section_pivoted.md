# section_pivoted

## Configuration

| field | value |
|---|---|
| mode | section |
| model | pivoted |
| chunk_size | n/a |

## Full-corpus retrieval effectiveness

| metric | value |
|---|---|
| MAP | 0.1476 |
| MRR | 0.9283 |
| P@10 | 0.7583 |
| nDCG@10 | 0.5177 |
| Recall@10 | 0.1629 |

Raw `trec_eval` output:
- `experiments/results/eval/raw/section_pivoted.txt`

## Query performance across corpus sizes

| corpus | indexed_docs | build_ms | mean_ms | median_ms | p95_ms | qps | wall_ms |
|---|---:|---:|---:|---:|---:|---:|---:|
| subset_2500 | 18749 | 270.1725 | 0.5265 | 0.5530 | 0.6863 | 1899.22 | 915.0806 |
| subset_5000 | 37074 | 521.9769 | 1.1453 | 1.2008 | 1.5206 | 873.16 | 1919.5044 |
| subset_7500 | 56580 | 704.2696 | 2.0167 | 2.0811 | 2.9562 | 495.86 | 3154.9247 |
| subset_10000 | 75307 | 935.7040 | 3.2858 | 3.3434 | 5.1144 | 304.34 | 4917.1269 |
| full | 83793 | 1058.0618 | 3.8907 | 3.8842 | 6.1978 | 257.02 | 5770.7529 |

Raw benchmark outputs:
- `experiments/results/benchmarks/raw/section_pivoted_subset_2500.txt`
- `experiments/results/benchmarks/raw/section_pivoted_subset_5000.txt`
- `experiments/results/benchmarks/raw/section_pivoted_subset_7500.txt`
- `experiments/results/benchmarks/raw/section_pivoted_subset_10000.txt`
- `experiments/results/benchmarks/raw/section_pivoted_full.txt`

