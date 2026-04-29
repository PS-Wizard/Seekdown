# chunk120_tfidf

## Configuration

| field | value |
|---|---|
| mode | chunk |
| model | tfidf |
| chunk_size | 120 |

## Full-corpus retrieval effectiveness

| metric | value |
|---|---|
| MAP | 0.1544 |
| MRR | 0.9103 |
| P@10 | 0.8083 |
| nDCG@10 | 0.7285 |
| Recall@10 | 0.1691 |

Raw `trec_eval` output:
- `experiments/results/eval/raw/chunk120_tfidf.txt`

## Query performance across corpus sizes

| corpus | indexed_docs | build_ms | mean_ms | median_ms | p95_ms | qps | wall_ms |
|---|---:|---:|---:|---:|---:|---:|---:|
| subset_2500 | 19469 | 340.3810 | 1.0821 | 1.1575 | 1.2767 | 924.09 | 1652.1617 |
| subset_5000 | 38105 | 646.1446 | 2.4977 | 2.5895 | 3.4497 | 400.37 | 3670.8429 |
| subset_7500 | 56579 | 956.9445 | 4.4273 | 4.4891 | 7.1212 | 225.87 | 6298.6209 |
| subset_10000 | 74887 | 1270.1344 | 6.7029 | 6.9249 | 10.3278 | 149.19 | 9354.1973 |
| full | 83580 | 1401.5359 | 8.0034 | 8.3829 | 11.6360 | 124.95 | 11049.4366 |

Raw benchmark outputs:
- `experiments/results/benchmarks/raw/chunk120_tfidf_subset_2500.txt`
- `experiments/results/benchmarks/raw/chunk120_tfidf_subset_5000.txt`
- `experiments/results/benchmarks/raw/chunk120_tfidf_subset_7500.txt`
- `experiments/results/benchmarks/raw/chunk120_tfidf_subset_10000.txt`
- `experiments/results/benchmarks/raw/chunk120_tfidf_full.txt`

