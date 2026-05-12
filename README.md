<div align="center">

# seekdown
### A barebones markdown retrieval engine with classic IR ranking and TREC-style evaluation

**Swoyam Pokharel** · **2431342**

<p>
  <img src="https://img.shields.io/badge/Rust-2024-black?style=for-the-badge&logo=rust" alt="Rust 2024" />
  <img src="https://img.shields.io/badge/Index-Inverted-blue?style=for-the-badge" alt="Inverted Index" />
  <img src="https://img.shields.io/badge/Ranking-BM25%20%7C%20TF--IDF%20%7C%20Boolean-6f42c1?style=for-the-badge" alt="Ranking Models" />
  <img src="https://img.shields.io/badge/Evaluation-TREC%20Pipeline-0a7f5a?style=for-the-badge" alt="TREC Pipeline" />
  <img src="https://img.shields.io/badge/Dependencies-Zero-critical?style=for-the-badge" alt="Zero Dependencies" />
</p>




> ### Licence: MIT, do whatever.

</div>

---

## Overview

**seekdown** is a command-line search engine targeted for markdown datasets.

It supports two retrieval granularities:
- **Section retrieval** : split documents by markdown heading hierarchy
- **Chunk retrieval** : split documents into fixed token windows

It supports five ranking models:
- **Boolean overlap**
- **TF-IDF**
- **BM25**
- **BM25+**
- **Pivoted length normalization**

It also includes an evaluation pipeline for:
- **TREC run file generation**
- **candidate pooling for annotation**
- **qrels generation**
- **retrieval benchmarking**

---

## System architecture

```text
Markdown Corpus
   │
   ├── SectionLoader  ──► heading-based retrieval units
   └── ChunkLoader    ──► fixed token-window retrieval units
                           │
                           ▼
                    Inverted Index Builder
                           │
                           ├── lexicon
                           ├── posting lists
                           ├── document lengths
                           └── corpus statistics
                           │
                           ▼
                      Query Processing
                           │
                           ├── tokenize query
                           ├── resolve term ids
                           └── score documents
                                  │
                                  ├── boolean
                                  ├── tfidf
                                  ├── bm25
                                  ├── bm25+
                                  └── pivoted
```

---

## Project structure

```text
src/
├── main.rs              # binary entry point
├── cli.rs               # command parsing and dispatch
├── query.rs             # indexing + retrieval pipeline
├── output.rs            # terminal result rendering
├── bench.rs             # latency benchmarking
├── tokenize/            # tokenizer
├── load/                # corpus readers and document loaders
├── index/               # inverted index structures and builder
├── ranking/             # lexical ranking models
└── eval/                # run files, pools, qrels
```

---

## Retrieval models

| Model | Idea |
|---|---|
| **Boolean** | Scores by number of distinct query terms matched |
| **TF-IDF** | Rewards frequent terms in a document and rare terms in the corpus |
| **BM25** | Standard probabilistic ranking with document-length normalization |
| **BM25+** | BM25 variant with an additive lower-bound adjustment |
| **Pivoted** | TF-IDF-style scoring with pivoted length normalization |

---

## CLI commands

### 1. Search a dataset

```bash
cargo run -- search <dataset_dir> <query> \
  --mode section \
  --model bm25 \
  --top-k 5
```

### 2. Generate a TREC run file

```bash
cargo run -- run <dataset_dir> <queries.csv> \
  --out results.run \
  --name seekdown_bm25 \
  --mode section \
  --model bm25 \
  --top-k 10
```

### 3. Benchmark query latency

```bash
cargo run -- bench <dataset_dir> <queries.csv> \
  --repeat 100 \
  --mode chunk \
  --model bm25plus \
  --top-k 10 \
  --chunk-size 120
```

### 4. Build a pooled candidate file for relevance annotation

```bash
cargo run -- pool <dataset_dir> <queries.csv> \
  --out pooled.csv \
  --modes section,chunk \
  --models boolean,tfidf,bm25,bm25plus,pivoted \
  --top-k 10 \
  --chunk-size 120
```

### 5. Convert annotated pool to qrels

```bash
cargo run -- qrels <annotated_pool.csv> --out qrels.txt
```

---

## Example usage

Querying a markdown documentation corpus:

```bash
cargo run -- search dataset "clap derive subcommands and argument parsing" \
  --mode section \
  --model bm25 \
  --top-k 5
```

This returns ranked sections with:
- title
- file path
- score
- line range
- snippet preview


---

