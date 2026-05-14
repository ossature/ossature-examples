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
### add subcommand

Adds a new bookmark.

**Accepts:** url (positional string, required), --desc/-d (string, optional, default ""), --tags/-t (comma-separated string, optional, default "")

**Returns:** Prints "added: <url>" to stdout on success

**Errors:**

- Missing url argument -> prints usage hint and exits with code 2
- Duplicate URL -> delegates to storage error message, exits with code 1

### list subcommand

Lists bookmarks, optionally filtered by a search query.

**Accepts:** query (positional string, optional, default "")

**Returns:** Prints each matching bookmark to stdout, one per line, in the format: `[<id>] <url> | <desc> | tags: <tags>`. If no bookmarks match, prints "no bookmarks found."

**Errors:**

- Database read failure -> delegates to storage error message, exits with code 1

### remove subcommand

Removes a bookmark by its numeric id.

**Accepts:** id (positional i64, required)

**Returns:** Prints "removed: <id>" to stdout on success

**Errors:**

- Missing or non-integer id -> prints "error: id must be a positive integer" and exits with code 2
- Unknown id -> delegates to storage error message, exits with code 1

### Constraints

- Single entry point: `src/main.rs` handles argument parsing and dispatches to storage or web modules
- Use `clap` crate with derive macros for argument parsing
- Global `--db <path>` flag applies to all subcommands; default path is resolved as `~/.markman.db`
- No colored output, no spinners — plain text only
</specification_context>

<dependency_files>
The following files from previous tasks are available. Use `grep_file` and `read_lines` to inspect the types, interfaces, and signatures you need.

- `Cargo.toml`
- `src/storage/types.rs`
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
## Storage: SQLite backend

Implement `src/storage/mod.rs` with the `Storage` struct that opens/creates a SQLite database at a given path, and exposes `add`, `list`, and `remove` methods. Errors map to `StorageError`. Default path resolves to `~/.markman.db`.

## Files to Produce

- `src/storage/mod.rs`
</task>