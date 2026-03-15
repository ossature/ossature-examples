# Interface: WEBUI

@source: build

# Markman Public Interface

## src/lib.rs

```rust
pub mod storage;
pub mod commands;
pub mod web;

pub use storage::{Bookmark, StorageError};
pub use commands::{handle_add, handle_list, handle_remove};
```

## src/storage/mod.rs

```rust
pub struct Bookmark {
    pub id: i64,
    pub url: String,
    pub description: String,
    pub tags: String,
}

pub enum StorageError {
    DatabaseError(String),
    NotFound,
    // ... other variants
}

pub fn initialize_database(db_path: &str) -> Result<Connection, StorageError>;

pub fn search_bookmarks(conn: &Connection, query: &str) -> Result<Vec<Bookmark>, StorageError>;

pub fn add_bookmark(
    conn: &Connection,
    url: &str,
    description: &str,
    tags: &str,
) -> Result<i64, StorageError>;

pub fn remove_bookmark(conn: &Connection, id: i64) -> Result<(), StorageError>;

pub fn list_bookmarks(conn: &Connection) -> Result<Vec<Bookmark>, StorageError>;
```

## src/commands.rs

```rust
pub fn handle_add(db_path: &str, url: &str, description: &str, tags: &str) -> Result<(), String>;

pub fn handle_list(db_path: &str) -> Result<(), String>;

pub fn handle_remove(db_path: &str, id: i64) -> Result<(), String>;
```

## src/web.rs

```rust
pub async fn run_server(db_path: &str, port: u16) -> Result<(), String>;
```

## src/main.rs

```rust
fn main();
```