use std::collections::HashMap;

use crate::index::types::{CorpusStats, DocumentMeta, Index, Lexicon, PostingList, TermId};
use crate::load::LoadedDocument;
use crate::tokenize::tokenize;

pub fn build_index(documents: Vec<LoadedDocument>) -> Index {
    let mut stored_documents = Vec::with_capacity(documents.len());
    let mut doc_lengths = Vec::with_capacity(documents.len());
    let mut term_to_id: HashMap<String, TermId> = HashMap::new();
    let mut terms = Vec::new();
    let mut postings_acc: Vec<Vec<(u32, u32)>> = Vec::new();
    let mut document_frequencies = Vec::new();
    let mut total_terms = 0_u64;

    for document in documents {
        let tokens = tokenize(&document.body);
        if tokens.is_empty() {
            continue;
        }

        let mut local_freqs: HashMap<TermId, u32> = HashMap::new();
        for token in &tokens {
            let term_id = match term_to_id.get(token) {
                Some(term_id) => *term_id,
                None => {
                    let next = terms.len() as TermId;
                    term_to_id.insert(token.clone(), next);
                    terms.push(token.clone());
                    postings_acc.push(Vec::new());
                    document_frequencies.push(0);
                    next
                }
            };

            *local_freqs.entry(term_id).or_insert(0) += 1;
        }

        let stored_doc_id = stored_documents.len() as u32;
        for (term_id, term_freq) in local_freqs {
            postings_acc[term_id as usize].push((stored_doc_id, term_freq));
            document_frequencies[term_id as usize] += 1;
        }

        let doc_length = tokens.len() as u32;
        total_terms += u64::from(doc_length);
        doc_lengths.push(doc_length);
        stored_documents.push(DocumentMeta::from(document));
    }

    let postings = postings_acc
        .into_iter()
        .map(|posting_pairs| {
            let mut doc_ids = Vec::with_capacity(posting_pairs.len());
            let mut term_freqs = Vec::with_capacity(posting_pairs.len());
            for (doc_id, term_freq) in posting_pairs {
                doc_ids.push(doc_id);
                term_freqs.push(term_freq);
            }
            PostingList { doc_ids, term_freqs }
        })
        .collect();

    let document_count = stored_documents.len() as u32;
    let average_doc_length = if document_count == 0 {
        0.0
    } else {
        total_terms as f32 / document_count as f32
    };

    Index {
        documents: stored_documents,
        doc_lengths,
        lexicon: Lexicon { terms, term_to_id },
        postings,
        stats: CorpusStats {
            document_count,
            total_terms,
            average_doc_length,
            document_frequencies,
        },
    }
}

#[cfg(test)]
mod tests {
    use crate::load::LoadedDocument;

    use super::build_index;

    #[test]
    fn build_index_should_count_term_frequencies() {
        let index = build_index(vec![LoadedDocument {
            key: String::from("doc#1"),
            path: String::from("doc.md"),
            title: String::from("Doc"),
            body: String::from("rust rust install"),
            start_line: 1,
            end_line: 1,
        }]);

        let rust_id = index.term_id("rust").unwrap();
        assert_eq!(index.postings[rust_id as usize].term_freqs, [2]);
    }

    #[test]
    fn build_index_should_store_document_frequencies_and_average_length() {
        let index = build_index(vec![
            LoadedDocument {
                key: String::from("a"),
                path: String::from("a.md"),
                title: String::from("A"),
                body: String::from("rust install"),
                start_line: 1,
                end_line: 1,
            },
            LoadedDocument {
                key: String::from("b"),
                path: String::from("b.md"),
                title: String::from("B"),
                body: String::from("rust cli search"),
                start_line: 1,
                end_line: 1,
            },
        ]);

        let rust_id = index.term_id("rust").unwrap();
        let install_id = index.term_id("install").unwrap();

        assert_eq!(index.document_frequency(rust_id), Some(2));
        assert_eq!(index.document_frequency(install_id), Some(1));
        assert!((index.stats.average_doc_length - 2.5).abs() < 1e-6);
    }
}
