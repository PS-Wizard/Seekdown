#import "@preview/charged-ieee:0.1.4": ieee

#show: ieee.with(
  title: [Evaluation of Classical Retrieval Models and Segmentation Strategies for Markdown Search],
  abstract: [
    This paper evaluates Seekdown, a zero-dependency search engine built in Rust specifically targeted towards markdown-based technical documentation. This experiment compares *20* retrieval systems produced by combining four segmentation strategies (`section`, `chunk80`, `chunk120`, `chunk200`) with five classical ranking models: `Boolean`, `TF-IDF`, `BM25`, `BM25+`, and `Pivoted Length Normalization`. The evaluation uses *11,095* Markdown files, *60* queries, pooled relevance judgments, TREC-style qrels, and graded retrieval metrics. The results show that segmentation matters more than small ranking-model differences. Fixed-size chunks consistently beat section-based indexing on effectiveness. The best system was `chunk120_bm25plus` with `nDCG-at-10` = *0.7820*, while `chunk200_bm25` reached nearly the same quality (*0.7710*) with much lower median latency (*4.24* ms instead of *7.93* ms). Section-based systems were fast, but the quality drop was too large. Overall, classical lexical retrieval is still practical for local markdown search, provided that the retrieval unit is chosen carefully.
  ],
  authors: (
    (
      name: "Swoyam Pokharel -- 2431342",
      department: [6CS030 Big Data],
      organization: [University Of Wolverhampton -- Herald College Kathamandu],
      location: [Kathmandu, Nepal],
      email: "np03cs4s240026@heraldcollege.edu.np",
    ),
  ),
  index-terms: (
    "information retrieval",
    "markdown search",
    "document segmentation",
    "classical lexical retrieval",
  ),
  figure-supplement: [Fig.],
)

#set text(font: "Noto Serif", size: 10pt, lang: "en", spacing: 100%)
#set par(
  justify: true,
  first-line-indent: 0pt,
  leading: 0.62em,
  spacing: 0.65em,
)
#set text(hyphenate: false)

#let fig(path, caption) = figure(
  image(path, width: 100%),
  caption: caption,
)

#let small = 8pt

#show table.cell.where(y: 0): strong
#show raw.where(block: false): it => box(
  fill: luma(242),
  inset: (x: 2.4pt, y: 1.1pt),
  radius: 1.5pt,
  text(font: "Noto Sans Mono", size: 8.4pt, fill: luma(35), it),
)
#show raw.where(block: true): it => block(
  width: 100%,
  fill: luma(245),
  inset: 7pt,
  radius: 2pt,
  stroke: 0.35pt + luma(215),
  text(font: "Noto Sans Mono", size: 8pt, fill: luma(35), it),
)

#let paper-table(columns: auto, align: auto, ..rows) = table(
  columns: columns,
  inset: (x: 5pt, y: 4pt),
  align: align,
  stroke: 0.35pt + luma(180),
  fill: (x, y) => if y == 0 { luma(238) } else if calc.rem(y, 2) == 0 { luma(250) },
  ..rows,
)

#let system-id(s) = box(
  fill: luma(242),
  inset: (x: 1.7pt, y: 0.7pt),
  radius: 1.2pt,
  text(font: "Noto Sans Mono", size: 6.4pt, fill: luma(35), s),
)

= Introduction

Markdown documentation search sits in an odd position. Recently, most retrieval discussions have shifted toward dense retrieval and large language model pipelines @xu2025survey @chatterjee2025regent. However, consumer-facing devices often need search systems that can run locally, respond quickly, and avoid the hardware requirements of neural information retrieval systems. In this case, lexical retrieval is not outdated. It remains useful because it is cheap, deterministic, able to run on most consumer devices, and easier to debug than neural-based approaches @killingback2025benchmarking @kachhadiya2025crosslingual.


Seekdown is a search engine targeted towards Markdown-based technical documentation. It has been tested specifically in this setting. The main challenge is that Markdown corpora are structured but very uneven. Especially in the context of technical documentation, a repository can contain a short README alongside a long API reference, with headings, lists, tables, and code blocks mixed together. This makes the actual retrieval unit significantly more important. So, with Seekdown, the aim is to answer two core questions:

- Which classical ranking model holds up best under extreme length variation and technical vocabulary?
- What is the right indexing unit for Markdown: a structure-aware section, or a fixed-size chunk?

