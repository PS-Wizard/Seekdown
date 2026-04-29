# Literature Review: Lexical Retrieval, Segmentation, and Evaluation in Structured Corpora

### 1. The Enduring Efficacy of Lexical Ranking Models
Despite the recent paradigm shift toward dense neural retrieval and Large Language Models (LLMs) `[xu2025survey]`, classical lexical ranking models remain a critical foundation, particularly in zero-shot, domain-specific, and resource-constrained environments like local documentation search `[killingback2025benchmarking]`. 

The evolution of lexical retrieval began with strict, binary matching mechanisms. The **Boolean model** relies on exact set theory, guaranteeing absolute precision but suffering from a lack of graded relevance `[gupta_survey_ir]`. The introduction of the **Vector Space Model (VSM)** and **TF-IDF** by Salton allowed for partial matching and continuous term weighting, fundamentally changing how document similarity was calculated `[gupta_survey_ir, mekontchou2023wordclustering]`. 

However, TF-IDF assumes a linear relationship between term frequency and relevance, which violates the empirical reality of text. The **Okapi BM25** model resolved this by introducing a probabilistic framework with a non-linear term saturation curve (controlled by the parameter $k_1$) and document length normalization (controlled by the parameter $b$) `[robertson1999okapi]`. Modern benchmarking on complex retrieval tasks continually demonstrates that highly-tuned BM25 implementations remain fiercely competitive baselines, often outperforming un-tuned dense models in domains requiring exact keyword matching (e.g., source code, mathematical retrieval, and highly technical documentation) `[killingback2025benchmarking, kachhadiya2025crosslingual]`.

### 2. The Document Length Penalty Debate (BM25 vs. BM25+ vs. Pivoted)
A major theoretical debate within classical IR—and highly relevant to Seekdown’s Research Question 1—is the proper handling of varying document lengths. Markdown corpora are notoriously heterogeneous; a repository might contain a 50-word `CONTRIBUTING.md` alongside a 10,000-word comprehensive `API_REFERENCE.md`.

While BM25’s length normalization parameter ($b$) was revolutionary, subsequent research revealed a fatal flaw: BM25 overly penalizes very long documents. Because the normalization function strictly divides by length, long documents with high relevance can be pushed down the ranking below short, marginally relevant documents `[lv2011lowerbounding]`. 

To solve this, Lv and Zhai proposed **BM25+**, introducing a lower-bound parameter (+ $\delta$) to the term frequency normalization. This ensures that a single occurrence of a query term in a massive document still yields a strictly positive minimum score `[lv2011lowerbounding]`. An alternative approach, **Pivoted Length Normalization**, tackles the same issue by "pivoting" the normalization function around the average document length of the corpus, mathematically correcting the bias against long texts. Seekdown’s inclusion of Boolean, TF-IDF, BM25, BM25+, and Pivoted models provides an empirical testbed to evaluate these competing length-penalty theories on modern developer documentation.

### 3. Document Segmentation: Fixed-Size vs. Structure-Aware (RQ2 & RQ3)
The decision of how to partition documents prior to indexing—referred to as "chunking" or "passage retrieval"—has become a highly contested area of research. Seekdown’s comparison of fixed `chunk80/120/200` against Markdown `section` segmentation sits directly at the center of this debate.

**The Critique of Fixed-Size Chunking:**
Historically, IR systems relied on fixed-size sliding windows (e.g., 100 tokens) because they are computationally cheap and guarantee uniform index structures. However, modern literature heavily critiques the "chunk-then-embed" or fixed-lexical-boundary approach `[zhou2026beyond]`. Arbitrary token cut-offs result in "semantic fragmentation," severing coreferences and splitting cohesive concepts across distinct retrieval units `[liu2025enhancing, duarte2024lumberchunker]`. Research on models like *LumberChunker* proves that dynamic segmentation—where boundaries adapt to narrative or topical shifts—significantly improves retrieval effectiveness (e.g., DCG@20) `[duarte2024lumberchunker]`. Furthermore, advanced techniques like graph-aware late chunking have been developed specifically to counteract the loss of global context caused by naive segmentation `[mortezaagha2026graphaware]`.

