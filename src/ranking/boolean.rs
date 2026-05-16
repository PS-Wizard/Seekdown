use crate::index::types::{Index, TermId};
use crate::ranking::{deduplicate_query_term_ids, ScoredDocument};

// Boolean baseline used here as term-overlap scoring.
//
// A document gains one point for each distinct query term it contains.
pub fn search(index: &Index, query_term_ids: &[TermId]) -> Vec<ScoredDocument> {
    let query_term_ids = deduplicate_query_term_ids(query_term_ids);
    let mut scores = vec![0_u32; index.document_count()];
    let mut seen = Vec::new();

    for term_id in query_term_ids {
        let postings = &index.postings[term_id as usize];
        for &doc_id in &postings.doc_ids {
            let entry = &mut scores[doc_id as usize];
            if *entry == 0 {
                seen.push(doc_id);
            }
            *entry += 1;
        }
    }

    let mut results = Vec::with_capacity(seen.len());
    for doc_id in seen {
        results.push(ScoredDocument {
            doc_id,
            score: scores[doc_id as usize] as f32,
        });
    }

    // Tie-breaks are stable across all models: shorter doc first, then key.
    results.sort_by(|left, right| {
        right
            .score
            .total_cmp(&left.score)
            .then_with(|| index.doc_lengths[left.doc_id as usize].cmp(&index.doc_lengths[right.doc_id as usize]))
            .then_with(|| index.documents[left.doc_id as usize].key.cmp(&index.documents[right.doc_id as usize].key))
    });
    results
}

#[cfg(test)]
mod tests {
    use crate::index::builder::build_index;
    use crate::load::LoadedDocument;

    use super::search;

    #[test]
    fn search_should_rank_more_matches_higher() {
        let index = build_index(vec![
            LoadedDocument {
                key: String::from("a"),
                path: String::from("a.md"),
                title: String::from("A"),
                body: String::from("rust install cargo"),
                start_line: 1,
                end_line: 1,
            },
            LoadedDocument {
                key: String::from("b"),
                path: String::from("b.md"),
                title: String::from("B"),
                body: String::from("rust"),
                start_line: 1,
                end_line: 1,
            },
        ]);

        let query_term_ids = [index.term_id("rust").unwrap(), index.term_id("install").unwrap()];
        let results = search(&index, &query_term_ids);
        assert_eq!(results[0].doc_id, 0);
    }
}
