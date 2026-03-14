<project_config>
Project: markman v0.0.1
Language: rust
</project_config>

<project_brief>
Markman is a lightweight bookmark manager built in Rust that provides both CLI and web interfaces for organizing and retrieving saved URLs. The Storage module handles all SQLite database operations, exposing functions that return `Result<T, StorageError>` to represent success or specific failure modes; callers manage error reporting and exit handling. The CLI module implements three core subcommands—`add`, `list`, and `remove`—for direct bookmark manipulation, with configurable database paths via `--db` flag and `~/.markman.db` as default. The Web UI module runs a minimal HTTP server providing read-only bookmark browsing and search capabilities through statically-embedded HTML and CSS with no external runtime dependencies, JavaScript, or authentication. All three modules share the same Storage interface, creating a unified persistence layer that serves both the command-line and browser-based clients without duplication of database logic.
</project_brief>

<spec_brief spec="WEBUI">
The Web UI module implements a minimal, read-only HTTP server using `tiny_http` that serves a self-contained HTML interface for browsing and searching bookmarks stored via the STORAGE module. It embeds all HTML and inline CSS as string constants in `src/web.rs`, providing GET endpoints for viewing all bookmarks (with optional case-insensitive substring filtering via the `q` query parameter) and a `/health` status check. The interface displays bookmarks in a table with clickable URL links, descriptions, and tags, with no authentication, JavaScript, or external assets required.
</spec_brief>

<specification_context>
### Overview

Minimal read-only HTTP server that lets users browse and search bookmarks in a browser. All HTML and CSS are embedded in the binary as string constants — no external files required at runtime. No JavaScript. No authentication.
</specification_context>

<cross_spec_interfaces>
<interface spec="STORAGE">
# Interface: STORAGE

@source: build

# STORAGE Module Public Interface

## src/storage.rs

### Types

```rust
/// A bookmark entry with URL, description, and tags
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Bookmark {
    pub id: i64,
    pub url: String,
    pub description: String,
    pub tags: String,
}
```

### Error Types

```rust
/// Errors that can occur during storage operations
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum StorageError {
    InvalidUrl,
    DuplicateUrl,
    DatabaseOpenFailed,
    SchemaInitializationFailed,
    BookmarkNotFound,
    QueryFailed,
    DatabaseError,
}

impl fmt::Display for StorageError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result { ... }
}

impl std::error::Error for StorageError {}
```

### Functions

```rust
/// Opens or creates a SQLite database file and initializes the bookmarks table schema.
pub fn initialize_database(db_path: &str) -> Result<Connection, StorageError>;

/// Adds a new bookmark to the database.
/// 
/// Returns the ID of the newly created bookmark on success.
/// Returns InvalidUrl if the URL is empty or whitespace.
/// Returns DuplicateUrl if the URL already exists.
/// Returns QueryFailed if the database operation fails.
pub fn add_bookmark(
    conn: &Connection,
    url: String,
    description: String,
    tags: String,
) -> Result<i64, StorageError>;

/// Deletes a bookmark by ID.
///
/// Returns BookmarkNotFound if the bookmark does not exist.
/// Returns QueryFailed if the database operation fails.
pub fn remove_bookmark(conn: &Connection, id: i64) -> Result<(), StorageError>;

/// Searches for bookmarks using case-insensitive substring matching.
///
/// Searches across URL, description, and tags fields using SQLite LIKE.
/// If the query is empty, returns all bookmarks.
/// Results are ordered by created_at descending.
pub fn search_bookmarks(
    conn: &Connection,
    query: &str,
) -> Result<Vec<Bookmark>, StorageError>;
```
</interface>
</cross_spec_interfaces>

<task>
## Bookmark Data Types & Storage Interface

Define the Bookmark struct and storage-related types needed by the web server to query and display bookmarks. This must exist before the web server implementation references storage.

## Files to Produce

- `src/lib.rs`
- `src/storage.rs`
</task>