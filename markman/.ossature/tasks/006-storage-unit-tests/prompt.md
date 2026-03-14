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
### Acceptance Criteria

- [ ] Database file is created on first run if absent
- [ ] Duplicate URL insertion returns an error
- [ ] Search with empty query returns all rows
- [ ] Search with non-empty query filters correctly across url, desc, and tags
- [ ] Remove with unknown id returns an error
</specification_context>

<dependency_files>
The following files from previous tasks are available. Use `grep_file` and `read_lines` to inspect the types, interfaces, and signatures you need.

- `src/storage.rs` (208 lines)
</dependency_files>

<task>
## Storage: Unit Tests

Add comprehensive unit tests covering all storage operations: database initialization, bookmark creation, duplicate detection, search with various queries, and deletion with error cases.

## Files to Produce

- `src/storage.rs`
</task>