The first question concerns document length normalization techniques such as `TF-IDF`, `BM25`, `BM25+`, and `Pivoted Length Normalization` @salton1975vector @robertson1999okapi @lv2011lowerbounding @singhal1996pivoted. The second question is essentially a passage retrieval problem: should the system respect markdown boundaries, or should it force documents into uniform windows and hope that the window size works well? @callan1994passage @champclaux2009enhancing @zhou2026beyond @chen2025mdeval @huang2025seal. 

The evaluation was done using the Cranfield/TREC workflow @voorhees2001philosophy. A corpus of *11,095* Markdown files, containing *7,934,587* words, was paired with *60* queries. The top results from all systems were pooled, annotated into graded qrels, and scored using the standard retrieval metrics such as `MAP`, `MRR`, `P-at-10`, `Recall-at-10`, and `nDCG-at-10` @jarvelin2002cumulated @vu2006machine. Scalability was measured separately by benchmarking build time, median latency, `p95` latency, and throughput across five corpus sizes.

This project is organized around five research questions:

- Which lexical ranking model performs best on Markdown retrieval?
- Does a structure-aware `section` segmentation outperform fixed-size chunking?
- Among fixed chunk sizes, which performs the best?
- How do segmentation strategies affect indexing and performance?
- Which configuration offers the best quality to performance trade-off?

Based on the findings, we can conclude that chunking wins on effectiveness, and chunk size seems to directly correspond with latency. `chunk120_bm25plus` is the best pure-quality configuration, but `chunk200_bm25` is a better practical trade-off when speed and quality both matter.

== Contributions

This project:

- Provides a comparison of five different classical lexical ranking models, on a fairly large Markdown corpus. 
- Compares structure-aware section indexing against three fixed-size chunking strategies. 
- Adds evidence to the current chunk-sizing debate by testing whether smaller, larger, or section-aware chunks act as the best retrieval unit for technical documentation. This directly connects to recent concerns around over-segmentation, semantic fragmentation, and the loss of surrounding context in chunked retrieval systems @zhou2026beyond @duarte2024lumberchunker @liu2025enhancing.
- It reports both retrieval quality and performance under a growing corpus size.
- It produces a reproducible TREC-style markdown retrieval benchmark built from pooled judgments, giving a compact workflow for evaluating local documentation search.

= Related Work

Seekdown revolves around three areas, namely: classical lexical ranking, segmentation / passage retrieval, and evaluation methodology.

For classical IR, it starts with `Boolean` retrieval. Although precise, it is very naive, because a term either matches or it does not @gupta_survey_ir. Salton's vector space model and `TF-IDF` made retrieval less rigid by introducing partial matching @salton1975vector. But, the problem is that `TF-IDF` still rewards repeated terms too linearly. In long technical documents, seeing the same term ten more times does not always mean the document is ten times more useful. Usefulness is rarely a linear scale. 

As such, probabilistic ranking functions were built to fix this. `BM25` remains the standard because it captures both term-frequency saturation and document-length normalization @robertson1999okapi. Modern benchmarking continues to show that a tuned lexical retrieval can still be extremely competitive in cases where exact terminology matters, such as code and technical documentation @killingback2025benchmarking @kachhadiya2025crosslingual.

Within the `BM25` family, document length is the long-running argument. Standard `BM25` can penalize long documents too aggressively, which often can suppress genuinely relevant long texts. `BM25+` addresses this by lower-bounding the normalization term so that long relevant documents still get meaningful credit when they match query terms @lv2011lowerbounding. `Pivoted Length Normalization` takes a different angle by pivoting the length penalty around a corpus-specific reference length @singhal1996pivoted. Thus, a markdown corpus, with a fairly large length variability, is a direct stress test for these techniques.

Segmentation is the other half of the problem. Long documents rarely contain relevant information uniformly; usually, it's one small portion that directly matches some query. Passage retrieval is not a new topic; Callan proved this decades ago: search systems work better when they score these local relevant passages instead of treating the entire document as equally relevant @callan1994passage.

Although fixed-size chunking provides a predictable structure, it can often break sentences midway, which in turn breaks any coherent ideas that were being said midway. Recent studies argue that this sort of naive chunking can fragment semantics and hurt retrieval quality @zhou2026beyond @duarte2024lumberchunker @liu2025enhancing.

