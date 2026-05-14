use std::fmt;

#[derive(Debug, Clone)]
pub struct Bookmark {
    pub id: i64,
    pub url: String,
    pub desc: String,
    pub tags: String,
    pub created_at: String,
}

#[derive(Debug)]
pub enum StorageError {
    /// Failed to open the database file.
    Open(rusqlite::Error),
    /// Caller supplied invalid input (e.g. empty URL).
    InvalidInput(String),
    /// A bookmark with the same URL already exists.
    Duplicate(String),
    /// No bookmark matched the requested identifier.
    NotFound(String),
    /// An unexpected SQLite error occurred.
    Db(rusqlite::Error),
}

impl fmt::Display for StorageError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            StorageError::Open(e) => write!(f, "error: failed to open database: {}", e),
            StorageError::InvalidInput(msg) => write!(f, "error: invalid input: {}", msg),
            StorageError::Duplicate(msg) => write!(f, "error: duplicate bookmark: {}", msg),
            StorageError::NotFound(msg) => write!(f, "error: not found: {}", msg),
            StorageError::Db(e) => write!(f, "error: database error: {}", e),
        }
    }
}

impl std::error::Error for StorageError {}
