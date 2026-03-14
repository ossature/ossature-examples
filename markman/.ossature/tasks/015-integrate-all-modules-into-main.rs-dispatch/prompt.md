<project_config>
Project: markman v0.0.1
Language: rust
</project_config>

<project_brief>
Markman is a lightweight bookmark manager built in Rust that provides both CLI and web interfaces for organizing and retrieving saved URLs. The Storage module handles all SQLite database operations, exposing functions that return `Result<T, StorageError>` to represent success or specific failure modes; callers manage error reporting and exit handling. The CLI module implements three core subcommands—`add`, `list`, and `remove`—for direct bookmark manipulation, with configurable database paths via `--db` flag and `~/.markman.db` as default. The Web UI module runs a minimal HTTP server providing read-only bookmark browsing and search capabilities through statically-embedded HTML and CSS with no external runtime dependencies, JavaScript, or authentication. All three modules share the same Storage interface, creating a unified persistence layer that serves both the command-line and browser-based clients without duplication of database logic.
</project_brief>

<spec_brief spec="CLI">
The CLI module provides the command-line entry point for the bookmark manager, implementing four subcommands (`add`, `list`, `remove`, `serve`) with `clap`-based argument parsing and a global `--db` flag for database path configuration. It delegates bookmark operations to the STORAGE module and delegates the `serve` subcommand to the web UI module, handling user input validation and providing plain-text output and error messages with appropriate exit codes.
</spec_brief>

<specification_context>
### Constraints

- Single entry point: `src/main.rs` handles argument parsing and dispatches to storage or web modules
- Use `clap` crate with derive macros for argument parsing
- Global `--db <path>` flag applies to all subcommands; default path is resolved as `~/.markman.db`
- No colored output, no spinners — plain text only
</specification_context>

<dependency_files>
The following files from previous tasks are available. Use `grep_file` and `read_lines` to inspect the types, interfaces, and signatures you need.

- `src/main.rs` (126 lines)
- `src/commands/mod.rs` (7 lines)
- `src/web/mod.rs` (3 lines)
- `src/web/serve.rs` (88 lines)
</dependency_files>

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
## Integrate all modules into main.rs dispatch

Update src/main.rs to wire together all command handlers and web server via imports and dispatch logic. Ensure global --db flag is properly passed to storage and serve modules.
</task>