**The Case for Structure and Element Awareness:**
Markdown is not plain text; it is semantically structured. Literature indicates that retrieval systems must explicitly leverage these structural elements (headers, lists, code blocks). The *MDEval* framework emphasizes that "Markdown Awareness" correlates directly with a system's ability to retrieve and comprehend technical data `[chen2025mdeval]`. Furthermore, research on structured document retrieval demonstrates that incorporating structural metadata and element-level semantics substantially boosts precision `[huang2025seal]`. In classical systems, Champclaux et al. demonstrated that combining standard Okapi BM25 with structural similarity metrics yields up to a 50% improvement in Precision at the top 10 retrieved documents `[champclaux2009enhancing]`. 

By comparing `section` segmentation (which respects structural Markdown headers) against `chunk120` (which relies on arbitrary token limits), Seekdown empirically tests whether the semantic preservation of structural boundaries outweighs the statistical predictability of fixed-size units in pure lexical search.

### 4. Computational Scalability and Performance Trade-offs (RQ4 & RQ5)
Evaluating an IR system strictly on retrieval quality ignores the physical realities of software engineering. Search engines face severe bottlenecks during inverted index construction and Top-*k* query latency `[ding2011faster]`.

While neural and cross-domain retrieval models push for higher precision `[chatterjee2025regent]`, they often require immense computational overhead, prompting a resurgence in "sparse" neural models that attempt to mimic the efficiency of classical inverted indexes `[nishida2023sparse]`. However, even within classical inverted indexes, performance trade-offs exist. For instance, techniques like **Block-Max Indexes** optimize Top-*k* document retrieval by safely skipping non-competitive documents during query processing, though this requires more complex index structures upfront `[ding2011faster]`. 

In Seekdown, varying the segmentation strategy directly impacts the index size. Segmenting a 11,000-file corpus into `chunk80` units generates vastly more index postings than `section` segmentation, theoretically increasing memory footprint and query latency. Seekdown’s benchmarking pipeline across 5 corpus sizes (2.5k to 10k) provides a rigorous evaluation of how index granularity (chunk size) directly impacts indexing time, median latency, and Queries Per Second (QPS).

### 5. Evaluation Methodology: The TREC Paradigm
To ensure the scientific validity of IR research, experiments must adhere to standardized, reproducible methodologies. Seekdown’s experimental design is deeply rooted in the **Cranfield paradigm** and the frameworks established by the Text REtrieval Conference (TREC).

