Build passes. The implementation adds `search_bookmarks` at the end of `src/storage.rs`:

- **Empty query**: executes `SELECT … ORDER BY created_at DESC` with no parameters, returning all rows.
- **Non-empty query**: wraps the query string in `%…%` and runs a single prepared statement with `LIKE ?1` applied to `url`, `desc`, and `tags`, relying on SQLite's default case-insensitive ASCII LIKE behaviour.
- Both branches map rusqlite errors to `StorageError::Db` and collect rows into `Vec<Bookmark>`.