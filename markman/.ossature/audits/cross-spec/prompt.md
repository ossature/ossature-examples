## Spec Dependency Graph

- STORAGE: depends on [(none)]
- CLI: depends on [STORAGE]
- WEBUI: depends on [STORAGE]

## Spec Summaries

### STORAGE: Storage

**Overview:** SQLite-backed persistence layer for bookmarks. Each bookmark has a URL, description, and comma-separated tags. This module owns all database interaction; the CLI and web UI use it exclusively.

All storage functions return `Result<T, StorageError>` where `StorageError` is an enum with variants for each failure case. Callers (CLI, web server) are responsible for printing error messages and exiting. Storage functions never call `process::exit` directly.

**Requirements:**
- Initialize Database
- Add Bookmark
- Search Bookmarks
- Remove Bookmark

### CLI: CLI

**Overview:** Command-line interface for managing bookmarks. Provides three subcommands — `add`, `list`, and `remove` — plus a `serve` subcommand to start the web UI. The database path defaults to `~/.markman.db` and can be overridden with `--db <path>`.

**Requirements:**
- add subcommand
- list subcommand
- remove subcommand
- serve subcommand

### WEBUI: Web UI

**Overview:** Minimal read-only HTTP server that lets users browse and search bookmarks in a browser. All HTML and CSS are embedded in the binary as string constants — no external files required at runtime. No JavaScript. No authentication.

**Requirements:**
- GET /
- GET /health
