# Interface: STORAGE

@source: build

# STORAGE Module Public Interface

## src/storage.rs

### Types

```rust
/// A bookmark entry with URL, description, and tags
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Bookmark {
    pub id: i64,
    pub url: String,
    pub description: String,
    pub tags: String,
}
```

### Error Types

```rust
/// Errors that can occur during storage operations
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum StorageError {
    InvalidUrl,
    DuplicateUrl,
    DatabaseOpenFailed,
    SchemaInitializationFailed,
    BookmarkNotFound,
    QueryFailed,
    DatabaseError,
}

impl fmt::Display for StorageError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result { ... }
}

impl std::error::Error for StorageError {}
```

### Functions

```rust
/// Opens or creates a SQLite database file and initializes the bookmarks table schema.
pub fn initialize_database(db_path: &str) -> Result<Connection, StorageError>;

/// Adds a new bookmark to the database.
/// 
/// Returns the ID of the newly created bookmark on success.
/// Returns InvalidUrl if the URL is empty or whitespace.
/// Returns DuplicateUrl if the URL already exists.
/// Returns QueryFailed if the database operation fails.
pub fn add_bookmark(
    conn: &Connection,
    url: String,
    description: String,
    tags: String,
) -> Result<i64, StorageError>;

/// Deletes a bookmark by ID.
///
/// Returns BookmarkNotFound if the bookmark does not exist.
/// Returns QueryFailed if the database operation fails.
pub fn remove_bookmark(conn: &Connection, id: i64) -> Result<(), StorageError>;

/// Searches for bookmarks using case-insensitive substring matching.
///
/// Searches across URL, description, and tags fields using SQLite LIKE.
/// If the query is empty, returns all bookmarks.
/// Results are ordered by created_at descending.
pub fn search_bookmarks(
    conn: &Connection,
    query: &str,
) -> Result<Vec<Bookmark>, StorageError>;
```