Structured document retrieval argues that if a corpus already encodes good boundaries, said boundaries _should_ matter. Early work showed that structural cues can improve retrieval when paired with `BM25`-style scoring @champclaux2009enhancing. More recent systems like SEAL and Markdown-focused benchmarks like MDEval convey the same point: structure and element awareness do matter for long technical documents @huang2025seal @chen2025mdeval. As such, Seekdown’s `section` mode is a simple test of this idea; it treats headings as retrieval units.

Finally, the evaluation design follows standard TREC practice. Pooling allows relevance assessment at reasonable cost by judging only a candidate set drawn from multiple systems @voorhees2001philosophy @vu2006machine. `nDCG` is particularly appropriate here because judgments are graded and documentation search is top-heavy: users rarely scroll far, so top-rank placement matters more than deep recall @jarvelin2002cumulated.

= System Design

Seekdown is a Rust-based command-line retrieval system for Markdown corpora. The design goal was straightforward: keep the pipeline inspectable, reproducible, and local. There are zero external runtime dependencies. Everything runs through one binary. 

At the top level, the project is split into modules for benchmarking, CLI handling, evaluation helpers, indexing, loading, output formatting, query execution, ranking, and tokenization. 

The CLI exposes five main commands:

- `search`: run one query and print ranked results.
- `run`: generate `TREC` run files for a query set.
- `bench`: benchmark repeated query execution and report build time, latency, and throughput.
- `pool`: create pooled candidate sets from multiple runs.
- `qrels`: convert annotated pools into `TREC` qrels.

== Corpus Processing

The corpus consists of Markdown technical documentation under `dataset/`. At evaluation time, it contains 11,095 files and 7,934,587 words. Those files belong to the following projects:

```
┌ ~/Projects/seekdown/dataset on main
└ ❯ tree -L 1
.
├── axum
├── bat
├── book
├── cargo
├── clap
├── docker-docs
├── fd
├── fishtest
├── github-docs
├── hugoDocs
├── hyprland-wiki
├── json
├── kubernetes-website
├── mdBook
├── niri
├── nomicon
├── nushell.github.io
├── rayon
├── reference
├── ripgrep
├── rust-by-example
├── rustc-dev-guide
├── rust-clippy
├── rustfmt
├── rustlings
├── serde
├── sway
├── tokio
├── vscode-docs
└── wezterm
31 directories, 0 files
```

Seekdown supports two loading modes:

- `section`: headings define retrieval unit boundaries.
- `chunk`: documents are split into fixed-size token windows.

Three chunk sizes were evaluated: 80, 120, and 200. 

== Indexing and Retrieval Models

Documents are tokenized, segmented into retrieval units, and scored using one of five ranking models:

- `Boolean`
- `TF-IDF`
- `BM25`
- `BM25+`
- `Pivoted Length Normalization`

`Boolean` is included just as a baseline. `TF-IDF` is the classic weighted vector-space approach @salton1975vector. `BM25` is the default probabilistic baseline @robertson1999okapi. `BM25+` and `Pivoted Length Normalization` test two different responses to document length bias @lv2011lowerbounding @singhal1996pivoted.

For the test, every ranking model is paired with every segmentation family, yielding 20 different models. 

== Query Processing and Output Format

The effectiveness query set contains 60 short, developer-style information needs stored in `tests/queries/queries.csv`. Representative examples are shown in @query-examples.

#figure(
  text(size: 7.8pt)[
    #paper-table(
      columns: (0.55fr, 2.7fr),
      align: (center + horizon, left + horizon),
      table.header([ID], [Query text]),
      [`q001`], [axum routing handlers],
      [`q002`], [axum middleware state management],
      [`q003`], [bat syntax highlighting themes],
      [`q004`], [bat line numbers and paging],
      [`q005`], [book markdown chapters and summary],
      [`q006`], [book publishing and output formats],
      [`q007`], [cargo dependencies features and workspace configuration],
      [`q008`], [cargo build release and test commands],
      [`q009`], [clap derive subcommands and argument parsing],
    )
  ],
  caption: [Examples from the 60-query set],
) <query-examples>

Each system produces TREC-formatted run files so that scoring can be performed using the standard `trec_eval` toolkit. This makes Seekdown align with the established evaluation methodology used in the Text REtrieval Conference (TREC).

= Methodology

