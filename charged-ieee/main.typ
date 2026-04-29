#import "@preview/charged-ieee:0.1.4": ieee

#show: ieee.with(
  title: [Evaluation of Classical Retrieval Models and Segmentation Strategies for Markdown Search],
  abstract: [
    *Target: ~180 words.*
    #lorem(180)
  ],
  authors: (
    (
      name: "Your Name",
      department: [6CS030 Big Data],
      organization: [University / School],
      location: [City, Country],
      email: "your.email@example.com",
    ),
  ),
  index-terms: (
    "information retrieval",
    "markdown search",
    "BM25",
    "document segmentation",
    "evaluation",
    "scalability",
  ),
  bibliography: bibliography("refs.bib"),
  figure-supplement: [Fig.],
)

= Introduction

*Target: ~700 words.*

#lorem(700)

== Contributions

*Target: ~140 words.*

#lorem(140)

= Related Work

*Target: ~950 words. Aim to cover at least 15 sources across classical IR, segmentation/passage retrieval, and TREC-style evaluation.*

#lorem(950)

= System Design

*Target: ~950 words.*

#lorem(140)

== Corpus Processing

*Target: ~220 words.*

#lorem(220)

== Indexing and Retrieval Models

*Target: ~300 words.*

#lorem(300)

== Query Processing and Output Format

*Target: ~200 words.*

#lorem(200)

== Implementation Notes

*Target: ~160 words.*

#lorem(160)

= Experimental Setup

*Target: ~1,050 words.*

#lorem(140)

== Evaluation Corpus and Query Set

*Target: ~220 words.*

#lorem(220)

== System Matrix

*Target: ~140 words.*

#lorem(140)

== Relevance Judgments and Qrels Construction

*Target: ~260 words.*

#lorem(260)

== Metrics

*Target: ~150 words.*

#lorem(150)

== Scalability Protocol

*Target: ~180 words.*

#lorem(180)

= Results and Discussion

*Target: ~2,050 words. This should be the largest section in the final paper.*

#lorem(140)

== Retrieval Effectiveness

*Target: ~600 words.*

#lorem(600)

== Scalability and Query Performance

*Target: ~520 words.*

#lorem(520)

== Quality--Performance Trade-offs

*Target: ~420 words.*

#lorem(420)

== Key Findings Summary

*Target: ~260 words.*

#lorem(260)

= Limitations

*Target: ~220 words.*

#lorem(220)

= Conclusion

*Target: ~260 words.*

#lorem(260)

#pagebreak()

= Writing Notes

- Keep the final paper within 10 IEEE pages including references.
- Prioritize Results and Discussion over an oversized literature survey.
- Use one main effectiveness table, one scalability table or figure, and one compact system matrix table.
- Keep references at 15+ sources, cited in IEEE numbered style.
- Write the abstract last after all tables and findings are fixed.
- If space gets tight, compress Related Work first, not Results.
