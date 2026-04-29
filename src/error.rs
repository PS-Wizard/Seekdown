#[derive(Debug)]
pub enum SeekdownError {
    Io(std::io::Error),
}
