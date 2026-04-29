use std::io;
use std::path::Path;
use std::time::Instant;

use crate::eval::trec::read_queries;
use crate::query::{build_search_index, search_index, LoadMode};
use crate::ranking::RankingModel;

#[derive(Debug, Clone, PartialEq)]
pub struct BenchmarkSummary {
    pub documents: usize,
    pub queries: usize,
    pub repeat: usize,
    pub total_runs: usize,
    pub build_ms: f64,
    pub mean_ms: f64,
    pub median_ms: f64,
    pub p95_ms: f64,
    pub qps: f64,
}

pub fn benchmark_queries(
    dataset_dir: &Path,
    queries_path: &Path,
    mode: LoadMode,
    ranking_model: RankingModel,
    top_k: usize,
    chunk_size: usize,
    repeat: usize,
) -> io::Result<BenchmarkSummary> {
    let build_start = Instant::now();
    let index = build_search_index(dataset_dir, mode, chunk_size)?;
    let build_ms = build_start.elapsed().as_secs_f64() * 1000.0;
    let documents = index.documents.len();
    let queries = read_queries(queries_path)?;
    let safe_repeat = repeat.max(1);
    let mut timings_ms = Vec::with_capacity(queries.len() * safe_repeat);

    for _ in 0..safe_repeat {
        for query in &queries {
            let start = Instant::now();
            let _results = search_index(&index, &query.query_text, ranking_model, top_k);
            timings_ms.push(start.elapsed().as_secs_f64() * 1000.0);
        }
    }

    timings_ms.sort_by(|a, b| a.total_cmp(b));
    let total_runs = timings_ms.len();
    let total_ms: f64 = timings_ms.iter().sum();
    let mean_ms = if total_runs == 0 { 0.0 } else { total_ms / total_runs as f64 };
    let median_ms = percentile(&timings_ms, 0.5);
    let p95_ms = percentile(&timings_ms, 0.95);
    let qps = if total_ms == 0.0 {
        0.0
    } else {
        (total_runs as f64) / (total_ms / 1000.0)
    };

    Ok(BenchmarkSummary {
        documents,
        queries: queries.len(),
        repeat: safe_repeat,
        total_runs,
        build_ms,
        mean_ms,
        median_ms,
        p95_ms,
        qps,
    })
}

fn percentile(values: &[f64], p: f64) -> f64 {
    if values.is_empty() {
        return 0.0;
    }

    let index = ((values.len() - 1) as f64 * p).round() as usize;
    values[index]
}
