# section_bm25plus

## Configuration

| field | value |
|---|---|
| mode | section |
| model | bm25plus |
| chunk_size | n/a |

## Full-corpus retrieval effectiveness

| metric | value |
|---|---|
| MAP | 0.1554 |
| MRR | 0.9750 |
| P@10 | 0.7583 |
| nDCG@10 | 0.5185 |
| Recall@10 | 0.1695 |

Raw `trec_eval` output:
- `experiments/results/eval/raw/section_bm25plus.txt`

## Query performance across corpus sizes

| corpus | indexed_docs | build_ms | mean_ms | median_ms | p95_ms | qps | wall_ms |
|---|---:|---:|---:|---:|---:|---:|---:|
| subset_2500 | 18749 | 258.1306 | 0.4628 | 0.4897 | 0.5720 | 2160.84 | 827.5881 |
| subset_5000 | 37074 | 507.1745 | 1.0466 | 1.0986 | 1.3438 | 955.46 | 1785.0874 |
| subset_7500 | 56580 | 731.1852 | 1.8983 | 1.8637 | 3.0683 | 526.79 | 3040.9424 |
| subset_10000 | 75307 | 993.4328 | 3.4575 | 3.3529 | 5.4392 | 289.23 | 5193.6750 |
| full | 83793 | 1092.0590 | 3.1833 | 3.0826 | 5.3055 | 314.14 | 4958.9870 |

Raw benchmark outputs:
- `experiments/results/benchmarks/raw/section_bm25plus_subset_2500.txt`
- `experiments/results/benchmarks/raw/section_bm25plus_subset_5000.txt`
- `experiments/results/benchmarks/raw/section_bm25plus_subset_7500.txt`
- `experiments/results/benchmarks/raw/section_bm25plus_subset_10000.txt`
- `experiments/results/benchmarks/raw/section_bm25plus_full.txt`

