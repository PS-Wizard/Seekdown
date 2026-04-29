use std::fs;
use std::io;
use std::path::{Path, PathBuf};

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct MarkdownFile {
    pub path: String,
    pub content: String,
}

pub fn read_markdown_files(root: &Path) -> io::Result<Vec<MarkdownFile>> {
    let mut paths = Vec::new();
    collect_markdown_paths(root, root, &mut paths)?;
    paths.sort();

    let mut files = Vec::with_capacity(paths.len());
    for path in paths {
        let full_path = root.join(&path);
        let content = fs::read_to_string(&full_path)?;
        files.push(MarkdownFile {
            path: normalize_path(&path),
            content,
        });
    }

    Ok(files)
}

fn collect_markdown_paths(root: &Path, current: &Path, out: &mut Vec<PathBuf>) -> io::Result<()> {
    for entry_result in fs::read_dir(current)? {
        let entry = entry_result?;
        let path = entry.path();
        let file_type = entry.file_type()?;

        if file_type.is_dir() {
            collect_markdown_paths(root, &path, out)?;
            continue;
        }

        if !file_type.is_file() || !is_markdown_file(&path) {
            continue;
        }

        let relative = path
            .strip_prefix(root)
            .map_err(|error| io::Error::other(error.to_string()))?;
        out.push(relative.to_path_buf());
    }

    Ok(())
}

fn is_markdown_file(path: &Path) -> bool {
    matches!(
        path.extension().and_then(|ext| ext.to_str()),
        Some("md" | "markdown")
    )
}

fn normalize_path(path: &Path) -> String {
    path.to_string_lossy().replace('\\', "/")
}
