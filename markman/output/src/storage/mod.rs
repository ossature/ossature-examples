mod types;

pub use types::{Bookmark, StorageError};

use rusqlite;

/// Open (or create) the SQLite database at `db_path` and ensure the
/// `bookmarks` table exists. Pass `":memory:"` for an in-memory database.
pub fn init_db(db_path: &str) -> Result<rusqlite::Connection, StorageError> {
    let conn = rusqlite::Connection::open(db_path).map_err(StorageError::Open)?;
    conn.execute_batch(
        "CREATE TABLE IF NOT EXISTS bookmarks (
            id         INTEGER PRIMARY KEY AUTOINCREMENT,
            url        TEXT NOT NULL UNIQUE,
            desc       TEXT NOT NULL DEFAULT '',
            tags       TEXT NOT NULL DEFAULT '',
            created_at TEXT NOT NULL DEFAULT (datetime('now'))
        );",
    )
    .map_err(StorageError::Db)?;
    Ok(conn)
}

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
) -> Result<i64, StorageError> {
    if url.trim().is_empty() {
        return Err(StorageError::InvalidInput(
            "URL must not be empty".to_string(),
        ));
    }
    conn.execute(
        "INSERT INTO bookmarks (url, desc, tags) VALUES (?1, ?2, ?3)",
        rusqlite::params![url, desc, tags],
    )
    .map_err(|e| match e {
        rusqlite::Error::SqliteFailure(ref err, _)
            if err.code == rusqlite::ErrorCode::ConstraintViolation =>
        {
            StorageError::Duplicate(format!("URL already exists: {}", url))
        }
        other => StorageError::Db(other),
    })?;
    Ok(conn.last_insert_rowid())
}

/// Delete the bookmark with the given `id`.
///
/// Errors:
/// - `StorageError::NotFound` if no bookmark with that id exists.
/// - `StorageError::Db` on any other database error.
pub fn remove_bookmark(conn: &rusqlite::Connection, id: i64) -> Result<(), StorageError> {
    let affected = conn
        .execute("DELETE FROM bookmarks WHERE id = ?1", rusqlite::params![id])
        .map_err(StorageError::Db)?;
    if affected == 0 {
        return Err(StorageError::NotFound(format!("no bookmark with id {}", id)));
    }
    Ok(())
}

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
) -> Result<Vec<Bookmark>, StorageError> {
    let mut stmt;
    let rows: Vec<Bookmark> = if query.is_empty() {
        stmt = conn
            .prepare(
                "SELECT id, url, desc, tags, created_at FROM bookmarks ORDER BY created_at DESC",
            )
            .map_err(StorageError::Db)?;
        stmt.query_map([], |row| {
            Ok(Bookmark {
                id: row.get(0)?,
                url: row.get(1)?,
                desc: row.get(2)?,
                tags: row.get(3)?,
                created_at: row.get(4)?,
            })
        })
        .map_err(StorageError::Db)?
        .collect::<Result<Vec<_>, _>>()
        .map_err(StorageError::Db)?
    } else {
        let pattern = format!("%{}%", query);
        stmt = conn
            .prepare(
                "SELECT id, url, desc, tags, created_at FROM bookmarks \
                 WHERE url LIKE ?1 OR desc LIKE ?1 OR tags LIKE ?1 \
                 ORDER BY created_at DESC",
            )
            .map_err(StorageError::Db)?;
        stmt.query_map(rusqlite::params![pattern], |row| {
            Ok(Bookmark {
                id: row.get(0)?,
                url: row.get(1)?,
                desc: row.get(2)?,
                tags: row.get(3)?,
                created_at: row.get(4)?,
            })
        })
        .map_err(StorageError::Db)?
        .collect::<Result<Vec<_>, _>>()
        .map_err(StorageError::Db)?
    };
    Ok(rows)
}

#[cfg(test)]
mod tests;
