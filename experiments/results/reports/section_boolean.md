# section_boolean

## Configuration

| field | value |
|---|---|
| mode | section |
| model | boolean |
| chunk_size | n/a |

## Full-corpus retrieval effectiveness

| metric | value |
|---|---|
| MAP | 0.0926 |
| MRR | 0.7154 |
| P@10 | 0.6000 |
| nDCG@10 | 0.3707 |
| Recall@10 | 0.1170 |

Raw `trec_eval` output:
- `experiments/results/eval/raw/section_boolean.txt`

## Query performance across corpus sizes

| corpus | indexed_docs | build_ms | mean_ms | median_ms | p95_ms | qps | wall_ms |
|---|---:|---:|---:|---:|---:|---:|---:|
| subset_2500 | 18749 | 259.7310 | 0.6199 | 0.6483 | 0.7968 | 1613.27 | 1017.9136 |
| subset_5000 | 37074 | 509.9445 | 1.4252 | 1.4786 | 1.8782 | 701.64 | 2243.4642 |
| subset_7500 | 56580 | 744.6472 | 2.5444 | 2.5511 | 3.8347 | 393.02 | 3829.8652 |
| subset_10000 | 75307 | 982.1682 | 3.5777 | 3.5662 | 5.9327 | 279.51 | 5321.4126 |
| full | 83793 | 1086.9235 | 5.3386 | 5.4100 | 8.3166 | 187.31 | 7540.5015 |

Raw benchmark outputs:
- `experiments/results/benchmarks/raw/section_boolean_subset_2500.txt`
- `experiments/results/benchmarks/raw/section_boolean_subset_5000.txt`
- `experiments/results/benchmarks/raw/section_boolean_subset_7500.txt`
- `experiments/results/benchmarks/raw/section_boolean_subset_10000.txt`
- `experiments/results/benchmarks/raw/section_boolean_full.txt`

