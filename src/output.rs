use crate::query::SearchResult;
use crate::tokenize::tokenize;

const RESET: &str = "\x1b[0m";
const BOLD: &str = "\x1b[1m";
const DIM: &str = "\x1b[2m";
const CYAN: &str = "\x1b[36m";
const YELLOW: &str = "\x1b[33m";

pub fn print_results(query: &str, results: &[SearchResult]) {
    if results.is_empty() {
        println!("no results");
        return;
    }

    let query_terms = tokenize(query);

    for (index, result) in results.iter().enumerate() {
        println!(
            "{bold}{rank}.{reset} {bold}{title}{reset}",
            bold = BOLD,
            rank = index + 1,
            reset = RESET,
            title = result.title,
        );
        println!(
            "  {cyan}{path}{reset}  {dim}lines {start}-{end}  score {score:.4}{reset}",
            cyan = CYAN,
            path = result.path,
            reset = RESET,
            dim = DIM,
            start = result.start_line,
            end = result.end_line,
            score = result.score,
        );
        if !result.snippet.is_empty() {
            println!("  {}", style_snippet(&result.snippet, &query_terms));
        }
        println!();
    }
}

fn style_snippet(snippet: &str, query_terms: &[String]) -> String {
    if snippet.is_empty() {
        return String::new();
    }

    let mut output = String::new();
    let mut current = String::new();

    for ch in snippet.chars() {
        if ch.is_alphanumeric() {
            current.push(ch);
            continue;
        }

        push_styled_token(&mut output, &current, query_terms);
        current.clear();
        output.push_str(DIM);
        output.push(ch);
        output.push_str(RESET);
    }

    push_styled_token(&mut output, &current, query_terms);
    output
}

fn push_styled_token(output: &mut String, token: &str, query_terms: &[String]) {
    if token.is_empty() {
        return;
    }

    if query_terms.iter().any(|term| term == &token.to_ascii_lowercase()) {
        output.push_str(BOLD);
        output.push_str(YELLOW);
        output.push_str(token);
        output.push_str(RESET);
    } else {
        output.push_str(DIM);
        output.push_str(token);
        output.push_str(RESET);
    }
}
