# section_tfidf

## Configuration

| field | value |
|---|---|
| mode | section |
| model | tfidf |
| chunk_size | n/a |

## Full-corpus retrieval effectiveness

| metric | value |
|---|---|
| MAP | 0.1043 |
| MRR | 0.8302 |
| P@10 | 0.6417 |
| nDCG@10 | 0.3883 |
| Recall@10 | 0.1314 |

Raw `trec_eval` output:
- `experiments/results/eval/raw/section_tfidf.txt`

## Query performance across corpus sizes

| corpus | indexed_docs | build_ms | mean_ms | median_ms | p95_ms | qps | wall_ms |
|---|---:|---:|---:|---:|---:|---:|---:|
| subset_2500 | 18749 | 255.4902 | 0.5940 | 0.6305 | 0.7372 | 1683.50 | 986.3039 |
| subset_5000 | 37074 | 521.2650 | 1.5511 | 1.5744 | 2.3540 | 644.70 | 2409.5054 |
| subset_7500 | 56580 | 758.8202 | 2.9115 | 2.8570 | 4.4676 | 343.47 | 4304.1311 |
| subset_10000 | 75307 | 1009.4628 | 3.8708 | 3.7365 | 6.3538 | 258.34 | 5696.1745 |
| full | 83793 | 1105.2027 | 4.8092 | 4.9163 | 7.1869 | 207.94 | 6925.1410 |

Raw benchmark outputs:
- `experiments/results/benchmarks/raw/section_tfidf_subset_2500.txt`
- `experiments/results/benchmarks/raw/section_tfidf_subset_5000.txt`
- `experiments/results/benchmarks/raw/section_tfidf_subset_7500.txt`
- `experiments/results/benchmarks/raw/section_tfidf_subset_10000.txt`
- `experiments/results/benchmarks/raw/section_tfidf_full.txt`

