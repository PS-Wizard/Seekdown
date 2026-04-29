# chunk120_bm25plus

## Configuration

| field | value |
|---|---|
| mode | chunk |
| model | bm25plus |
| chunk_size | 120 |

## Full-corpus retrieval effectiveness

| metric | value |
|---|---|
| MAP | 0.1718 |
| MRR | 0.9500 |
| P@10 | 0.8350 |
| nDCG@10 | 0.7820 |
| Recall@10 | 0.1878 |

Raw `trec_eval` output:
- `experiments/results/eval/raw/chunk120_bm25plus.txt`

## Query performance across corpus sizes

| corpus | indexed_docs | build_ms | mean_ms | median_ms | p95_ms | qps | wall_ms |
|---|---:|---:|---:|---:|---:|---:|---:|
| subset_2500 | 19469 | 331.1299 | 0.9983 | 1.0679 | 1.1679 | 1001.68 | 1541.7905 |
| subset_5000 | 38105 | 649.1465 | 2.3711 | 2.4485 | 3.2835 | 421.75 | 3517.5334 |
| subset_7500 | 56579 | 953.5494 | 4.0803 | 4.1774 | 6.2152 | 245.08 | 5878.7028 |
| subset_10000 | 74887 | 1266.8415 | 6.8973 | 7.0189 | 10.9256 | 144.98 | 9583.2266 |
| full | 83580 | 1406.3375 | 7.8400 | 7.9261 | 12.4187 | 127.55 | 10857.2707 |

Raw benchmark outputs:
- `experiments/results/benchmarks/raw/chunk120_bm25plus_subset_2500.txt`
- `experiments/results/benchmarks/raw/chunk120_bm25plus_subset_5000.txt`
- `experiments/results/benchmarks/raw/chunk120_bm25plus_subset_7500.txt`
- `experiments/results/benchmarks/raw/chunk120_bm25plus_subset_10000.txt`
- `experiments/results/benchmarks/raw/chunk120_bm25plus_full.txt`

