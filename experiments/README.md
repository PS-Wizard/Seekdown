# Experiments

Frozen experiment layout for the final report.

## Full-corpus retrieval effectiveness systems

The evaluation matrix is fixed at 20 systems:

- `section × {boolean, tfidf, bm25, bm25plus, pivoted}`
- `chunk80 × {boolean, tfidf, bm25, bm25plus, pivoted}`
- `chunk120 × {boolean, tfidf, bm25, bm25plus, pivoted}`
- `chunk200 × {boolean, tfidf, bm25, bm25plus, pivoted}`

Queries:
- `tests/queries/queries.csv`

Corpus for effectiveness:
- `dataset/`

## Directory layout

- `systems/` — frozen system matrix manifests
- `results/` — generated run files, eval summaries, and benchmark outputs
- `qrels/` — final qrels and supporting evaluation files
- `annotated/` — pooled candidate files and annotated pool CSVs

## Scripts

- `scripts/run_full_corpus_experiments.sh`
  - Generates all 20 TREC run files.
- `scripts/build_full_corpus_pool.sh`
  - Builds the pooled candidate CSV for annotation across all 20 systems.
