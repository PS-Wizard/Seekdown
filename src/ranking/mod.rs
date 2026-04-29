pub mod bm25;
pub mod bm25_plus;
pub mod boolean;
pub mod pivoted;
pub mod tfidf;

use crate::index::types::TermId;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum RankingModel {
    Boolean,
    TfIdf,
    Bm25,
    Bm25Plus,
    Pivoted,
}

impl RankingModel {
    pub fn parse(input: &str) -> Option<Self> {
        match input {
            "boolean" => Some(Self::Boolean),
            "tfidf" => Some(Self::TfIdf),
            "bm25" => Some(Self::Bm25),
            "bm25plus" | "bm25+" => Some(Self::Bm25Plus),
            "pivoted" => Some(Self::Pivoted),
            _ => None,
        }
    }
}

#[derive(Debug, Clone, PartialEq)]
pub struct ScoredDocument {
    pub doc_id: u32,
    pub score: f32,
}

pub fn deduplicate_query_term_ids(query_term_ids: &[TermId]) -> Vec<TermId> {
    let mut unique = query_term_ids.to_vec();
    unique.sort_unstable();
    unique.dedup();
    unique
}
