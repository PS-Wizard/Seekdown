// Lowercase lexical tokenizer.
//
// Any non-ASCII-alphanumeric character acts as a boundary, so `rust-cli`
// becomes `rust`, `cli` and `BM25+` becomes `bm25`.
pub fn tokenize(text: &str) -> Vec<String> {
    let mut tokens = Vec::new();
    let mut current = String::new();

    for ch in text.chars() {
        if ch.is_ascii_alphanumeric() {
            current.push(ch.to_ascii_lowercase());
            continue;
        }

        if !current.is_empty() {
            tokens.push(std::mem::take(&mut current));
        }
    }

    if !current.is_empty() {
        tokens.push(current);
    }

    tokens
}

#[cfg(test)]
mod tests {
    use super::tokenize;

    #[test]
    fn tokenize_should_lowercase_and_split_punctuation() {
        let tokens = tokenize("Rust, rust-cli and JSON!");
        assert_eq!(tokens, ["rust", "rust", "cli", "and", "json"]);
    }
}
