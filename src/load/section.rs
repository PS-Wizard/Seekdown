use std::io;
use std::path::{Path, PathBuf};

use super::corpus::read_markdown_files;
use super::{DocumentLoader, LoadedDocument};

#[derive(Debug, Clone)]
pub struct SectionLoader {
    pub root: PathBuf,
}

impl SectionLoader {
    pub fn new(root: impl AsRef<Path>) -> Self {
        Self {
            root: root.as_ref().to_path_buf(),
        }
    }
}

impl DocumentLoader for SectionLoader {
    fn load(&self) -> io::Result<Vec<LoadedDocument>> {
        let files = read_markdown_files(&self.root)?;
        let mut documents = Vec::new();

        for file in files {
            documents.extend(parse_sections(&file.path, &file.content));
        }

        Ok(documents)
    }
}

fn parse_sections(path: &str, content: &str) -> Vec<LoadedDocument> {
    let lines: Vec<&str> = content.lines().collect();
    let mut sections = Vec::new();
    let mut stack: Vec<String> = Vec::new();

    let mut current_title = String::from("root");
    let mut current_key = format!("{path}#root");
    let mut current_start = 1_u32;
    let mut current_body = String::new();

    for (index, line) in lines.iter().enumerate() {
        if let Some((level, heading)) = parse_heading(line) {
            push_section(
                &mut sections,
                path,
                &current_title,
                &current_key,
                current_start,
                index as u32,
                &current_body,
            );

            while stack.len() >= level {
                stack.pop();
            }
            stack.push(heading.to_string());

            current_title = stack.join(" > ");
            current_key = format!("{path}#{}", slug_path(&stack));
            current_start = index as u32 + 1;
            current_body.clear();
            continue;
        }

        current_body.push_str(line);
        current_body.push('\n');
    }

    push_section(
        &mut sections,
        path,
        &current_title,
        &current_key,
        current_start,
        lines.len() as u32,
        &current_body,
    );

    if sections.is_empty() {
        sections.push(LoadedDocument {
            key: format!("{path}#root"),
            path: path.to_string(),
            title: String::from("root"),
            body: content.to_string(),
            start_line: 1,
            end_line: lines.len() as u32,
        });
    }

    sections
}

fn push_section(
    sections: &mut Vec<LoadedDocument>,
    path: &str,
    title: &str,
    key: &str,
    start_line: u32,
    end_line: u32,
    body: &str,
) {
    let trimmed = body.trim();
    if trimmed.is_empty() {
        return;
    }

    sections.push(LoadedDocument {
        key: key.to_string(),
        path: path.to_string(),
        title: title.to_string(),
        body: trimmed.to_string(),
        start_line,
        end_line,
    });
}

fn parse_heading(line: &str) -> Option<(usize, &str)> {
    let trimmed = line.trim();
    let hashes = trimmed.bytes().take_while(|byte| *byte == b'#').count();
    if hashes == 0 || hashes > 6 {
        return None;
    }

    let heading = trimmed[hashes..].trim();
    if heading.is_empty() {
        return None;
    }

    Some((hashes, heading))
}

fn slug_path(parts: &[String]) -> String {
    let mut slugged = Vec::with_capacity(parts.len());
    for part in parts {
        slugged.push(slugify(part));
    }
    slugged.join("/")
}

fn slugify(input: &str) -> String {
    let mut slug = String::with_capacity(input.len());
    let mut last_dash = false;

    for ch in input.chars() {
        if ch.is_ascii_alphanumeric() {
            slug.push(ch.to_ascii_lowercase());
            last_dash = false;
        } else if !last_dash {
            slug.push('-');
            last_dash = true;
        }
    }

    slug.trim_matches('-').to_string()
}

#[cfg(test)]
mod tests {
    use super::parse_sections;

    #[test]
    fn parse_sections_should_preserve_header_hierarchy() {
        let docs = parse_sections(
            "docs/test.md",
            "# Intro\nhello\n## Install\nuse cargo\n### Linux\nworks\n",
        );

        assert_eq!(docs[0].title, "Intro");
        assert_eq!(docs[1].title, "Intro > Install");
        assert_eq!(docs[2].title, "Intro > Install > Linux");
    }
}
