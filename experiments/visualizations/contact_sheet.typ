#set page(paper: "a4", flipped: true, margin: 10mm)
#set text(size: 9pt)
#set par(justify: false, leading: 0.9em)

#let charts = (
  (
    title: "effectiveness matrix",
    path: "svg/effectiveness_matrix_ndcg.svg",
  ),
  (
    title: "effectiveness ranked",
    path: "svg/effectiveness_ranked_ndcg.svg",
  ),
  (
    title: "corpus size vs median latency",
    path: "svg/corpus_size_vs_median_latency.svg",
  ),
  (
    title: "corpus size vs qps",
    path: "svg/corpus_size_vs_qps.svg",
  ),
  (
    title: "corpus size vs p95 latency",
    path: "svg/corpus_size_vs_p95_latency.svg",
  ),
  (
    title: "corpus size vs build time",
    path: "svg/corpus_size_vs_build_time.svg",
  ),
  (
    title: "pareto frontier",
    path: "svg/pareto_frontier_quality_speed.svg",
  ),
  (
    title: "radar chart top systems",
    path: "svg/radar_chart_top_systems.svg",
  ),
)

#grid(
  columns: 2,
  gutter: 8mm,
  ..charts.map(chart => block(
    inset: 0pt,
    breakable: false,
    [
      #text(weight: "bold", size: 8.5pt)[#chart.title]
      #v(3mm)
      #image(chart.path, width: 100%)
    ],
  )),
)
