use std::io;
use std::path::Path;

use crate::index::builder::build_index;
use crate::index::types::{Index, TermId};
use crate::load::chunk::ChunkLoader;
use crate::load::section::SectionLoader;
use crate::load::DocumentLoader;
use crate::ranking::bm25;
use crate::ranking::bm25_plus;
use crate::ranking::boolean;
use crate::ranking::pivoted;
use crate::ranking::tfidf;
use crate::ranking::{RankingModel, ScoredDocument};
use crate::tokenize::tokenize;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum LoadMode {
    Section,
    Chunk,
}

impl LoadMode {
    pub fn parse(input: &str) -> Option<Self> {
        match input {
            "section" => Some(Self::Section),
            "chunk" => Some(Self::Chunk),
            _ => None,
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SearchOptions<'a> {
    pub dataset_dir: &'a Path,
    pub query: &'a str,
    pub mode: LoadMode,
    pub ranking_model: RankingModel,
    pub top_k: usize,
    pub chunk_size: usize,
}

#[derive(Debug, Clone, PartialEq)]
pub struct SearchResult {
    pub key: String,
    pub path: String,
    pub title: String,
    pub score: f32,
    pub start_line: u32,
    pub end_line: u32,
    pub snippet: String,
}

pub fn build_search_index(dataset_dir: &Path, mode: LoadMode, chunk_size: usize) -> io::Result<Index> {
    let documents = match mode {
        LoadMode::Section => SectionLoader::new(dataset_dir).load()?,
        LoadMode::Chunk => ChunkLoader::new(dataset_dir, chunk_size).load()?,
    };

    Ok(build_index(documents))
}

pub fn search_dataset(options: &SearchOptions<'_>) -> io::Result<Vec<SearchResult>> {
    let index = build_search_index(options.dataset_dir, options.mode, options.chunk_size)?;
    Ok(search_index(&index, options.query, options.ranking_model, options.top_k))
}

pub fn search_index(index: &Index, query: &str, ranking_model: RankingModel, top_k: usize) -> Vec<SearchResult> {
    let query_term_ids = resolve_query_term_ids(index, query);
    execute_search(index, &query_term_ids, ranking_model, top_k)
}

fn resolve_query_term_ids(index: &Index, query: &str) -> Vec<TermId> {
    tokenize(query)
        .into_iter()
        .filter_map(|term| index.term_id(&term))
        .collect()
}

fn execute_search(
    index: &Index,
    query_term_ids: &[TermId],
    ranking_model: RankingModel,
    top_k: usize,
) -> Vec<SearchResult> {
    let scored = match ranking_model {
        RankingModel::Boolean => boolean::search(index, query_term_ids),
        RankingModel::TfIdf => tfidf::search(index, query_term_ids),
        RankingModel::Bm25 => bm25::search(index, query_term_ids),
        RankingModel::Bm25Plus => bm25_plus::search(index, query_term_ids),
        RankingModel::Pivoted => pivoted::search(index, query_term_ids),
    };

    scored
        .into_iter()
        .take(top_k.max(1))
        .map(|scored_doc| map_result(index, scored_doc))
        .collect()
}

fn map_result(index: &Index, scored_doc: ScoredDocument) -> SearchResult {
    let document = &index.documents[scored_doc.doc_id as usize];
    SearchResult {
        key: document.key.clone(),
        path: document.path.clone(),
        title: document.title.clone(),
        score: scored_doc.score,
        start_line: document.start_line,
        end_line: document.end_line,
        snippet: first_snippet_line(&document.body),
    }
}

fn first_snippet_line(body: &str) -> String {
    body.lines()
        .find(|line| !line.trim().is_empty())
        .map(|line| line.trim().to_string())
        .unwrap_or_default()
}
