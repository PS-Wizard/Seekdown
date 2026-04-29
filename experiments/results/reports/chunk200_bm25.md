# chunk200_bm25

## Configuration

| field | value |
|---|---|
| mode | chunk |
| model | bm25 |
| chunk_size | 200 |

## Full-corpus retrieval effectiveness

| metric | value |
|---|---|
| MAP | 0.1680 |
| MRR | 0.9519 |
| P@10 | 0.8350 |
| nDCG@10 | 0.7710 |
| Recall@10 | 0.1851 |

Raw `trec_eval` output:
- `experiments/results/eval/raw/chunk200_bm25.txt`

## Query performance across corpus sizes

| corpus | indexed_docs | build_ms | mean_ms | median_ms | p95_ms | qps | wall_ms |
|---|---:|---:|---:|---:|---:|---:|---:|
| subset_2500 | 12234 | 325.4709 | 0.6180 | 0.6622 | 0.7270 | 1618.07 | 1080.9524 |
| subset_5000 | 23997 | 636.4985 | 1.3685 | 1.4550 | 1.6724 | 730.73 | 2297.5075 |
| subset_7500 | 35688 | 933.4833 | 2.3523 | 2.4127 | 3.3628 | 425.11 | 3784.7350 |
| subset_10000 | 47240 | 1242.3591 | 3.4049 | 3.4530 | 5.3266 | 293.70 | 5363.1724 |
| full | 52709 | 1376.7848 | 4.2125 | 4.2442 | 6.7922 | 237.39 | 6470.9965 |

Raw benchmark outputs:
- `experiments/results/benchmarks/raw/chunk200_bm25_subset_2500.txt`
- `experiments/results/benchmarks/raw/chunk200_bm25_subset_5000.txt`
- `experiments/results/benchmarks/raw/chunk200_bm25_subset_7500.txt`
- `experiments/results/benchmarks/raw/chunk200_bm25_subset_10000.txt`
- `experiments/results/benchmarks/raw/chunk200_bm25_full.txt`

