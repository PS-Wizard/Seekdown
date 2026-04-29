# chunk120_bm25

## Configuration

| field | value |
|---|---|
| mode | chunk |
| model | bm25 |
| chunk_size | 120 |

## Full-corpus retrieval effectiveness

| metric | value |
|---|---|
| MAP | 0.1681 |
| MRR | 0.9569 |
| P@10 | 0.8333 |
| nDCG@10 | 0.7710 |
| Recall@10 | 0.1815 |

Raw `trec_eval` output:
- `experiments/results/eval/raw/chunk120_bm25.txt`

## Query performance across corpus sizes

| corpus | indexed_docs | build_ms | mean_ms | median_ms | p95_ms | qps | wall_ms |
|---|---:|---:|---:|---:|---:|---:|---:|
| subset_2500 | 19469 | 337.3975 | 0.9992 | 1.0704 | 1.1635 | 1000.75 | 1548.8911 |
| subset_5000 | 38105 | 645.8304 | 2.3181 | 2.4203 | 3.1143 | 431.38 | 3448.3235 |
| subset_7500 | 56579 | 953.4904 | 4.1360 | 4.2194 | 6.3827 | 241.78 | 5952.7074 |
| subset_10000 | 74887 | 1261.4397 | 6.8333 | 6.9286 | 10.8036 | 146.34 | 9503.3491 |
| full | 83580 | 1404.6834 | 7.8239 | 7.9112 | 12.4580 | 127.81 | 10837.1125 |

Raw benchmark outputs:
- `experiments/results/benchmarks/raw/chunk120_bm25_subset_2500.txt`
- `experiments/results/benchmarks/raw/chunk120_bm25_subset_5000.txt`
- `experiments/results/benchmarks/raw/chunk120_bm25_subset_7500.txt`
- `experiments/results/benchmarks/raw/chunk120_bm25_subset_10000.txt`
- `experiments/results/benchmarks/raw/chunk120_bm25_full.txt`

