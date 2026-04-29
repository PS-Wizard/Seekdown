use std::fs;
use std::path::Path;

use seekdown::eval::pool::{generate_pool, parse_specs};
use seekdown::eval::trec::convert_pool_to_qrels;

#[test]
fn generate_pool_should_write_annotation_csv() {
    let out_path = Path::new("target/test-pool.csv");
    let specs = parse_specs("section,chunk", "boolean,bm25").unwrap();

    let rows = generate_pool(
        Path::new("test_corpus"),
        Path::new("test_corpus/queries.csv"),
        out_path,
        &specs,
        3,
        50,
    )
    .unwrap();

    let content = fs::read_to_string(out_path).unwrap();
    assert!(rows > 0);
    assert!(content.contains("sources"));
    assert!(content.contains("relevance"));
    fs::remove_file(out_path).unwrap();
}

#[test]
fn convert_pool_to_qrels_should_emit_judged_rows() {
    let pool_path = Path::new("target/annotated-pool.csv");
    let qrels_path = Path::new("target/generated-qrels.txt");

    fs::write(
        pool_path,
        "query_id,query_text,doc_id,path,title,score,snippet,sources,relevance\nq001,install cargo,getting-started.md#getting-started/installation,getting-started.md,Installation,5.4,Install the binary,section:bm25|chunk:boolean,3\nq001,install cargo,api-reference.md#api-reference,api-reference.md,API Reference,1.2,The command line interface,section:boolean,\n",
    )
    .unwrap();

    let written = convert_pool_to_qrels(pool_path, qrels_path).unwrap();
    let content = fs::read_to_string(qrels_path).unwrap();

    assert_eq!(written, 1);
    assert_eq!(content, "q001 0 getting-started.md#getting-started/installation 3\n");

    fs::remove_file(pool_path).unwrap();
    fs::remove_file(qrels_path).unwrap();
}
