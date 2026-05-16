use crate::index::types::{Index, TermId};
use crate::ranking::{deduplicate_query_term_ids, ScoredDocument};

// Classical TF-IDF scoring with log-scaled term frequency.
pub fn search(index: &Index, query_term_ids: &[TermId]) -> Vec<ScoredDocument> {
    let query_term_ids = deduplicate_query_term_ids(query_term_ids);
    let mut scores = vec![0.0_f32; index.document_count()];
    let mut seen = Vec::new();

    for term_id in query_term_ids {
        let df = index.document_frequency(term_id).unwrap_or(0) as f32;
        if df == 0.0 {
            continue;
        }

        let n = index.stats.document_count as f32;
        let idf = ((n + 1.0) / (df + 1.0)).ln() + 1.0;
        let postings = &index.postings[term_id as usize];

        for (&doc_id, &term_freq) in postings.doc_ids.iter().zip(&postings.term_freqs) {
            let entry = &mut scores[doc_id as usize];
            if *entry == 0.0 {
                seen.push(doc_id);
            }

            // Repeated terms help, but with diminishing returns.
            let tf = 1.0 + (term_freq as f32).ln();
            *entry += tf * idf;
        }
    }

    finalize_results(index, scores, seen)
}

fn finalize_results(index: &Index, scores: Vec<f32>, seen: Vec<u32>) -> Vec<ScoredDocument> {
    let mut results = Vec::with_capacity(seen.len());
    for doc_id in seen {
        results.push(ScoredDocument {
            doc_id,
            score: scores[doc_id as usize],
        });
    }

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
    fn search_should_reward_higher_term_frequency() {
        let index = build_index(vec![
            LoadedDocument {
                key: String::from("a"),
                path: String::from("a.md"),
                title: String::from("A"),
                body: String::from("rust rust rust install"),
                start_line: 1,
                end_line: 1,
            },
            LoadedDocument {
                key: String::from("b"),
                path: String::from("b.md"),
                title: String::from("B"),
                body: String::from("rust install"),
                start_line: 1,
                end_line: 1,
            },
        ]);

        let results = search(&index, &[index.term_id("rust").unwrap()]);
        assert_eq!(results[0].doc_id, 0);
    }
}
