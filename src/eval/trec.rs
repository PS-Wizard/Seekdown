use std::fs;
use std::io;
use std::path::Path;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct QueryInput {
    pub query_id: String,
    pub query_text: String,
}

#[derive(Debug, Clone, PartialEq)]
pub struct RunRow {
    pub query_id: String,
    pub doc_id: String,
    pub rank: usize,
    pub score: f32,
    pub run_name: String,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct QrelRow {
    pub query_id: String,
    pub doc_id: String,
    pub relevance: u32,
}

// Read the benchmark query set from a tiny two-column CSV.
pub fn read_queries(path: &Path) -> io::Result<Vec<QueryInput>> {
    let content = fs::read_to_string(path)?;
    let mut queries = Vec::new();

    for (line_index, line) in content.lines().enumerate() {
        if line_index == 0 && line.trim() == "query_id,query_text" {
            continue;
        }

        let trimmed = line.trim();
        if trimmed.is_empty() {
            continue;
        }

        let Some((query_id, query_text)) = trimmed.split_once(',') else {
            return Err(io::Error::new(
                io::ErrorKind::InvalidData,
                format!("invalid query csv row: {trimmed}"),
            ));
        };

        queries.push(QueryInput {
            query_id: query_id.trim().to_string(),
            query_text: query_text.trim().to_string(),
        });
    }

    Ok(queries)
}

// Write standard TREC run lines: `query_id Q0 doc_id rank score run_name`.
pub fn write_run_file(path: &Path, rows: &[RunRow]) -> io::Result<()> {
    let mut output = String::new();
    for row in rows {
        output.push_str(&format!(
            "{} Q0 {} {} {:.6} {}\n",
            row.query_id, row.doc_id, row.rank, row.score, row.run_name
        ));
    }
    fs::write(path, output)
}

// Convert the annotated pool CSV into qrels.
//
// Human-facing fields like query text, title, snippet, and source systems are
// dropped here because `trec_eval` only needs `(query_id, doc_id, relevance)`.
pub fn convert_pool_to_qrels(pool_path: &Path, out_path: &Path) -> io::Result<usize> {
    let content = fs::read_to_string(pool_path)?;
    let mut rows = Vec::new();

    for (line_index, line) in content.lines().enumerate() {
        if line_index == 0 {
            continue;
        }

        let trimmed = line.trim();
        if trimmed.is_empty() {
            continue;
        }

        let columns = parse_csv_line(trimmed);
        if columns.len() != 9 {
            return Err(io::Error::new(
                io::ErrorKind::InvalidData,
                format!("invalid pool row column count: {trimmed}"),
            ));
        }

        let relevance = columns[8].trim();
        if relevance.is_empty() {
            continue;
        }

        let relevance_value = relevance.parse::<u32>().map_err(|_| {
            io::Error::new(
                io::ErrorKind::InvalidData,
                format!("invalid relevance value: {relevance}"),
            )
        })?;

        rows.push(QrelRow {
            query_id: columns[0].trim().to_string(),
            doc_id: columns[2].trim().to_string(),
            relevance: relevance_value,
        });
    }

    write_qrels(out_path, &rows)?;
    Ok(rows.len())
}

pub fn write_qrels(path: &Path, rows: &[QrelRow]) -> io::Result<()> {
    let mut output = String::new();
    for row in rows {
        output.push_str(&format!("{} 0 {} {}\n", row.query_id, row.doc_id, row.relevance));
    }
    fs::write(path, output)
}

// Tiny CSV parser that handles quotes well enough for the pooled annotation file.
fn parse_csv_line(line: &str) -> Vec<String> {
    let mut fields = Vec::new();
    let mut current = String::new();
    let mut chars = line.chars().peekable();
    let mut in_quotes = false;

    while let Some(ch) = chars.next() {
        match ch {
            '"' if in_quotes => {
                if chars.peek() == Some(&'"') {
                    current.push('"');
                    let _ = chars.next();
                } else {
                    in_quotes = false;
                }
            }
            '"' => in_quotes = true,
            ',' if !in_quotes => {
                fields.push(current);
                current = String::new();
            }
            _ => current.push(ch),
        }
    }

    fields.push(current);
    fields
}

#[cfg(test)]
mod tests {
    use super::convert_pool_to_qrels;
    use super::write_run_file;
    use super::RunRow;
    use std::fs;
    use std::path::PathBuf;

    #[test]
    fn write_run_file_should_emit_trec_lines() {
        let path = PathBuf::from("target/test-run.txt");
        let rows = [RunRow {
            query_id: String::from("q1"),
            doc_id: String::from("doc#a"),
            rank: 1,
            score: 1.5,
            run_name: String::from("seekdown_test"),
        }];

        write_run_file(&path, &rows).unwrap();
        let content = fs::read_to_string(&path).unwrap();
        assert_eq!(content, "q1 Q0 doc#a 1 1.500000 seekdown_test\n");
        fs::remove_file(path).unwrap();
    }

    #[test]
    fn convert_pool_to_qrels_should_skip_unjudged_rows() {
        let pool_path = PathBuf::from("target/test-pool.csv");
        let qrels_path = PathBuf::from("target/test-qrels.txt");

        fs::write(
            &pool_path,
            "query_id,query_text,doc_id,path,title,score,snippet,sources,relevance\nq1,install,doc#a,a.md,Install,1.0,snip,section:bm25,3\nq1,install,doc#b,b.md,Other,0.5,snip,section:boolean,\n",
        )
        .unwrap();

        let written = convert_pool_to_qrels(&pool_path, &qrels_path).unwrap();
        let content = fs::read_to_string(&qrels_path).unwrap();
        assert_eq!(written, 1);
        assert_eq!(content, "q1 0 doc#a 3\n");

        fs::remove_file(pool_path).unwrap();
        fs::remove_file(qrels_path).unwrap();
    }
}
