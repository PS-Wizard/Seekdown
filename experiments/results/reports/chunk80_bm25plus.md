# chunk80_bm25plus

## Configuration

| field | value |
|---|---|
| mode | chunk |
| model | bm25plus |
| chunk_size | 80 |

## Full-corpus retrieval effectiveness

| metric | value |
|---|---|
| MAP | 0.1738 |
| MRR | 0.9431 |
| P@10 | 0.8400 |
| nDCG@10 | 0.7692 |
| Recall@10 | 0.1911 |

Raw `trec_eval` output:
- `experiments/results/eval/raw/chunk80_bm25plus.txt`

## Query performance across corpus sizes

| corpus | indexed_docs | build_ms | mean_ms | median_ms | p95_ms | qps | wall_ms |
|---|---:|---:|---:|---:|---:|---:|---:|
| subset_2500 | 28521 | 339.4062 | 1.4224 | 1.4977 | 1.7715 | 703.06 | 2061.4693 |
| subset_5000 | 55797 | 656.3940 | 3.3578 | 3.4512 | 4.8978 | 297.82 | 4713.4227 |
| subset_7500 | 82851 | 966.8677 | 6.0948 | 6.2602 | 9.7375 | 164.08 | 8316.8607 |
| subset_10000 | 109624 | 1284.8034 | 9.6082 | 10.0287 | 13.6166 | 104.08 | 12857.8420 |
| full | 122359 | 1432.1894 | 11.5178 | 12.1297 | 15.6661 | 86.82 | 15304.4705 |

Raw benchmark outputs:
- `experiments/results/benchmarks/raw/chunk80_bm25plus_subset_2500.txt`
- `experiments/results/benchmarks/raw/chunk80_bm25plus_subset_5000.txt`
- `experiments/results/benchmarks/raw/chunk80_bm25plus_subset_7500.txt`
- `experiments/results/benchmarks/raw/chunk80_bm25plus_subset_10000.txt`
- `experiments/results/benchmarks/raw/chunk80_bm25plus_full.txt`

