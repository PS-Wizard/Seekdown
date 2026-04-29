pub mod chunk;
pub mod corpus;
pub mod section;

use std::io;

pub trait DocumentLoader {
    fn load(&self) -> io::Result<Vec<LoadedDocument>>;
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct LoadedDocument {
    pub key: String,
    pub path: String,
    pub title: String,
    pub body: String,
    pub start_line: u32,
    pub end_line: u32,
}
