use std::io;
use std::path::{Path, PathBuf};

use crate::tokenize::tokenize;

use super::corpus::read_markdown_files;
use super::{DocumentLoader, LoadedDocument};

#[derive(Debug, Clone)]
pub struct ChunkLoader {
    pub root: PathBuf,
    pub chunk_size: usize,
}

impl ChunkLoader {
    pub fn new(root: impl AsRef<Path>, chunk_size: usize) -> Self {
        Self {
            root: root.as_ref().to_path_buf(),
            chunk_size,
        }
    }
}

impl DocumentLoader for ChunkLoader {
    fn load(&self) -> io::Result<Vec<LoadedDocument>> {
        let files = read_markdown_files(&self.root)?;
        let mut documents = Vec::new();

        for file in files {
            documents.extend(split_into_chunks(&file.path, &file.content, self.chunk_size));
        }

        Ok(documents)
    }
}

// Turn one markdown file into many synthetic retrieval documents.
//
// Chunk mode deliberately ignores authored markdown structure and instead treats
// the file as a flat token stream split into fixed-size windows.
fn split_into_chunks(path: &str, content: &str, chunk_size: usize) -> Vec<LoadedDocument> {
    let tokens = tokenize(content);
    if tokens.is_empty() {
        return Vec::new();
    }

    // Defensive clamp so `--chunk-size 0` does not break chunking.
    let safe_chunk_size = chunk_size.max(1);
    let mut documents = Vec::new();

    for (index, chunk) in tokens.chunks(safe_chunk_size).enumerate() {
        // Rebuild the chunk body as normalized token text.
        let body = chunk.join(" ");
        documents.push(LoadedDocument {
            // Stable chunk ids are important because runs / pools / qrels refer to them later.
            key: format!("{path}#chunk-{index:04}"),
            path: path.to_string(),
            title: format!("chunk {index}"),
            body,
            // Chunk mode does not preserve original line locations.
            start_line: 0,
            end_line: 0,
        });
    }

    documents
}

#[cfg(test)]
mod tests {
    use super::split_into_chunks;

    #[test]
    fn split_into_chunks_should_emit_stable_chunk_keys() {
        let docs = split_into_chunks("docs/test.md", "one two three four five", 2);
        assert_eq!(docs[0].key, "docs/test.md#chunk-0000");
        assert_eq!(docs[1].key, "docs/test.md#chunk-0001");
        assert_eq!(docs[2].key, "docs/test.md#chunk-0002");
    }
}
