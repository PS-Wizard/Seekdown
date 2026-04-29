# section_bm25

## Configuration

| field | value |
|---|---|
| mode | section |
| model | bm25 |
| chunk_size | n/a |

## Full-corpus retrieval effectiveness

| metric | value |
|---|---|
| MAP | 0.1593 |
| MRR | 0.9583 |
| P@10 | 0.7717 |
| nDCG@10 | 0.5405 |
| Recall@10 | 0.1725 |

Raw `trec_eval` output:
- `experiments/results/eval/raw/section_bm25.txt`

## Query performance across corpus sizes

| corpus | indexed_docs | build_ms | mean_ms | median_ms | p95_ms | qps | wall_ms |
|---|---:|---:|---:|---:|---:|---:|---:|
| subset_2500 | 18749 | 269.9704 | 0.4830 | 0.5000 | 0.6243 | 2070.42 | 867.9409 |
| subset_5000 | 37074 | 527.5195 | 1.0854 | 1.1191 | 1.4798 | 921.34 | 1853.3174 |
| subset_7500 | 56580 | 741.2167 | 1.9389 | 1.9097 | 3.1129 | 515.77 | 3100.8882 |
| subset_10000 | 75307 | 991.9415 | 3.0067 | 2.9509 | 4.8372 | 332.59 | 4641.5365 |
| full | 83793 | 1102.4446 | 3.9249 | 3.9573 | 6.0197 | 254.78 | 5861.4608 |

Raw benchmark outputs:
- `experiments/results/benchmarks/raw/section_bm25_subset_2500.txt`
- `experiments/results/benchmarks/raw/section_bm25_subset_5000.txt`
- `experiments/results/benchmarks/raw/section_bm25_subset_7500.txt`
- `experiments/results/benchmarks/raw/section_bm25_subset_10000.txt`
- `experiments/results/benchmarks/raw/section_bm25_full.txt`

