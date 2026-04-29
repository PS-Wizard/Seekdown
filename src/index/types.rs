use std::collections::HashMap;

use crate::load::LoadedDocument;

pub type DocId = u32;
pub type TermId = u32;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct PostingList {
    pub doc_ids: Vec<DocId>,
    pub term_freqs: Vec<u32>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct DocumentMeta {
    pub key: String,
    pub path: String,
    pub title: String,
    pub start_line: u32,
    pub end_line: u32,
    pub body: String,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Lexicon {
    pub terms: Vec<String>,
    pub term_to_id: HashMap<String, TermId>,
}

#[derive(Debug, Clone, PartialEq)]
pub struct CorpusStats {
    pub document_count: u32,
    pub total_terms: u64,
    pub average_doc_length: f32,
    pub document_frequencies: Vec<u32>,
}

#[derive(Debug, Clone, PartialEq)]
pub struct Index {
    pub documents: Vec<DocumentMeta>,
    pub doc_lengths: Vec<u32>,
    pub lexicon: Lexicon,
    pub postings: Vec<PostingList>,
    pub stats: CorpusStats,
}

impl Index {
    pub fn document_count(&self) -> usize {
        self.documents.len()
    }

    pub fn term_id(&self, term: &str) -> Option<TermId> {
        self.lexicon.term_to_id.get(term).copied()
    }

    pub fn term(&self, term_id: TermId) -> Option<&str> {
        self.lexicon.terms.get(term_id as usize).map(String::as_str)
    }

    pub fn document_frequency(&self, term_id: TermId) -> Option<u32> {
        self.stats.document_frequencies.get(term_id as usize).copied()
    }
}

impl From<LoadedDocument> for DocumentMeta {
    fn from(value: LoadedDocument) -> Self {
        Self {
            key: value.key,
            path: value.path,
            title: value.title,
            start_line: value.start_line,
            end_line: value.end_line,
            body: value.body,
        }
    }
}
