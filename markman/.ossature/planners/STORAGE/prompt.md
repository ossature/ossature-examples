# Project: markman v0.0.1 (rust)

## Specification (SMD)

---
id: STORAGE
status: draft
priority: critical
depends: []
---

# Storage

## Overview

SQLite-backed persistence layer for bookmarks. Each bookmark has a URL, description, and comma-separated tags. This module owns all database interaction; the CLI and web UI use it exclusively.

All storage functions return `Result<T, StorageError>` where `StorageError` is an enum with variants for each failure case. Callers (CLI, web server) are responsible for printing error messages and exiting. Storage functions never call `process::exit` directly.

## Goals

- Provide CRUD operations for bookmarks backed by a local SQLite file
- Support full-text search across URL, description, and tags

## Non-Goals

- No caching, migrations beyond initial schema creation, or multi-user isolation

## Requirements

### Initialize Database

Opens (or creates) the SQLite database file at the given path and creates the `bookmarks` table if it does not exist.

**Accepts:** db_path (string — absolute or relative path to `.db` file)

**Returns:** `Result<Connection, StorageError>` — an open database connection handle on success, or `StorageError::Open(reason)` if the path is not writable or the database cannot be opened

**Errors:**

- Path is not writable or cannot be opened -> returns `StorageError::Open(reason)`; caller prints "error: cannot open database at <path>: <reason>" and exits with code 1

### Add Bookmark

Inserts a new bookmark record.

**Accepts:** conn (Connection), url (string, non-empty), desc (string, may be empty — treated same as absent, stored as `""`), tags (string, comma-separated, may be empty — treated same as absent, stored as `""`)

**Returns:** `Result<i64, StorageError>` — the integer row id of the newly inserted bookmark on success

**Errors:**

- Empty url -> returns `StorageError::InvalidInput("url must not be empty")`; caller prints "error: url must not be empty" and exits with code 1
- URL already exists in the database -> returns `StorageError::Duplicate(url)`; caller prints "error: bookmark already exists: <url>" and exits with code 1
- Any other database error -> returns `StorageError::Db(reason)`; caller prints "error: <reason>" and exits with code 1

### Search Bookmarks

Returns all bookmarks whose url, desc, or tags fields contain the query string (case-insensitive ASCII substring match using SQLite `LIKE`). If query is empty, returns all bookmarks ordered by `created_at` descending.

**Accepts:** conn (Connection), query (string, may be empty)

**Returns:** `Result<Vec<Bookmark>, StorageError>` — list of bookmark rows on success, each containing: id (i64), url (string), desc (string), tags (string), created_at (UTC datetime string in `YYYY-MM-DD HH:MM:SS` format as stored by SQLite `datetime('now')`)

**Errors:**

- Database read failure -> returns `StorageError::Db(reason)`; caller prints "error: query failed: <reason>" and exits with code 1

### Remove Bookmark

Deletes the bookmark with the given id.

**Accepts:** conn (Connection), id (i64)

**Returns:** `Result<(), StorageError>` — unit on success

**Errors:**

- No bookmark with that id exists -> returns `StorageError::NotFound(id)`; caller prints "error: bookmark not found: <id>" and exits with code 1
- Any other database error -> returns `StorageError::Db(reason)`; caller prints "error: <reason>" and exits with code 1

## Constraints

- Single file: all storage logic lives in `src/storage.rs`
- Use `rusqlite` crate with the `bundled` feature so SQLite is compiled in — no system SQLite required
- Schema: one table `bookmarks(id INTEGER PRIMARY KEY AUTOINCREMENT, url TEXT NOT NULL UNIQUE, desc TEXT NOT NULL DEFAULT '', tags TEXT NOT NULL DEFAULT '', created_at TEXT NOT NULL DEFAULT (datetime('now')))`

## Examples

### Add and Retrieve

**Input:**

```
add("https://example.com", "Example site", "example,test")
search("")
```

**Output:**

```
[Bookmark { id: 1, url: "https://example.com", desc: "Example site", tags: "example,test", created_at: "2026-01-01T00:00:00" }]
```

### Search by Tag

**Input:**

```
search("test")
```

**Output:**

```
[Bookmark { id: 1, url: "https://example.com", desc: "Example site", tags: "example,test", created_at: "2026-01-01T00:00:00" }]
```

## Acceptance Criteria

- [ ] [ ] Database file is created on first run if absent
- [ ] [ ] Duplicate URL insertion returns an error
- [ ] [ ] Search with empty query returns all rows
- [ ] [ ] Search with non-empty query filters correctly across url, desc, and tags
- [ ] [ ] Remove with unknown id returns an error

## Notes



## Audit Findings (avoid these issues in planning)

- [WARNING] Requirements > Search Bookmarks, L57: The spec states results are ordered by `created_at` descending when the query is empty, but does not specify the ordering when a non-empty query is provided. Two implementers could reasonably choose different orderings (e.g., insertion order, ascending created_at, or relevance), producing different user-visible output.
- [WARNING] Requirements > Search Bookmarks, L57: The spec says 'case-insensitive ASCII substring match using SQLite `LIKE`', but SQLite's `LIKE` is only case-insensitive for ASCII alphabetic characters (A-Z) by default — it is case-sensitive for non-ASCII Unicode characters. This boundary condition is not acknowledged, so an implementer might add `PRAGMA case_sensitive_like` or a custom collation while another relies on SQLite's default, producing different results for non-ASCII queries.
- [WARNING] Requirements > Add Bookmark, L52: The duplicate-URL detection is described as a returned `StorageError::Duplicate`, but it is not specified whether this check is performed in Rust before the INSERT (e.g., a prior SELECT) or by relying on the SQLite UNIQUE constraint violation. These approaches differ in behavior under concurrent writes (though the spec is single-connection/CLI). More critically, if detection is via the UNIQUE constraint, the error must be distinguished from a generic `StorageError::Db`, and the spec does not describe how to identify the constraint violation from `rusqlite`'s error type.
- [INFO] Requirements > Initialize Database > Connection-lifetime model, L34: The spec notes that `rusqlite::Connection` is neither `Send` nor `Clone` and defers web UI connection sharing to a future spec. However, the function signatures use `conn (Connection)` by value in subsequent calls (e.g., Add Bookmark, Search Bookmarks, Remove Bookmark at L45, L59, L71). Passing `Connection` by value would consume it on the first call, making subsequent calls impossible. The intent is almost certainly to pass by shared or mutable reference, but this is not stated.

## Build Setup Command
The following setup command runs before the first task:
```
['cargo init --name markman']
```
Do not generate tasks that duplicate what this command does.