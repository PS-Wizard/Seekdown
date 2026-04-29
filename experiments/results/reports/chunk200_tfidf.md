# chunk200_tfidf

## Configuration

| field | value |
|---|---|
| mode | chunk |
| model | tfidf |
| chunk_size | 200 |

## Full-corpus retrieval effectiveness

| metric | value |
|---|---|
| MAP | 0.1547 |
| MRR | 0.9227 |
| P@10 | 0.8167 |
| nDCG@10 | 0.7388 |
| Recall@10 | 0.1752 |

Raw `trec_eval` output:
- `experiments/results/eval/raw/chunk200_tfidf.txt`

## Query performance across corpus sizes

| corpus | indexed_docs | build_ms | mean_ms | median_ms | p95_ms | qps | wall_ms |
|---|---:|---:|---:|---:|---:|---:|---:|
| subset_2500 | 12234 | 326.8186 | 0.6725 | 0.7209 | 0.7772 | 1486.95 | 1147.3364 |
| subset_5000 | 23997 | 631.8833 | 1.4715 | 1.5744 | 1.7570 | 679.57 | 2415.7112 |
| subset_7500 | 35688 | 939.5075 | 2.5014 | 2.5857 | 3.5026 | 399.78 | 3966.9044 |
| subset_10000 | 47240 | 1235.6390 | 3.8585 | 3.8903 | 6.0408 | 259.17 | 5899.0227 |
| full | 52709 | 1380.8202 | 4.2427 | 4.2800 | 7.1255 | 235.70 | 6506.0788 |

Raw benchmark outputs:
- `experiments/results/benchmarks/raw/chunk200_tfidf_subset_2500.txt`
- `experiments/results/benchmarks/raw/chunk200_tfidf_subset_5000.txt`
- `experiments/results/benchmarks/raw/chunk200_tfidf_subset_7500.txt`
- `experiments/results/benchmarks/raw/chunk200_tfidf_subset_10000.txt`
- `experiments/results/benchmarks/raw/chunk200_tfidf_full.txt`

