<error_output>
```
Checking markman v0.1.0 (/Users/beshr/src/code/ossature-examples/markman/output)
error[E0761]: file for module `storage` found at both "src/storage.rs" and "src/storage/mod.rs"
 --> src/lib.rs:1:1
  |
1 | pub mod storage;
  | ^^^^^^^^^^^^^^^^
  |
  = help: delete or rename one of them to remove the ambiguity

For more information about this error, try `rustc --explain E0761`.
error: could not compile `markman` (lib) due to 1 previous error
```
</error_output>

<verify_command>
cargo check
</verify_command>

<current_file path="src/lib.rs">
```
pub mod storage;
pub mod commands;
pub mod web;

pub use storage::{Bookmark, StorageError};
pub use commands::{handle_add, handle_list, handle_remove};

```
</current_file>

<current_file path="src/storage.rs">
```
use std::fmt;
use serde::{Deserialize, Serialize};
use rusqlite::Connection;

/// A bookmark entry with URL, description, and tags
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct Bookmark {
    pub id: i64,
    pub url: String,
    pub description: String,
    pub tags: String, // comma-separated
}

/// Errors that can occur during storage operations
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum StorageError {
    /// URL is empty or contains only whitespace
    InvalidUrl,
    /// URL already exists in the database
    DuplicateUrl,
    /// Database file could not be opened or created
    DatabaseOpenFailed,
    /// Database schema could not be initialized
    SchemaInitializationFailed,
    /// Bookmark with the given ID was not found
    BookmarkNotFound,
    /// Query execution failed
    QueryFailed,
    /// Generic database error
    DatabaseError,
}

impl fmt::Display for StorageError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            StorageError::InvalidUrl => write!(f, "Invalid URL: URL must not be empty"),
            StorageError::DuplicateUrl => write!(f, "Duplicate URL: A bookmark with this URL already exists"),
            StorageError::DatabaseOpenFailed => write!(f, "Failed to open database"),
            StorageError::SchemaInitializationFailed => write!(f, "Failed to initialize database schema"),
            StorageError::BookmarkNotFound => write!(f, "Bookmark not found"),
            StorageError::QueryFailed => write!(f, "Query execution failed"),
            StorageError::DatabaseError => write!(f, "Database error"),
        }
    }
}

impl std::error::Error for StorageError {}

/// Opens or creates a SQLite database file and initializes the bookmarks table schema.
///
/// # Arguments
///
/// * `db_path` - Path to the SQLite database file
///
/// # Returns
///
/// A `Result` containing the database `Connection` on success, or a `StorageError` on failure.
pub fn initialize_database(db_path: &str) -> Result<Connection, StorageError> {
    // Validate path is not empty
    if db_path.trim().is_empty() {
        return Err(StorageError::DatabaseOpenFailed);
    }

    // Open or create the database file
    let conn = Connection::open(db_path)
        .map_err(|_| StorageError::DatabaseOpenFailed)?;

    // Create the bookmarks table if it doesn't exist
    let schema = "CREATE TABLE IF NOT EXISTS bookmarks (
            id INTEGER PRIMARY KEY,
            url TEXT UNIQUE NOT NULL,
            description TEXT NOT NULL DEFAULT '',
            tags TEXT NOT NULL DEFAULT '',
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )";
    conn.execute(schema, [])
        .map_err(|_| StorageError::SchemaInitializationFailed)?;

    Ok(conn)
}

/// Adds a new bookmark to the database.
///
/// Returns the ID of the newly created bookmark on success.
/// Returns InvalidUrl if the URL is empty or whitespace.
/// Returns DuplicateUrl if the URL already exists.
/// Returns QueryFailed if the database operation fails.
///
/// # Arguments
///
/// * `conn` - Database connection
/// * `url` - The URL of the bookmark
/// * `description` - A description of the bookmark
/// * `tags` - Comma-separated tags for the bookmark
///
/// # Returns
///
/// A `Result` containing the ID of the newly created bookmark on success, or a `StorageError` on failure.
pub fn add_bookmark(
    conn: &Connection,
    url: String,
    description: String,
    tags: String,
) -> Result<i64, StorageError> {
    if url.trim().is_empty() {
        return Err(StorageError::InvalidUrl);
    }

    let mut stmt = conn
        .prepare("SELECT id FROM bookmarks WHERE url = ?1")
        .map_err(|_| StorageError::QueryFailed)?;

    let exists = stmt
        .exists([&url])
        .map_err(|_| StorageError::QueryFailed)?;

    if exists {
        return Err(StorageError::DuplicateUrl);
    }

    conn.execute(
        "INSERT INTO bookmarks (url, description, tags) VALUES (?1, ?2, ?3)",
        rusqlite::params![&url, &description, &tags],
    )
    .map_err(|_| StorageError::QueryFailed)?;

    Ok(conn.last_insert_rowid())
}

/// Deletes a bookmark by ID.
///
/// Returns BookmarkNotFound if the bookmark does not exist.
/// Returns QueryFailed if the database operation fails.
///
/// # Arguments
///
/// * `conn` - Database connection
/// * `id` - ID of the bookmark to delete
///
/// # Returns
///
/// A `Result` containing `()` on success, or a `StorageError` on failure.
pub fn remove_bookmark(conn: &Connection, id: i64) -> Result<(), StorageError> {
    let mut stmt = conn
        .prepare("SELECT id FROM bookmarks WHERE id = ?1")
        .map_err(|_| StorageError::QueryFailed)?;

    let exists = stmt
        .exists([id])
        .map_err(|_| StorageError::QueryFailed)?;

    if !exists {
        return Err(StorageError::BookmarkNotFound);
    }

    conn.execute("DELETE FROM bookmarks WHERE id = ?1", rusqlite::params![id])
        .map_err(|_| StorageError::QueryFailed)?;

    Ok(())
}

/// Searches for bookmarks using case-insensitive substring matching.
///
/// Searches across URL, description, and tags fields using SQLite LIKE.
/// If the query is empty, returns all bookmarks.
/// Results are ordered by created_at descending.
///
/// # Arguments
///
/// * `conn` - Database connection
/// * `query` - Search query (case-insensitive, empty returns all)
///
/// # Returns
///
/// A `Result` containing a vector of matching `Bookmark` structs, or a `StorageError` on failure.
pub fn search_bookmarks(
    conn: &Connection,
    query: &str,
) -> Result<Vec<Bookmark>, StorageError> {
    let query_trimmed = query.trim();

    if query_trimmed.is_empty() {
        let mut stmt = conn
            .prepare("SELECT id, url, description, tags FROM bookmarks ORDER BY created_at DESC")
            .map_err(|_| StorageError::QueryFailed)?;

        let bookmarks = stmt
            .query_map([], |row| {
                Ok(Bookmark {
                    id: row.get(0)?,
                    url: row.get(1)?,
                    description: row.get(2)?,
                    tags: row.get(3)?,
                })
            })
            .map_err(|_| StorageError::QueryFailed)?
            .collect::<Result<Vec<_>, _>>()
            .map_err(|_| StorageError::QueryFailed)?;

        Ok(bookmarks)
    } else {
        let pattern = format!("%{}%", query_trimmed);
        let mut stmt = conn
            .prepare(
                "SELECT id, url, description, tags FROM bookmarks \
                 WHERE url LIKE ?1 OR description LIKE ?1 OR tags LIKE ?1 \
                 ORDER BY created_at DESC"
            )
            .map_err(|_| StorageError::QueryFailed)?;

        let bookmarks = stmt
            .query_map(rusqlite::params![&pattern], |row| {
                Ok(Bookmark {
                    id: row.get(0)?,
                    url: row.get(1)?,
                    description: row.get(2)?,
                    tags: row.get(3)?,
                })
            })
            .map_err(|_| StorageError::QueryFailed)?
            .collect::<Result<Vec<_>, _>>()
            .map_err(|_| StorageError::QueryFailed)?;

        Ok(bookmarks)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn setup_test_db() -> Connection {
        initialize_database(":memory:").expect("Failed to create in-memory database")
    }

    #[test]
    fn test_database_initialization() {
        let result = initialize_database(":memory:");
        assert!(result.is_ok());
    }

    #[test]
    fn test_database_already_exists() {
        let _conn1 = initialize_database(":memory:").expect("First initialization failed");
        let _conn2 = initialize_database(":memory:").expect("Second initialization failed");
    }

    #[test]
    fn test_initialize_with_empty_path() {
        let result = initialize_database("");
        assert!(matches!(result, Err(StorageError::DatabaseOpenFailed)));
    }

    #[test]
    fn test_initialize_with_whitespace_path() {
        let result = initialize_database("   ");
        assert!(matches!(result, Err(StorageError::DatabaseOpenFailed)));
    }

    #[test]
    fn test_add_bookmark_success() {
        let conn = setup_test_db();
        let result = add_bookmark(
            &conn,
            "https://example.com".to_string(),
            "Example site".to_string(),
            "example,web".to_string(),
        );
        assert!(result.is_ok());
        assert!(result.unwrap() > 0);
    }

    #[test]
    fn test_add_bookmark_with_empty_url() {
        let conn = setup_test_db();
        let result = add_bookmark(
            &conn,
            "".to_string(),
            "Description".to_string(),
            "tags".to_string(),
        );
        assert_eq!(result, Err(StorageError::InvalidUrl));
    }

    #[test]
    fn test_add_bookmark_with_whitespace_url() {
        let conn = setup_test_db();
        let result = add_bookmark(
            &conn,
            "   ".to_string(),
            "Description".to_string(),
            "tags".to_string(),
        );
        assert_eq!(result, Err(StorageError::InvalidUrl));
    }

    #[test]
    fn test_duplicate_url_detection() {
        let conn = setup_test_db();
        let url = "https://example.com".to_string();

        add_bookmark(&conn, url.clone(), "First".to_string(), "tags1".to_string())
            .expect("First add failed");

        let result = add_bookmark(&conn, url, "Second".to_string(), "tags2".to_string());
        assert_eq!(result, Err(StorageError::DuplicateUrl));
    }

    #[test]
    fn test_search_empty_query_returns_all() {
        let conn = setup_test_db();

        add_bookmark(&conn, "https://example1.com".to_string(), "Example 1".to_string(), "tag1".to_string())
            .expect("Add 1 failed");
        add_bookmark(&conn, "https://example2.com".to_string(), "Example 2".to_string(), "tag2".to_string())
            .expect("Add 2 failed");
        add_bookmark(&conn, "https://example3.com".to_string(), "Example 3".to_string(), "tag3".to_string())
            .expect("Add 3 failed");

        let result = search_bookmarks(&conn, "");
        assert!(result.is_ok());
        let bookmarks = result.unwrap();
        assert_eq!(bookmarks.len(), 3);
    }

    #[test]
    fn test_search_whitespace_query_returns_all() {
        let conn = setup_test_db();

        add_bookmark(&conn, "https://example1.com".to_string(), "Example 1".to_string(), "tag1".to_string())
            .expect("Add 1 failed");
        add_bookmark(&conn, "https://example2.com".to_string(), "Example 2".to_string(), "tag2".to_string())
            .expect("Add 2 failed");

        let result = search_bookmarks(&conn, "   ");
        assert!(result.is_ok());
        let bookmarks = result.unwrap();
        assert_eq!(bookmarks.len(), 2);
    }

    #[test]
    fn test_search_by_url() {
        let conn = setup_test_db();

        add_bookmark(&conn, "https://example.com".to_string(), "Example".to_string(), "tags".to_string())
            .expect("Add failed");
        add_bookmark(&conn, "https://other.com".to_string(), "Other".to_string(), "tags".to_string())
            .expect("Add failed");

        let result = search_bookmarks(&conn, "example");
        assert!(result.is_ok());
        let bookmarks = result.unwrap();
        assert_eq!(bookmarks.len(), 1);
        assert_eq!(bookmarks[0].url, "https://example.com");
    }

    #[test]
    fn test_search_by_description() {
        let conn = setup_test_db();

        add_bookmark(&conn, "https://example.com".to_string(), "Example description".to_string(), "tags".to_string())
            .expect("Add failed");
        add_bookmark(&conn, "https://other.com".to_string(), "Other content".to_string(), "tags".to_string())
            .expect("Add failed");

        let result = search_bookmarks(&conn, "description");
        assert!(result.is_ok());
        let bookmarks = result.unwrap();
        assert_eq!(bookmarks.len(), 1);
        assert_eq!(bookmarks[0].description, "Example description");
    }

    #[test]
    fn test_search_by_tags() {
        let conn = setup_test_db();

        add_bookmark(&conn, "https://example.com".to_string(), "Example".to_string(), "important,urgent".to_string())
            .expect("Add failed");
        add_bookmark(&conn, "https://other.com".to_string(), "Other".to_string(), "casual,reading".to_string())
            .expect("Add failed");

        let result = search_bookmarks(&conn, "urgent");
        assert!(result.is_ok());
        let bookmarks = result.unwrap();
        assert_eq!(bookmarks.len(), 1);
        assert_eq!(bookmarks[0].tags, "important,urgent");
    }

    #[test]
    fn test_search_case_insensitive() {
        let conn = setup_test_db();

        add_bookmark(&conn, "https://EXAMPLE.COM".to_string(), "Example".to_string(), "tags".to_string())
            .expect("Add failed");

        let result1 = search_bookmarks(&conn, "example");
        let result2 = search_bookmarks(&conn, "EXAMPLE");
        let result3 = search_bookmarks(&conn, "Example");

        assert_eq!(result1.unwrap().len(), 1);
        assert_eq!(result2.unwrap().len(), 1);
        assert_eq!(result3.unwrap().len(), 1);
    }

    #[test]
    fn test_search_matches_multiple_fields() {
        let conn = setup_test_db();

        add_bookmark(&conn, "https://example.com".to_string(), "Test description".to_string(), "tags".to_string())
            .expect("Add 1 failed");
        add_bookmark(&conn, "https://other.com".to_string(), "Other description".to_string(), "test,important".to_string())
            .expect("Add 2 failed");

        let result = search_bookmarks(&conn, "test");
        assert!(result.is_ok());
        let bookmarks = result.unwrap();
        assert_eq!(bookmarks.len(), 2);
    }

    #[test]
    fn test_search_no_matches() {
        let conn = setup_test_db();

        add_bookmark(&conn, "https://example.com".to_string(), "Example".to_string(), "tags".to_string())
            .expect("Add failed");

        let result = search_bookmarks(&conn, "nonexistent");
        assert!(result.is_ok());
        let bookmarks = result.unwrap();
        assert_eq!(bookmarks.len(), 0);
    }

    #[test]
    fn test_remove_bookmark_success() {
        let conn = setup_test_db();

        let id = add_bookmark(&conn, "https://example.com".to_string(), "Example".to_string(), "tags".to_string())
            .expect("Add failed");

        let result = remove_bookmark(&conn, id);
        assert!(result.is_ok());

        // Verify it's actually deleted
        let bookmarks = search_bookmarks(&conn, "").expect("Search failed");
        assert_eq!(bookmarks.len(), 0);
    }

    #[test]
    fn test_remove_bookmark_not_found() {
        let conn = setup_test_db();

        let result = remove_bookmark(&conn, 999);
        assert_eq!(result, Err(StorageError::BookmarkNotFound));
    }

    #[test]
    fn test_remove_bookmark_already_deleted() {
        let conn = setup_test_db();

        let id = add_bookmark(&conn, "https://example.com".to_string(), "Example".to_string(), "tags".to_string())
            .expect("Add failed");

        remove_bookmark(&conn, id).expect("First remove failed");

        // Try to remove again
        let result = remove_bookmark(&conn, id);
        assert_eq!(result, Err(StorageError::BookmarkNotFound));
    }

    #[test]
    fn test_search_multiple_bookmarks_returns_all() {
        let conn = setup_test_db();

        add_bookmark(&conn, "https://example1.com".to_string(), "First".to_string(), "tags".to_string())
            .expect("Add 1 failed");
        add_bookmark(&conn, "https://example2.com".to_string(), "Second".to_string(), "tags".to_string())
            .expect("Add 2 failed");
        add_bookmark(&conn, "https://example3.com".to_string(), "Third".to_string(), "tags".to_string())
            .expect("Add 3 failed");

        let result = search_bookmarks(&conn, "").expect("Search failed");
        let bookmarks = result;
        assert_eq!(bookmarks.len(), 3);

        // Verify all bookmarks are returned
        let urls: Vec<String> = bookmarks.iter().map(|b| b.url.clone()).collect();
        assert!(urls.contains(&"https://example1.com".to_string()));
        assert!(urls.contains(&"https://example2.com".to_string()));
        assert!(urls.contains(&"https://example3.com".to_string()));
    }

    #[test]
    fn test_bookmark_fields_preserved() {
        let conn = setup_test_db();

        let url = "https://example.com".to_string();
        let description = "My test bookmark".to_string();
        let tags = "rust,learning,important".to_string();

        let id = add_bookmark(&conn, url.clone(), description.clone(), tags.clone())
            .expect("Add failed");

        let bookmarks = search_bookmarks(&conn, "example").expect("Search failed");
        assert_eq!(bookmarks.len(), 1);
        assert_eq!(bookmarks[0].id, id);
        assert_eq!(bookmarks[0].url, url);
        assert_eq!(bookmarks[0].description, description);
        assert_eq!(bookmarks[0].tags, tags);
    }
}

```
</current_file>

<task>
**Bookmark Data Types & Storage Interface**: Define the Bookmark struct and storage-related types needed by the web server to query and display bookmarks. This must exist before the web server implementation references storage.
</task>