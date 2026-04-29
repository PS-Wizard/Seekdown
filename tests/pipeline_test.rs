use std::path::Path;

use seekdown::query::{build_search_index, search_dataset, search_index, LoadMode, SearchOptions};
use seekdown::ranking::RankingModel;

#[test]
fn search_dataset_should_find_installation_section_first() {
    let results = search_dataset(&SearchOptions {
        dataset_dir: Path::new("test_corpus"),
        query: "install cargo",
        mode: LoadMode::Section,
        ranking_model: RankingModel::Boolean,
        top_k: 3,
        chunk_size: 100,
    })
    .unwrap();

    assert!(results[0].key.contains("installation"));
}

#[test]
fn build_search_index_should_separate_indexing_from_querying() {
    let index = build_search_index(Path::new("test_corpus"), LoadMode::Section, 100).unwrap();
    let results = search_index(&index, "query latency", RankingModel::Boolean, 3);

    assert_eq!(index.stats.document_count as usize, index.documents.len());
    assert!(!results.is_empty());
}

#[test]
fn search_index_should_support_all_ranking_models() {
    let index = build_search_index(Path::new("test_corpus"), LoadMode::Section, 100).unwrap();

    for model in [
        RankingModel::TfIdf,
        RankingModel::Bm25,
        RankingModel::Bm25Plus,
        RankingModel::Pivoted,
    ] {
        let results = search_index(&index, "install cargo", model, 3);
        assert!(results[0].key.contains("installation"));
    }
}
