# chunk80_bm25

## Configuration

| field | value |
|---|---|
| mode | chunk |
| model | bm25 |
| chunk_size | 80 |

## Full-corpus retrieval effectiveness

| metric | value |
|---|---|
| MAP | 0.1688 |
| MRR | 0.9597 |
| P@10 | 0.8333 |
| nDCG@10 | 0.7617 |
| Recall@10 | 0.1833 |

Raw `trec_eval` output:
- `experiments/results/eval/raw/chunk80_bm25.txt`

## Query performance across corpus sizes

| corpus | indexed_docs | build_ms | mean_ms | median_ms | p95_ms | qps | wall_ms |
|---|---:|---:|---:|---:|---:|---:|---:|
| subset_2500 | 28521 | 356.8211 | 1.5268 | 1.5644 | 2.1855 | 654.95 | 2206.4138 |
| subset_5000 | 55797 | 709.0579 | 4.3811 | 4.8766 | 6.2388 | 228.25 | 5992.1563 |
| subset_7500 | 82851 | 988.0062 | 6.1776 | 6.3098 | 9.6258 | 161.87 | 8438.3317 |
| subset_10000 | 109624 | 1286.6906 | 10.3921 | 10.8466 | 15.1151 | 96.23 | 13807.0038 |
| full | 122359 | 1426.1619 | 12.0853 | 12.5123 | 17.7046 | 82.75 | 15978.7707 |

Raw benchmark outputs:
- `experiments/results/benchmarks/raw/chunk80_bm25_subset_2500.txt`
- `experiments/results/benchmarks/raw/chunk80_bm25_subset_5000.txt`
- `experiments/results/benchmarks/raw/chunk80_bm25_subset_7500.txt`
- `experiments/results/benchmarks/raw/chunk80_bm25_subset_10000.txt`
- `experiments/results/benchmarks/raw/chunk80_bm25_full.txt`

