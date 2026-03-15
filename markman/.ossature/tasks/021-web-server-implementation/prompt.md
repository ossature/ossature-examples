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

### Goals

- Serve a single-page HTML interface for viewing and searching bookmarks
- Ship as a fully self-contained binary with no external static assets

### Non-Goals

- No add, edit, or remove via the web UI
- No authentication or access control
- No JavaScript, no external CSS frameworks or fonts

## Requirements

### GET /

Returns the full HTML page. If the `q` query parameter is present and non-empty, only bookmarks matching the query (case-insensitive substring match against url, desc, or tags) are shown. If `q` is absent or empty, all bookmarks are shown ordered by insertion time descending.

**Accepts:** q (query string parameter, optional, string)

**Returns:** HTTP 200 with `Content-Type: text/html; charset=utf-8`. Body is a complete HTML document containing: a text input pre-filled with `q`, a submit button, and a table listing each bookmark's URL (as a clickable `<a>` link), description, and tags. If no bookmarks match, the table body shows a single row with the message "No bookmarks found."

**Errors:**

- Database read failure -> HTTP 500 with plain-text body "internal server error"

### GET /health

Health check endpoint for the server.

**Accepts:** (no parameters)

**Returns:** HTTP 200 with plain-text body "ok"

**Errors:**

- Server internal failure -> HTTP 500 with plain-text body "internal server error"

### Constraints

- Single file: all server logic lives in `src/web.rs`
- Use `tiny_http` crate for the HTTP server — no async runtime required
- HTML template and CSS are defined as `const &str` within `src/web.rs`; they are not read from disk at runtime
- HTML must be valid and render correctly without JavaScript
- CSS must be inline in the `<style>` tag within the HTML — no external stylesheets
- The search form uses `method="get"` and `action="/"` so the query appears in the URL
- Table columns: URL, Description, Tags

## Examples

### View all bookmarks

**Input:**

```
GET / HTTP/1.1
```

**Output:**

```
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8

<!DOCTYPE html>
<html>...table with all bookmarks...</html>
```

### Search bookmarks

**Input:**

```
GET /?q=rust HTTP/1.1
```

**Output:**

```
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8

<!DOCTYPE html>
<html>...table filtered to bookmarks matching "rust"...</html>
```

### Acceptance Criteria

- [ ] `GET /` returns all bookmarks as an HTML table
- [ ] `GET /?q=<term>` returns only matching bookmarks
- [ ] All HTML and CSS are embedded in the binary — no files read from disk
- [ ] Bookmark URLs in the table are rendered as clickable `<a>` links
- [ ] Empty result set shows "No bookmarks found." row instead of an empty table
- [ ] `GET /health` returns 200 with body "ok"
</specification_context>

<dependency_files>
The following files from previous tasks are available. Use `grep_file` and `read_lines` to inspect the types, interfaces, and signatures you need.

- `Cargo.toml` (23 lines)
- `src/lib.rs` (7 lines)
- `src/storage.rs` (2 lines)
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
## Web Server Implementation

Implement the HTTP server in src/web.rs with embedded HTML/CSS, handling GET / (with optional ?q search), GET /health, and error cases. All HTML and CSS are defined as const strings within this module.

## Files to Produce

- `src/web.rs`
</task>