# chunk200_bm25plus

## Configuration

| field | value |
|---|---|
| mode | chunk |
| model | bm25plus |
| chunk_size | 200 |

## Full-corpus retrieval effectiveness

| metric | value |
|---|---|
| MAP | 0.1656 |
| MRR | 0.9489 |
| P@10 | 0.8283 |
| nDCG@10 | 0.7695 |
| Recall@10 | 0.1826 |

Raw `trec_eval` output:
- `experiments/results/eval/raw/chunk200_bm25plus.txt`

## Query performance across corpus sizes

| corpus | indexed_docs | build_ms | mean_ms | median_ms | p95_ms | qps | wall_ms |
|---|---:|---:|---:|---:|---:|---:|---:|
| subset_2500 | 12234 | 323.6493 | 0.6227 | 0.6655 | 0.7416 | 1605.86 | 1083.3111 |
| subset_5000 | 23997 | 636.5614 | 1.3710 | 1.4624 | 1.6326 | 729.42 | 2299.2178 |
| subset_7500 | 35688 | 935.7019 | 2.2847 | 2.3849 | 3.1582 | 437.69 | 3701.1803 |
| subset_10000 | 47240 | 1230.0399 | 3.4347 | 3.5139 | 5.1799 | 291.15 | 5385.9795 |
| full | 52709 | 1369.6392 | 3.9593 | 4.0217 | 6.5645 | 252.57 | 6155.2301 |

Raw benchmark outputs:
- `experiments/results/benchmarks/raw/chunk200_bm25plus_subset_2500.txt`
- `experiments/results/benchmarks/raw/chunk200_bm25plus_subset_5000.txt`
- `experiments/results/benchmarks/raw/chunk200_bm25plus_subset_7500.txt`
- `experiments/results/benchmarks/raw/chunk200_bm25plus_subset_10000.txt`
- `experiments/results/benchmarks/raw/chunk200_bm25plus_full.txt`

