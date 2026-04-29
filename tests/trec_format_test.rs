use std::fs;
use std::path::Path;

use seekdown::eval::runner::generate_run_file;
use seekdown::ranking::RankingModel;
use seekdown::query::LoadMode;

#[test]
fn generate_run_file_should_write_trec_output() {
    let out_path = Path::new("target/test-output.run");
    let rows = generate_run_file(
        Path::new("test_corpus"),
        Path::new("test_corpus/queries.csv"),
        out_path,
        LoadMode::Section,
        RankingModel::Bm25,
        3,
        100,
        "seekdown_test",
    )
    .unwrap();

    let content = fs::read_to_string(out_path).unwrap();
    assert!(rows > 0);
    assert!(content.contains("Q0"));
    assert!(content.contains("seekdown_test"));
    fs::remove_file(out_path).unwrap();
}
