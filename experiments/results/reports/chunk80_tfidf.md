# chunk80_tfidf

## Configuration

| field | value |
|---|---|
| mode | chunk |
| model | tfidf |
| chunk_size | 80 |

## Full-corpus retrieval effectiveness

| metric | value |
|---|---|
| MAP | 0.1564 |
| MRR | 0.9181 |
| P@10 | 0.8150 |
| nDCG@10 | 0.7208 |
| Recall@10 | 0.1728 |

Raw `trec_eval` output:
- `experiments/results/eval/raw/chunk80_tfidf.txt`

## Query performance across corpus sizes

| corpus | indexed_docs | build_ms | mean_ms | median_ms | p95_ms | qps | wall_ms |
|---|---:|---:|---:|---:|---:|---:|---:|
| subset_2500 | 28521 | 363.5769 | 1.8053 | 1.9226 | 2.4201 | 553.93 | 2546.8317 |
| subset_5000 | 55797 | 710.4909 | 4.7096 | 5.1579 | 6.0605 | 212.33 | 6390.2895 |
| subset_7500 | 82851 | 1031.2254 | 8.2643 | 9.1043 | 10.2539 | 121.00 | 10986.4682 |
| subset_10000 | 109624 | 1396.7410 | 12.6451 | 13.8934 | 15.7729 | 79.08 | 16622.8329 |
| full | 122359 | 1478.5344 | 13.6675 | 15.0389 | 16.8435 | 73.17 | 17934.7048 |

Raw benchmark outputs:
- `experiments/results/benchmarks/raw/chunk80_tfidf_subset_2500.txt`
- `experiments/results/benchmarks/raw/chunk80_tfidf_subset_5000.txt`
- `experiments/results/benchmarks/raw/chunk80_tfidf_subset_7500.txt`
- `experiments/results/benchmarks/raw/chunk80_tfidf_subset_10000.txt`
- `experiments/results/benchmarks/raw/chunk80_tfidf_full.txt`

