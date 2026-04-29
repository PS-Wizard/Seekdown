# chunk80_pivoted

## Configuration

| field | value |
|---|---|
| mode | chunk |
| model | pivoted |
| chunk_size | 80 |

## Full-corpus retrieval effectiveness

| metric | value |
|---|---|
| MAP | 0.1619 |
| MRR | 0.9417 |
| P@10 | 0.8250 |
| nDCG@10 | 0.7357 |
| Recall@10 | 0.1758 |

Raw `trec_eval` output:
- `experiments/results/eval/raw/chunk80_pivoted.txt`

## Query performance across corpus sizes

| corpus | indexed_docs | build_ms | mean_ms | median_ms | p95_ms | qps | wall_ms |
|---|---:|---:|---:|---:|---:|---:|---:|
| subset_2500 | 28521 | 336.8121 | 1.4773 | 1.5609 | 1.8502 | 676.90 | 2123.0148 |
| subset_5000 | 55797 | 659.6308 | 3.7063 | 3.7496 | 5.9874 | 269.81 | 5131.4157 |
| subset_7500 | 82851 | 971.0394 | 6.3021 | 6.4775 | 9.9560 | 158.68 | 8567.9405 |
| subset_10000 | 109624 | 1294.2232 | 10.6748 | 10.8440 | 15.3634 | 93.68 | 14158.1326 |
| full | 122359 | 1649.8807 | 15.3309 | 16.6750 | 20.3245 | 65.23 | 20114.2374 |

Raw benchmark outputs:
- `experiments/results/benchmarks/raw/chunk80_pivoted_subset_2500.txt`
- `experiments/results/benchmarks/raw/chunk80_pivoted_subset_5000.txt`
- `experiments/results/benchmarks/raw/chunk80_pivoted_subset_7500.txt`
- `experiments/results/benchmarks/raw/chunk80_pivoted_subset_10000.txt`
- `experiments/results/benchmarks/raw/chunk80_pivoted_full.txt`

