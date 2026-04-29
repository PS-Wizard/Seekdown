use std::io;
use std::path::Path;

use crate::eval::trec::{read_queries, write_run_file, QueryInput, RunRow};
use crate::query::{build_search_index, search_index, LoadMode};
use crate::ranking::RankingModel;

pub fn generate_run_file(
    dataset_dir: &Path,
    queries_path: &Path,
    out_path: &Path,
    mode: LoadMode,
    ranking_model: RankingModel,
    top_k: usize,
    chunk_size: usize,
    run_name: &str,
) -> io::Result<usize> {
    let index = build_search_index(dataset_dir, mode, chunk_size)?;
    let queries = read_queries(queries_path)?;
    let mut rows = Vec::new();

    for query in queries {
        append_query_results(&mut rows, &index, &query, ranking_model, top_k, run_name);
    }

    write_run_file(out_path, &rows)?;
    Ok(rows.len())
}

fn append_query_results(
    rows: &mut Vec<RunRow>,
    index: &crate::index::types::Index,
    query: &QueryInput,
    ranking_model: RankingModel,
    top_k: usize,
    run_name: &str,
) {
    let results = search_index(index, &query.query_text, ranking_model, top_k);
    for (rank, result) in results.into_iter().enumerate() {
        rows.push(RunRow {
            query_id: query.query_id.clone(),
            doc_id: result.key,
            rank: rank + 1,
            score: result.score,
            run_name: run_name.to_string(),
        });
    }
}
