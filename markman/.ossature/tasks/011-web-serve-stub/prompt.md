<project_config>
Project: markman v0.0.1
Language: rust
</project_config>

<project_brief>
Markman is a bookmark manager that stores URLs, descriptions, and tags in a local SQLite database and exposes that data through both a CLI and a browser-based read-only web UI. The storage module (`STORAGE`) owns all database interaction, defining CRUD operations that return `Result<T, StorageError>` with typed error variants; it never calls `process::exit` directly, leaving error handling to callers. The CLI module (`CLI`) depends on storage and provides `add`, `list`, and `remove` subcommands for managing bookmarks, plus a `serve` subcommand that starts the web server; the database path defaults to `~/.markman.db` and is overridable via `--db`. The web UI module (`WEBUI`) also depends on storage and implements a minimal read-only HTTP server for browsing and searching bookmarks in a browser, with all HTML and CSS embedded directly in the binary as string constants — no external files, no JavaScript, and no authentication. The project is written in Rust and uses SQLite (via a Rust SQLite crate) for persistence; both the CLI and web server are compiled into a single binary.
</project_brief>

<spec_brief spec="CLI">
The CLI module provides a command-line interface for bookmark management, exposing `add`, `list`, `remove`, and `serve` subcommands. It is responsible for parsing user arguments, resolving the database path (defaulting to `~/.markman.db` with an optional `--db` override), and delegating operations to the STORAGE module. The `serve` subcommand launches the web UI, bridging CLI entry points with the broader application stack.
</spec_brief>

<specification_context>
### serve subcommand

Starts the HTTP server for the web UI.

**Accepts:** --port/-p (u16, optional, default 3000), --db (string path, optional, overrides global default)

**Returns:** Prints "listening on http://0.0.0.0:<port>" to stdout, then blocks serving requests

**Errors:**

- Port already in use -> prints "error: port <port> is already in use" to stderr and exits with code 1
</specification_context>

<dependency_files>
The following files from previous tasks are available. Use `grep_file` and `read_lines` to inspect the types, interfaces, and signatures you need.

- `Cargo.toml`
- `src/storage/mod.rs`
</dependency_files>

<cross_spec_interfaces>
<interface spec="STORAGE">
# Interface: STORAGE

@source: build

# `src/storage.rs` Interface

## Types

```rust
#[derive(Debug, Clone)]
pub struct Bookmark {
    pub id: i64,
    pub url: String,
    pub desc: String,
    pub tags: String,
    pub created_at: String,
}
```

## Error Types

```rust
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
impl std::error::Error for StorageError { ... }
```

## Functions

```rust
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
</interface>
</cross_spec_interfaces>

<task>
## Web: serve stub

Implement `src/web/mod.rs` with a `serve` function that binds to the given port, prints the listening message to stdout, and blocks serving requests. Handles port-already-in-use error by printing to stderr and exiting with code 1.

## Files to Produce

- `src/web/mod.rs`
</task>