The experimental design follows the Cranfield/TREC paradigm @voorhees2001philosophy. The system matrix is fixed, the corpus and query set are fixed, judgments are pooled, and scoring uses standard IR metrics. 

== Evaluation Corpus and Query Set

The corpus contains 11,095 files and 7,934,587 words. The query set contains 60 short, task-focused queries. It is worth noting that the corpus is “single domain” in the broad sense that it consists of only technical documentation. With that said, it contains varied projects and writing styles, which keeps the benchmark realistic while preserving enough terminology overlap for lexical retrieval to be meaningful.

== System Matrix

#figure(
  text(size: 7pt)[
    #paper-table(
      columns: (0.72fr, 3.25fr),
      align: (left + horizon, left + horizon),
      table.header([Seg.], [System IDs]),
      [section], [
        #system-id("section_boolean") #h(8pt)
        #system-id("section_tfidf") #h(8pt)
        #system-id("section_bm25") \
        #system-id("section_bm25plus") #h(8pt)
        #system-id("section_pivoted")
      ],
      [chunk80], [
        #system-id("chunk80_boolean") #h(8pt)
        #system-id("chunk80_tfidf") #h(8pt)
        #system-id("chunk80_bm25") \
        #system-id("chunk80_bm25plus") #h(8pt)
        #system-id("chunk80_pivoted")
      ],
      [chunk120], [
        #system-id("chunk120_boolean") #h(8pt)
        #system-id("chunk120_tfidf") #h(8pt)
        #system-id("chunk120_bm25") \
        #system-id("chunk120_bm25plus") #h(8pt)
        #system-id("chunk120_pivoted")
      ],
      [chunk200], [
        #system-id("chunk200_boolean") #h(8pt)
        #system-id("chunk200_tfidf") #h(8pt)
        #system-id("chunk200_bm25") \
        #system-id("chunk200_bm25plus") #h(8pt)
        #system-id("chunk200_pivoted")
      ],
    )
  ],
  caption: [Frozen 20-system evaluation matrix.],
)

The matrix combines four segmentation families with five ranking models, totaling 20 systems.

== Relevance Judgments and Qrels Construction

Relevance judgments were produced through pooling, following standard TREC practice @voorhees2001philosophy @vu2006machine. The top-10 results from all 20 systems were pooled into one candidate set. After de-duplication, this produced 4,263 judged candidate rows across 60 queries. Each pooled item was assigned a relevance label. The final label distribution was 1,202 items at relevance 0, 728 at relevance 1, 887 at relevance 2, and 1,446 at relevance 3.

Of course, pooling has the obvious limitation: anything not residing in the top-10 from the pooled systems is unjudged. This is acceptable here because the goal is evaluation within the 20-system matrix, not the absolute recall over the entire corpus.

The annotated pool was converted into TREC qrels using Seekdown’s `qrels` command, and effectiveness metrics were computed through the standard run-file/qrels workflow.

== Metrics

Effectiveness is reported using `MAP`, `MRR`, `P-at-10`, `Recall-at-10`, and `nDCG-at-10`. `nDCG-at-10` is treated as the primary metric because judgments are graded and the intended use case is top-heavy @jarvelin2002cumulated.

Scalability is reported using build time, mean latency, median latency, `p95` latency, total wall time, and `QPS`. Median latency is prioritized as it better represents typical query behaviour.

== Scalability and Performance Experiments

Performance experiments were run across five deterministic corpus sizes: 
- `subset_2500`,
- `subset_5000`,
- `subset_7500`,
- `subset_10000`,
- `full_corpus (11088)`.

For each system and corpus size, benchmarks recorded index build time and repeated query execution over the 60-query set. Each benchmark used 20 repetitions, yielding 1,200 query executions per system and size pair. 

The main objective of this experiment was to measure how different segmentation strategies affect index size and query processing cost as the corpus scales.

#pagebreak()
= Results and Discussions

The pattern is consistent across the results: chunking improves retrieval quality, while smaller chunks cost more at query time. 

== Retrieval Effectiveness

#figure(
  image("assets/effectiveness_matrix_ndcg.svg", width: 100%),
  caption: [nDCG-at-10 across all 20 systems],
)

The best `nDCG-at-10` was achieved by `chunk120_bm25plus` at *0.7820*. It was followed closely by `chunk120_bm25` and `chunk200_bm25` (both 0.7710), then `chunk200_bm25plus` (0.7695) and `chunk80_bm25plus` (0.7692). The margins between the best probabilistic chunked systems exist, but are small. The larger gap is between chunked and section-based indexing.

