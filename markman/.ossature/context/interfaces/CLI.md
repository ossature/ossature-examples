# Interface: CLI

@source: build

# Markman Public Interface

## `src/storage/types.rs`

```rust
/// A bookmark record stored in the database.
#[derive(Debug, Clone)]
pub struct Bookmark {
    pub id: i64,
    pub url: String,
    pub desc: String,
    pub tags: String,
    pub created_at: String,
}

/// Errors that can occur during storage operations.
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

impl fmt::Display for StorageError { ... }
impl std::error::Error for StorageError {}
```

## `src/storage/mod.rs`

```rust
pub use types::{Bookmark, StorageError};

/// Open (or create) the SQLite database at `db_path` and ensure the
/// `bookmarks` table exists. Pass `":memory:"` for an in-memory database.
pub fn init_db(db_path: &str) -> Result<rusqlite::Connection, StorageError>;

/// Insert a new bookmark. Returns the row-id of the newly created record.
///
/// Errors:
/// - `StorageError::InvalidInput` if `url` is blank/whitespace-only.
/// - `StorageError::Duplicate` if a bookmark with the same URL already exists.
/// - `StorageError::Db` on any other database error.
pub fn add_bookmark(
    conn: &rusqlite::Connection,
    url: &str,
    desc: &str,
    tags: &str,
) -> Result<i64, StorageError>;

/// Delete the bookmark with the given `id`.
///
/// Errors:
/// - `StorageError::NotFound` if no bookmark with that id exists.
/// - `StorageError::Db` on any other database error.
pub fn remove_bookmark(conn: &rusqlite::Connection, id: i64) -> Result<(), StorageError>;

/// Return bookmarks ordered by `created_at` descending.
///
/// If `query` is empty, all bookmarks are returned.
/// Otherwise, only bookmarks whose `url`, `desc`, or `tags` contain
/// `query` (case-insensitive LIKE match) are returned.
///
/// Errors:
/// - `StorageError::Db` on any database error.
pub fn search_bookmarks(
    conn: &rusqlite::Connection,
    query: &str,
) -> Result<Vec<Bookmark>, StorageError>;
```

## `src/cli.rs`

```rust
#[derive(Parser)]
#[command(name = "markman", version, about = "A bookmark manager")]
pub struct Cli {
    /// Path to the SQLite database file
    #[arg(long, global = true, default_value = "~/.markman.db")]
    pub db: String,

    #[command(subcommand)]
    pub command: Commands,
}

#[derive(Subcommand)]
pub enum Commands {
    /// Add a new bookmark
    Add {
        /// URL to bookmark
        url: String,
        /// Description
        #[arg(short, long, default_value = "")]
        desc: String,
        /// Comma-separated tags
        #[arg(short, long, default_value = "")]
        tags: String,
    },
    /// List bookmarks, optionally filtered by a search query
    List {
        /// Search query
        #[arg(default_value = "")]
        query: String,
    },
    /// Remove a bookmark by id
    Remove {
        /// Bookmark id
        id: i64,
    },
    /// Start the web UI server
    Serve {
        /// Port to listen on
        #[arg(short, long, default_value_t = 3000)]
        port: u16,
    },
}
```

## `src/web/mod.rs`

```rust
/// Start the HTTP server on the given `port`, serving a bookmark search UI
/// backed by `conn`. Blocks indefinitely, handling incoming requests.
pub fn serve(conn: rusqlite::Connection, port: u16);
```