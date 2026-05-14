# Specification (SMD)

---
L1: ---
L2: id: STORAGE
L3: status: draft
L4: priority: critical
L5: depends: []
L6: ---
L7: # Storage
L8: 
L9: ## Overview
L10: 
L11: SQLite-backed persistence layer for bookmarks. Each bookmark has a URL, description, and comma-separated tags. This module owns all database interaction; the CLI and web UI use it exclusively.
L12: 
L13: All storage functions return `Result<T, StorageError>` where `StorageError` is an enum with variants for each failure case. Callers (CLI, web server) are responsible for printing error messages and exiting. Storage functions never call `process::exit` directly.
L14: 
L15: ## Goals
L16: 
L17: - Provide CRUD operations for bookmarks backed by a local SQLite file
L18: - Support full-text search across URL, description, and tags
L19: 
L20: ## Non-Goals
L21: 
L22: - No caching, migrations beyond initial schema creation, or multi-user isolation
L23: 
L24: ## Requirements
L25: 
L26: ### Initialize Database
L27: 
L28: Opens (or creates) the SQLite database file at the given path and creates the `bookmarks` table if it does not exist.
L29: 
L30: **Accepts:** db_path (string — absolute or relative path to `.db` file)
L31: 
L32: **Returns:** `Result<Connection, StorageError>` — an open database connection handle on success, or an error if the file cannot be opened (`StorageError::Open`) or if the schema cannot be created after a successful open (`StorageError::Init`)
L33: 
L34: **Connection-lifetime model:** The caller owns the returned `Connection` for the duration of the process and passes it to every subsequent storage call. This module targets the CLI use-case: one connection is opened once at startup, used for all operations, and dropped on exit. The web UI is **out of scope** for this module; if a web server is added in the future, connection sharing (e.g. wrapping in a `Mutex` or using a connection pool) must be specified in a separate module spec, as `rusqlite::Connection` is neither `Send` nor `Clone`.
L35: 
L36: **Errors:**
L37: 
L38: - Path is not writable or cannot be opened -> returns `StorageError::Open(reason)`; caller prints "error: cannot open database at <path>: <reason>" and exits with code 1
L39: - `CREATE TABLE` statement fails after a successful open (e.g., corrupt database, permission revoked mid-session) -> returns `StorageError::Init(reason)`; caller prints "error: cannot initialize database: <reason>" and exits with code 1
L40: 
L41: ### Add Bookmark
L42: 
L43: Inserts a new bookmark record.
L44: 
L45: **Accepts:** conn (Connection), url (string, non-empty), desc (string, may be empty — treated same as absent, stored as `""`), tags (string, comma-separated, may be empty — treated same as absent, stored as `""`)
L46: 
L47: **Returns:** `Result<i64, StorageError>` — the integer row id of the newly inserted bookmark on success
L48: 
L49: **Errors:**
L50: 
L51: - Empty url -> returns `StorageError::InvalidInput("url must not be empty")`; caller prints "error: url must not be empty" and exits with code 1
L52: - URL already exists in the database -> returns `StorageError::Duplicate(url)`; caller prints "error: bookmark already exists: <url>" and exits with code 1
L53: - Any other database error -> returns `StorageError::Db(reason)`; caller prints "error: <reason>" and exits with code 1
L54: 
L55: ### Search Bookmarks
L56: 
L57: Returns all bookmarks whose url, desc, or tags fields contain the query string (case-insensitive ASCII substring match using SQLite `LIKE`). If query is empty, returns all bookmarks ordered by `created_at` descending.
L58: 
L59: **Accepts:** conn (Connection), query (string, may be empty)
L60: 
L61: **Returns:** `Result<Vec<Bookmark>, StorageError>` — list of bookmark rows on success, each containing: id (i64), url (string), desc (string), tags (string), created_at (UTC datetime string in `YYYY-MM-DD HH:MM:SS` format, space-separated as returned directly by SQLite `datetime('now')` — e.g. `"2026-01-01 00:00:00"`)
L62: 
L63: **Errors:**
L64: 
L65: - Database read failure -> returns `StorageError::Db(reason)`; caller prints "error: query failed: <reason>" and exits with code 1
L66: 
L67: ### Remove Bookmark
L68: 
L69: Deletes the bookmark with the given id.
L70: 
L71: **Accepts:** conn (Connection), id (i64)
L72: 
L73: **Returns:** `Result<(), StorageError>` — unit on success
L74: 
L75: **Errors:**
L76: 
L77: - No bookmark with that id exists -> returns `StorageError::NotFound(id)`; caller prints "error: bookmark not found: <id>" and exits with code 1
L78: - Any other database error -> returns `StorageError::Db(reason)`; caller prints "error: <reason>" and exits with code 1
L79: 
L80: ## Constraints
L81: 
L82: - Single file: all storage logic lives in `src/storage.rs`
L83: - Use `rusqlite` crate with the `bundled` feature so SQLite is compiled in — no system SQLite required
L84: - Schema: one table `bookmarks(id INTEGER PRIMARY KEY AUTOINCREMENT, url TEXT NOT NULL UNIQUE, desc TEXT NOT NULL DEFAULT '', tags TEXT NOT NULL DEFAULT '', created_at TEXT NOT NULL DEFAULT (datetime('now')))`
L85: 
L86: ## Examples
L87: 
L88: ### Add and Retrieve
L89: 
L90: **Input:**
L91: 
L92: ```
L93: add("https://example.com", "Example site", "example,test")
L94: search("")
L95: ```
L96: 
L97: **Output:**
L98: 
L99: ```
L100: [Bookmark { id: 1, url: "https://example.com", desc: "Example site", tags: "example,test", created_at: "2026-01-01 00:00:00" }]
L101: ```
L102: 
L103: ### Search by Tag
L104: 
L105: **Input:**
L106: 
L107: ```
L108: search("test")
L109: ```
L110: 
L111: **Output:**
L112: 
L113: ```
L114: [Bookmark { id: 1, url: "https://example.com", desc: "Example site", tags: "example,test", created_at: "2026-01-01 00:00:00" }]
L115: ```
L116: 
L117: ## Acceptance Criteria
L118: 
L119: - [ ] Database file is created on first run if absent
L120: - [ ] Duplicate URL insertion returns an error
L121: - [ ] Search with empty query returns all rows
L122: - [ ] Search with non-empty query filters correctly across url, desc, and tags
L123: - [ ] Remove with unknown id returns an error