Compiles cleanly. The implementation defines:

- **`Bookmark`** — `pub` struct with `id: i64`, `url`, `desc`, `tags`, `created_at` as `String` fields, matching the SQLite schema columns exactly.
- **`StorageError`** — enum with all five required variants:
  - `Open(rusqlite::Error)` — wraps failures when opening the database
  - `InvalidInput(String)` — carries a message for bad user-supplied data
  - `Duplicate(String)` — carries a message when a unique constraint is violated
  - `NotFound(String)` — carries a message when a lookup finds nothing
  - `Db(rusqlite::Error)` — wraps general database-level errors

Both `Display` and `std::error::Error` are implemented so callers can print or propagate errors idiomatically. The `source()` impl correctly chains the underlying `rusqlite::Error` for the two wrapping variants.