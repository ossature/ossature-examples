<project_config>
Project: markman v0.0.1
Language: rust
</project_config>

<project_brief>
Markman is a bookmark manager that stores URLs, descriptions, and tags in a local SQLite database and exposes that data through both a CLI and a browser-based read-only web UI. The storage module (`STORAGE`) owns all database interaction, defining CRUD operations that return `Result<T, StorageError>` with typed error variants; it never calls `process::exit` directly, leaving error handling to callers. The CLI module (`CLI`) depends on storage and provides `add`, `list`, and `remove` subcommands for managing bookmarks, plus a `serve` subcommand that starts the web server; the database path defaults to `~/.markman.db` and is overridable via `--db`. The web UI module (`WEBUI`) also depends on storage and implements a minimal read-only HTTP server for browsing and searching bookmarks in a browser, with all HTML and CSS embedded directly in the binary as string constants — no external files, no JavaScript, and no authentication. The project is written in Rust and uses SQLite (via a Rust SQLite crate) for persistence; both the CLI and web server are compiled into a single binary.
</project_brief>

<spec_brief spec="STORAGE">
Provides SQLite-backed persistence for bookmarks, where each record stores a URL, description, and comma-separated tags. Exposes CRUD operations that return `Result<T, StorageError>` with typed error variants, leaving error display and process termination to callers. Both the CLI and web UI depend exclusively on this module for all database interaction.
</spec_brief>

<specification_context>
### Overview

SQLite-backed persistence layer for bookmarks. Each bookmark has a URL, description, and comma-separated tags. This module owns all database interaction; the CLI and web UI use it exclusively.

All storage functions return `Result<T, StorageError>` where `StorageError` is an enum with variants for each failure case. Callers (CLI, web server) are responsible for printing error messages and exiting. Storage functions never call `process::exit` directly.

### Constraints

- Single file: all storage logic lives in `src/storage.rs`
- Use `rusqlite` crate with the `bundled` feature so SQLite is compiled in — no system SQLite required
- Schema: one table `bookmarks(id INTEGER PRIMARY KEY AUTOINCREMENT, url TEXT NOT NULL UNIQUE, desc TEXT NOT NULL DEFAULT '', tags TEXT NOT NULL DEFAULT '', created_at TEXT NOT NULL DEFAULT (datetime('now')))`
</specification_context>

<dependency_files>
The following files from previous tasks are available. Use `grep_file` and `read_lines` to inspect the types, interfaces, and signatures you need.

- `Cargo.toml`
</dependency_files>

<task>
## Storage: Types — Bookmark & StorageError

Define the `Bookmark` struct (id, url, desc, tags, created_at) and the `StorageError` enum (Open, InvalidInput, Duplicate, NotFound, Db variants) in `src/storage.rs`. These types are the foundation for all storage operations.

## Files to Produce

- `src/storage.rs`
</task>