#figure(
  text(size: 6.9pt)[
    #paper-table(
      columns: (1.72fr, 0.72fr, 0.72fr, 0.72fr, 0.82fr, 0.72fr, 0.78fr),
      align: (left + horizon, right + horizon, right + horizon, right + horizon, right + horizon, right + horizon, right + horizon),
      table.header([System], [MAP], [MRR], [P10], [nDCG], [R10], [Med.]),
      [#system-id("c120_bm25+")], [0.1718], [0.9500], [0.8350], [*0.7820*], [0.1878], [7.93],
      [#system-id("c120_bm25")], [0.1681], [*0.9569*], [0.8333], [0.7710], [0.1815], [7.91],
      [#system-id("c200_bm25")], [0.1680], [0.9519], [0.8350], [0.7710], [0.1851], [4.24],
      [#system-id("c200_bm25+")], [0.1656], [0.9489], [0.8283], [0.7695], [0.1826], [4.02],
      [#system-id("c80_bm25+")], [*0.1738*], [0.9431], [*0.8400*], [0.7692], [*0.1911*], [12.13],
      [#system-id("sec_bm25")], [0.1593], [0.9583], [0.7717], [0.5405], [0.1725], [*3.96*],
    )
  ],
  caption: [Most effective systems and the strongest section baseline.],
)

#figure(
  image("assets/effectiveness_ranked_ndcg.svg", width: 100%),
  caption: [Ranked full-system view of nDCG-at-10.],
)

The average `nDCG-at-10` for `section_*` systems was 0.4671. `chunk80`, `chunk120`, and `chunk200` averaged 0.7270, 0.7383, and 0.7361. In this benchmark, authored sections were simply too broad to be good retrieval units.

Mean `nDCG-at-10` across all segmentations was 0.5832 for `Boolean`, 0.6441 for `TF-IDF`, 0.7111 for `BM25`, 0.7098 for `BM25+`, and 0.6875 for `Pivoted Length Normalization`. `Boolean` is too rigid, `TF-IDF` is a solid improvement, but the probabilistic methods lead.

Chunk size also matters. `chunk120` is the strongest family overall (0.7383 mean `nDCG-at-10`), with `chunk200` essentially tied (0.7361). `chunk80` falls behind slightly in quality, but much more in terms of latency.

One interesting finding is that different metrics have different winners. `chunk80_bm25plus` achieved the highest `MAP` (0.1738), the highest `P-at-10` (0.8400), and the highest `Recall-at-10` (0.1911), but it did not achieve the best `nDCG-at-10`. The summary is that `chunk80` surfaces many relevant items, but `chunk120` orders the highly relevant items better.

== Scalability and Query Performance

#figure(
  image("assets/corpus_size_vs_median_latency.svg", width: 100%),
  caption: [Average query latency vs corpus size.],
)

The results align with the expected intuition: finer segmentation produces more retrieval units, which increases query-time work.

On the full corpus, the average median latency of the `section_*` family was 4.25 ms. `chunk200_*` was similar at 4.43 ms. `chunk120_*` grew to 8.43 ms, and `chunk80_*` rose sharply to 14.94 ms.

Throughput follows the same ordering. The fastest full-corpus system was `section_bm25plus` at 314.14 `QPS`, while the slowest family overall was `chunk80_*`.

Build time also shows a similar pattern. Full-corpus section systems built in roughly [1.06,1.11] seconds. Chunked systems clustered around [1.37,1.43] seconds, with `chunk80_pivoted` reaching 1.65 seconds. The key point is that chunk-size effects are much more visible at query time than at build time.

#figure(
  text(size: 7.3pt)[
    #paper-table(
      columns: (1fr, 1.45fr, 0.9fr, 0.9fr, 0.8fr, 0.85fr),
      align: (left + horizon, left + horizon, right + horizon, right + horizon, right + horizon, right + horizon),
      table.header([Seg.], [System], [Build ms], [Median ms], [P95 ms], [QPS]),
      [section], [#system-id("sec_bm25+")], [1092.06], [*3.08*], [*5.31*], [*314.14*],
      [chunk80], [#system-id("c80_bm25+")], [1432.19], [12.13], [15.67], [86.82],
      [chunk120], [#system-id("c120_bm25+")], [1406.34], [7.93], [12.42], [127.55],
      [chunk200], [#system-id("c200_bm25")], [*1376.78*], [4.24], [6.79], [237.39],
    )
  ],
  caption: [Full-corpus performance for the strongest systems in each segmentation family.],
)

#figure(
  image("assets/corpus_size_vs_qps.svg", width: 100%),
  caption: [QPS vs corpus size],
)

#figure(
  image("assets/corpus_size_vs_p95_latency.svg", width: 100%),
  caption: [P95 latency vs corpus size],
)

#figure(
  image("assets/corpus_size_vs_build_time.svg", width: 100%),
  caption: [Index build time vs corpus size],
)

The growth curves present an interesting finding: not all chunking is equally expensive. `chunk200_*` matches section systems surprisingly closely, while `chunk80_*` separates quickly as the corpus grows.

== Quality-Performance Trade-offs

#figure(
  image("assets/pareto_frontier_quality_speed.svg", width: 100%),
  caption: [Pareto frontier on the full corpus using nDCG-at-10 and median latency.],
)

