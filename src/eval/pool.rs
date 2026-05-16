use std::collections::{BTreeMap, BTreeSet};
use std::fs;
use std::io;
use std::path::Path;

use crate::eval::trec::read_queries;
use crate::query::{build_search_index, search_index, LoadMode, SearchResult};
use crate::ranking::RankingModel;

#[derive(Debug, Clone, PartialEq)]
pub struct PoolSpec {
    pub mode: LoadMode,
    pub ranking_model: RankingModel,
}

#[derive(Debug, Clone, PartialEq)]
pub struct PoolRow {
    pub query_id: String,
    pub query_text: String,
    pub doc_id: String,
    pub path: String,
    pub title: String,
    pub score: f32,
    pub snippet: String,
    pub sources: Vec<String>,
}

// Build one pooled candidate CSV from many systems.
//
// The pool deduplicates by `(query_id, doc_id)`, because relevance is judged per
// query-document pair, not per model score.
pub fn generate_pool(
    dataset_dir: &Path,
    queries_path: &Path,
    out_path: &Path,
    specs: &[PoolSpec],
    top_k: usize,
    chunk_size: usize,
) -> io::Result<usize> {
    let queries = read_queries(queries_path)?;
    let mut indexes: BTreeMap<&'static str, crate::index::types::Index> = BTreeMap::new();
    let mut pool: BTreeMap<(String, String), PoolRow> = BTreeMap::new();

    for spec in specs {
        // Pooling may request many systems, but there are only two actual loader
        // modes. Reuse the built index for each mode instead of rebuilding it for
        // every ranking model.
        let mode_key = match spec.mode {
            LoadMode::Section => "section",
            LoadMode::Chunk => "chunk",
        };

        if !indexes.contains_key(mode_key) {
            let index = build_search_index(dataset_dir, spec.mode, chunk_size)?;
            indexes.insert(mode_key, index);
        }

        let index = indexes.get(mode_key).expect("index exists");
        let source_name = format!("{}:{}", mode_key, model_name(spec.ranking_model));

        for query in &queries {
            let results = search_index(index, &query.query_text, spec.ranking_model, top_k);
            append_results(&mut pool, query.query_id.as_str(), query.query_text.as_str(), &source_name, results);
        }
    }

    let rows: Vec<PoolRow> = pool.into_values().collect();
    write_pool_csv(out_path, &rows)?;
    Ok(rows.len())
}

// Merge one system's top-k results into the shared candidate pool.
fn append_results(
    pool: &mut BTreeMap<(String, String), PoolRow>,
    query_id: &str,
    query_text: &str,
    source_name: &str,
    results: Vec<SearchResult>,
) {
    for result in results {
        let key = (query_id.to_string(), result.key.clone());
        let entry = pool.entry(key).or_insert_with(|| PoolRow {
            query_id: query_id.to_string(),
            query_text: query_text.to_string(),
            doc_id: result.key.clone(),
            path: result.path.clone(),
            title: result.title.clone(),
            score: result.score,
            snippet: result.snippet.clone(),
            sources: Vec::new(),
        });

        // Keep the maximum score seen across contributing systems purely as a
        // representative value for the pooled CSV. It is not used for evaluation.
        if result.score > entry.score {
            entry.score = result.score;
        }

        if !entry.sources.iter().any(|source| source == source_name) {
            entry.sources.push(source_name.to_string());
            entry.sources.sort();
        }
    }
}

// Write the human-facing annotation sheet. The trailing `relevance` column is
// intentionally left blank for manual judgment.
pub fn write_pool_csv(path: &Path, rows: &[PoolRow]) -> io::Result<()> {
    let mut output = String::from(
        "query_id,query_text,doc_id,path,title,score,snippet,sources,relevance\n",
    );

    for row in rows {
        output.push_str(&csv_escape(&row.query_id));
        output.push(',');
        output.push_str(&csv_escape(&row.query_text));
        output.push(',');
        output.push_str(&csv_escape(&row.doc_id));
        output.push(',');
        output.push_str(&csv_escape(&row.path));
        output.push(',');
        output.push_str(&csv_escape(&row.title));
        output.push(',');
        output.push_str(&csv_escape(&format!("{:.6}", row.score)));
        output.push(',');
        output.push_str(&csv_escape(&row.snippet));
        output.push(',');
        output.push_str(&csv_escape(&row.sources.join("|")));
        output.push(',');
        output.push_str("\n");
    }

    fs::write(path, output)
}

// Expand comma-separated CLI lists like `section,chunk` and `bm25,tfidf`
// into the concrete system matrix to run.
pub fn parse_specs(modes: &str, models: &str) -> Result<Vec<PoolSpec>, String> {
    let mut parsed_modes = Vec::new();
    for mode in split_list(modes) {
        parsed_modes.push(LoadMode::parse(mode).ok_or_else(|| format!("invalid mode: {mode}"))?);
    }

    let mut parsed_models = Vec::new();
    for model in split_list(models) {
        parsed_models.push(
            RankingModel::parse(model).ok_or_else(|| format!("invalid model: {model}"))?,
        );
    }

    let mut seen = BTreeSet::new();
    let mut specs = Vec::new();
    for mode in parsed_modes {
        for model in &parsed_models {
            let key = (mode as u8, *model as u8);
            if seen.insert(key) {
                specs.push(PoolSpec {
                    mode,
                    ranking_model: *model,
                });
            }
        }
    }

    Ok(specs)
}

fn split_list(input: &str) -> impl Iterator<Item = &str> {
    input.split(',').map(str::trim).filter(|item| !item.is_empty())
}

fn model_name(model: RankingModel) -> &'static str {
    match model {
        RankingModel::Boolean => "boolean",
        RankingModel::TfIdf => "tfidf",
        RankingModel::Bm25 => "bm25",
        RankingModel::Bm25Plus => "bm25plus",
        RankingModel::Pivoted => "pivoted",
    }
}

fn csv_escape(input: &str) -> String {
    let needs_quotes = input.contains(',') || input.contains('"') || input.contains('\n');
    if !needs_quotes {
        return input.to_string();
    }

    let escaped = input.replace('"', "\"\"");
    format!("\"{escaped}\"")
}
