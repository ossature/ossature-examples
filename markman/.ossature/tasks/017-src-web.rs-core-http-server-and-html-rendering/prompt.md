<project_config>
Project: markman v0.0.1
Language: rust
</project_config>

<project_brief>
Markman is a bookmark manager that stores URLs, descriptions, and tags in a local SQLite database and exposes that data through both a CLI and a browser-based read-only web UI. The storage module (`STORAGE`) owns all database interaction, defining CRUD operations that return `Result<T, StorageError>` with typed error variants; it never calls `process::exit` directly, leaving error handling to callers. The CLI module (`CLI`) depends on storage and provides `add`, `list`, and `remove` subcommands for managing bookmarks, plus a `serve` subcommand that starts the web server; the database path defaults to `~/.markman.db` and is overridable via `--db`. The web UI module (`WEBUI`) also depends on storage and implements a minimal read-only HTTP server for browsing and searching bookmarks in a browser, with all HTML and CSS embedded directly in the binary as string constants — no external files, no JavaScript, and no authentication. The project is written in Rust and uses SQLite (via a Rust SQLite crate) for persistence; both the CLI and web server are compiled into a single binary.
</project_brief>

<spec_brief spec="WEBUI">
The Web UI module implements a minimal read-only HTTP server that renders bookmark data from the STORAGE module as HTML pages viewable in a browser. It is responsible for serving bookmark listings, search/filter functionality, and all HTML/CSS responses — with all markup and styles embedded directly as string constants in the binary. The server requires no external assets, no JavaScript, and no authentication.
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

- `Cargo.toml`
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
## src/web.rs: Core HTTP server and HTML rendering

Implement all server logic in `src/web.rs`. Define embedded HTML template and CSS as `const &str`. Implement `GET /` (list all bookmarks or filter by `q` via case-insensitive substring match against url, desc, and tags joined as a single string), `GET /health`, and a catch-all 404 handler. Render bookmarks into an HTML table with URL as a clickable `<a>` link, description, and tags columns. HTML-escape the `q` value when placing it in the input's `value` attribute, and HTML-escape bookmark fields before insertion. Return HTTP 500 with plain-text 'internal server error' on database read failure. Export a public `run` function that accepts a bind address and a storage handle.

## Files to Produce

- `src/web.rs`
</task>