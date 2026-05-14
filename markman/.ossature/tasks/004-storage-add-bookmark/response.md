Build succeeds. Here's a summary of what was implemented:

**`add_bookmark(conn, url, desc, tags) -> Result<i64, StorageError>`**

- **Empty URL validation**: trims the URL and returns `StorageError::InvalidInput` if blank, before touching the database.
- **Insert**: executes `INSERT INTO bookmarks (url, desc, tags) VALUES (?1, ?2, ?3)` using parameterised queries.
- **Error mapping**: inspects the `rusqlite::Error` variant — a `SqliteFailure` with `ErrorCode::ConstraintViolation` (SQLite error 19, triggered by the `UNIQUE` constraint on `url`) becomes `StorageError::Duplicate`; any other DB error becomes `StorageError::Db`.
- **Return value**: on success, returns `conn.last_insert_rowid()` as the new row's `i64` ID.