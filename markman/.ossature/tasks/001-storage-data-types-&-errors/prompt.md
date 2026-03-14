<project_config>
Project: markman v0.0.1
Language: rust
</project_config>

<project_brief>
Markman is a lightweight bookmark manager built in Rust that provides both CLI and web interfaces for organizing and retrieving saved URLs. The Storage module handles all SQLite database operations, exposing functions that return `Result<T, StorageError>` to represent success or specific failure modes; callers manage error reporting and exit handling. The CLI module implements three core subcommands—`add`, `list`, and `remove`—for direct bookmark manipulation, with configurable database paths via `--db` flag and `~/.markman.db` as default. The Web UI module runs a minimal HTTP server providing read-only bookmark browsing and search capabilities through statically-embedded HTML and CSS with no external runtime dependencies, JavaScript, or authentication. All three modules share the same Storage interface, creating a unified persistence layer that serves both the command-line and browser-based clients without duplication of database logic.
</project_brief>

<spec_brief spec="STORAGE">
The Storage module provides a SQLite-backed persistence layer for bookmarks, implementing CRUD operations (add, search, remove) and full-text search across URL, description, and tags fields. It centralizes all database interaction logic in `src/storage.rs` using the `rusqlite` crate and returns `Result<T, StorageError>` types to be handled by callers (CLI and web UI), which are responsible for error reporting and process exit codes. The module manages a single `bookmarks` table with automatic schema creation and enforces constraints like unique URLs and non-empty URL validation.
</spec_brief>

<specification_context>
### Overview

SQLite-backed persistence layer for bookmarks. Each bookmark has a URL, description, and comma-separated tags. This module owns all database interaction; the CLI and web UI use it exclusively.

All storage functions return `Result<T, StorageError>` where `StorageError` is an enum with variants for each failure case. Callers (CLI, web server) are responsible for printing error messages and exiting. Storage functions never call `process::exit` directly.
</specification_context>

<task>
## Storage: Data Types & Errors

Define the core Bookmark struct and StorageError enum. These types are used by all storage operations and called by CLI/web UI error handlers.

## Files to Produce

- `src/storage.rs`
</task>