Figure 7 shows the trade-off as a Pareto frontier. The frontier contains five systems: `section_bm25plus`, `section_bm25`, `chunk200_bm25plus`, `chunk200_bm25`, and `chunk120_bm25plus`. The trade-off shows: 

- If the only goal is top-rank effectiveness, `chunk120_bm25plus` is the clear winner.
- If speed dominates and quality can drop significantly, `section_bm25plus` is the fastest configuration.
- If both matter, `chunk200_bm25` is the most balanced point in the matrix.

`chunk200_bm25` reaches the same `nDCG-at-10` as `chunk120_bm25` and trails `chunk120_bm25plus` by only *0.0110* `nDCG-at-10`, while nearly halving median latency (*4.24* ms vs *7.93* ms) and boosting throughput (*237.39* `QPS` vs *127.55* `QPS`).

So the summary is pretty straightforward: `chunk120` squeezes out the bit of quality, but `chunk200` buys most of that quality at a much lower runtime cost, making it the practical trade-off.
#figure(
  image("assets/radar_chart_top_systems.svg", width: 82%),
  caption: [Comparison of the top five systems across the metrics],
)


== Key Findings Summary

Thus, the five research questions can be answered directly:

- *RQ1:* Probabilistic ranking models were strongest. `Boolean` retrieval underperformed, `TF-IDF` improved on it, and `BM25`/`BM25+` dominated.
- *RQ2:* `section` segmentation did not beat chunking. It was consistently weaker on effectiveness.
- *RQ3:* `chunk120` was best on pure effectiveness, with `chunk200` coming extremely close.
- *RQ4:* Smaller chunks increased query latency and reduced throughput. `chunk200` scaled gently; `chunk80` did not.
- *RQ5:* `chunk120_bm25plus` is the best sheer quality system, but `chunk200_bm25` is the better practical trade-off in terms of quality to performance.

= Limitations

This study has some limitations. First, the corpus is domain-specific; it consists of only technical documentation, not general web retrieval. Second, the query set contains 60 queries, which is enough for a small controlled comparison but lacks in comparison to industrial benchmarks. Third, qrels were built through pooling, so documents outside the pool were not judged and are treated as non-relevant. Although this is standard TREC practice @voorhees2001philosophy, it does mean that the recall measurements are bound only to the pooled candidate space. Fourth, the comparison is lexical only. No dense retriever, hybrid retriever, or neural reranker is included, so the results should be taken as a comparison among classical retrieval techniques rather than a claim about beating modern neural systems.

= Conclusion

This paper evaluated 20 Markdown retrieval systems formed by combining four segmentation strategies with five classical ranking models. The results show that lexical retrieval still works well for local technical-document search, but the indexing unit does most of the real work.

The strongest system by effectiveness was `chunk120_bm25plus` (`nDCG-at-10` = *0.7820*). However, the main conclusion is about trade-offs rather than a single winner. Chunking consistently outperformed section-based indexing on effectiveness, and chunk size controlled most of the runtime.

From a practical standpoint, `chunk200_bm25` is the best default. It gives up very little effectiveness compared with the top system while still staying closer to section-level in terms of latency and throughput. Thus, we can conclude that better length normalization helps, but segmentation is where the large gains and the large costs actually come from.

#bibliography("refs.bib")