Evaluating a corpus of millions of words using human relevance judgments is practically impossible. To solve this, the literature standardizes the use of **pooling**—where the top-*k* results from diverse retrieval systems (in Seekdown's case, all 20 variants) are pooled and annotated `[vu2006machine]`. This reduces the relevance assessment bottleneck while maintaining statistical reliability.

Finally, the choice of evaluation metrics dictates what "success" looks like. While early IR relied purely on binary Precision and Recall, modern search evaluation requires graded relevance. Metrics like **nDCG (Normalized Discounted Cumulative Gain)** evaluate not just whether a document is relevant, but how highly ranked it is, heavily penalizing systems that place highly relevant documents lower in the SERP `[chapelle_optimization_ranking]`. By compiling a deterministic corpus, generating pooled `qrels`, and executing `trec_eval` for metrics like nDCG, MAP, and MRR, Seekdown aligns perfectly with the foundational evaluation standards of academic information retrieval `[vu2006machine, chapelle_optimization_ranking]`.

# Second Addition

### Phase 1: The Canonical IR "Must-Adds" (Add these to your `refs.bib`)

To fix the foundational gaps, add these seminal papers. They are the universally accepted authorities for your methodology:

```bibtex
% The absolute foundation of TF-IDF and Vector Space
@article{salton1975vector,
  title={A vector space model for automatic indexing},
  author={Salton, Gerard and Wong, Anita and Yang, Chung-Shu},
  journal={Communications of the ACM},
  volume={18},
  number={11},
  pages={613--620},
  year={1975},
  publisher={ACM New York, NY, USA}
}

% The authority on Pivoted Length Normalization
@inproceedings{singhal1996pivoted,
  title={Pivoted document length normalization},
  author={Singhal, Amit and Buckley, Chris and Mitra, Mandar},
  booktitle={Proceedings of the 19th annual international ACM SIGIR conference on Research and development in information retrieval},
  pages={21--29},
  year={1996}
}

% The canonical paper for classical Passage Retrieval (Pre-LLM Chunking)
@inproceedings{callan1994passage,
  title={Passage-level evidence in document retrieval},
  author={Callan, James P},
  booktitle={Proceedings of the 17th annual international ACM SIGIR conference on Research and development in information retrieval},
  pages={302--310},
  year={1994}
}

% The ultimate authority on the TREC / Cranfield / Pooling paradigm
@incollection{voorhees2001philosophy,
  title={The philosophy of information retrieval evaluation},
  author={Voorhees, Ellen M},
  booktitle={Evaluation of cross-language information retrieval systems},
  pages={355--370},
  year={2001},
  publisher={Springer}
}

% The canonical origin of nDCG
@article{jarvelin2002cumulated,
  title={Cumulated gain-based evaluation of IR techniques},
  author={J{\"a}rvelin, Kalervo and Kek{\"a}l{\"a}inen, Jaana},
  journal={ACM Transactions on Information Systems (TOIS)},
  volume={20},
  number={4},
  pages={422--446},
  year={2002},
  publisher={ACM New York, NY, USA}
}
```

---

### Phase 2: The Revised Literature Review (Explicitly Bridged to Seekdown)

Here is the revised synthesis, structured to anchor your project in the classics and explicitly bridge to your methodology and research questions.

#### 1. Foundational IR Models and the Document Length Problem (RQ1)
The theoretical foundation of modern search engines relies on the quantification of term significance and document representation. The classical paradigm was established by Salton et al. `[salton1975vector]` with the introduction of the **Vector Space Model (VSM)** and **TF-IDF**, which allowed documents to be ranked by continuous similarity scores rather than strict Boolean retrieval. 

However, TF-IDF fails to account for term saturation and varying document lengths. This is a critical issue in developer documentation, where a corpus contains highly heterogeneous lengths (e.g., a massive `API_REFERENCE.md` vs. a short `CONTRIBUTING.md`). The probabilistic framework, culminating in **Okapi BM25** `[robertson1999okapi]`, solved this via non-linear term saturation ($k_1$) and length normalization ($b$). Yet, standard BM25 strictly penalizes very long documents. To address this, Singhal et al. introduced **Pivoted Length Normalization** to mathematically pivot the penalty around the corpus average `[singhal1996pivoted]`, and Lv and Zhai later introduced **BM25+** to provide a strict lower-bound score for long documents `[lv2011lowerbounding]`.

**Bridge to Seekdown (RQ1):** Seekdown’s inclusion of Boolean, TF-IDF, BM25, BM25+, and Pivoted models explicitly tests this progression of classical IR theory. By evaluating these models on a modern Markdown corpus, Seekdown investigates whether the length-penalty corrections proposed by Singhal (Pivoted) and Lv (BM25+) practically outperform standard BM25 when searching heterogeneous developer documentation.

#### 2. From Passage Retrieval to Structured Segmentation (RQ2 & RQ3)
The decision of how to partition a document before indexing is a foundational problem in IR. Long before the era of LLMs and "RAG," classical IR studied this as **passage retrieval**. Callan demonstrated that retrieving fixed-size "passages" (windows of text) alongside full documents significantly improves precision by isolating local context and mitigating the noise of long documents `[callan1994passage]`. 

While fixed-size chunking (e.g., 80, 120, or 200 tokens) is computationally efficient, it inherently suffers from "semantic fragmentation," arbitrarily severing coreferences `[zhou2026beyond]`. Conversely, structured document retrieval argues for exploiting explicitly authored boundaries. Early work by Champclaux et al. proved that combining BM25 with structural similarities enhances Top-10 precision `[champclaux2009enhancing]`. Modern frameworks like *MDEval* `[chen2025mdeval]` and *SEAL* `[huang2025seal]` reinforce that in formats like Markdown, structural elements (e.g., `# Headers`) denote hard semantic boundaries that should dictate retrieval units.

**Bridge to Seekdown (RQ2 & RQ3):** Seekdown operationalizes this classical vs. modern debate. By comparing arbitrary token windows (`chunk80`, `chunk120`, `chunk200`) against structurally aware parsing (`section`), Research Question 2 tests whether the semantic preservation of Markdown headers outweighs the statistical uniformity of fixed passages. Furthermore, Research Question 3 evaluates the fixed-size axis itself: finding the optimal passage size (80 vs. 120 vs. 200) that balances local context density with sufficient vocabulary.

#### 3. Evaluation Methodology: The Cranfield and TREC Paradigm
To ensure the scientific validity of Seekdown's findings, the experimental design strictly adheres to the **Cranfield paradigm** and the methodology standardized by the Text REtrieval Conference (TREC) `[voorhees2001philosophy]`. 

Because evaluating an 11,000-document corpus against 60 queries exhaustively is impossible, IR relies on **pooling**. As defined by Voorhees `[voorhees2001philosophy]`, pooling takes the top-$k$ (e.g., Top-10) documents retrieved by diverse participating systems and forms a unified candidate set for human (or LLM) relevance annotation. Documents outside this pool are assumed non-relevant. This guarantees an unbiased evaluation environment across all tested models.

Furthermore, binary metrics (Precision/Recall) are insufficient for modern search evaluation. Järvelin and Kekäläinen established **nDCG (Normalized Discounted Cumulative Gain)** to evaluate graded relevance, heavily penalizing systems that rank highly relevant documents lower in the results `[jarvelin2002cumulated]`. 

**Bridge to Seekdown:** Seekdown’s methodology is a direct implementation of this canonical standard. By pooling the Top-10 results from all 20 system variants (5 models $\times$ 4 segmentations), constructing TREC-safe `qrels`, and utilizing `trec_eval` to calculate nDCG, MRR, and MAP, the project ensures its findings on Markdown retrieval are statistically rigorous and comparable to industry benchmarks.

#### 4. Scalability, Indexing, and Performance Trade-offs (RQ4 & RQ5)
Evaluating an IR system strictly on ranking effectiveness ignores the physical constraints of software engineering. The construction of inverted indexes and the traversal of posting lists are primary computational bottlenecks `[ding2011faster]`. 

Different segmentation strategies alter the fundamental architecture of the inverted index. For example, dividing an 11,000-file corpus into 80-token chunks drastically increases the total number of indexed units compared to coarser `section` parsing. This inherently impacts the index build time, memory footprint, and posting list traversal latency during query execution. While optimizations like Block-Max Indexes `[ding2011faster]` can accelerate Top-$k$ retrieval by skipping non-competitive documents, the underlying granularity of the index remains the primary driver of performance.

**Bridge to Seekdown (RQ4 & RQ5):** A local search engine in Rust must prioritize low latency and low memory overhead. Seekdown addresses this by benchmarking all 20 systems across five deterministic corpus scales (2.5k to 10k documents). This allows for an empirical analysis of QPS (Queries Per Second) and p95 latency, explicitly answering RQ5 by identifying the exact configuration that offers the best compromise between TREC evaluation effectiveness (nDCG) and real-time execution speed.
