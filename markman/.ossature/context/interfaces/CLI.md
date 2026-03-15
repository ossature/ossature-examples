# Interface: CLI

@source: build

# CLI Public Interface

## src/main.rs

```rust
#[derive(Parser)]
pub struct Cli {
    pub db: Option<PathBuf>,
    pub command: Commands,
}

#[derive(Subcommand)]
pub enum Commands {
    Add {
        url: String,
        description: String,
        tags: String,
    },
    List {
        query: Option<String>,
    },
    Remove {
        id: i64,
    },
    Serve {
        port: u16,
    },
}

pub fn main() { ... }
```

## src/storage/mod.rs

```rust
pub use types::{Bookmark, StorageError};

pub fn initialize_database(db_path: &str) -> Result<Connection, StorageError> { ... }

pub fn add_bookmark(
    conn: &Connection,
    url: String,
    description: String,
    tags: String,
) -> Result<i64, StorageError> { ... }

pub fn remove_bookmark(conn: &Connection, id: i64) -> Result<(), StorageError> { ... }

pub fn search_bookmarks(
    conn: &Connection,
    query: &str,
) -> Result<Vec<Bookmark>, StorageError> { ... }
```

## src/storage/types.rs

```rust
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct Bookmark {
    pub id: i64,
    pub url: String,
    pub description: String,
    pub tags: String,
}

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

impl fmt::Display for StorageError { ... }
impl std::error::Error for StorageError { ... }
```

## src/storage/memory.rs

```rust
pub struct MemoryStorage {
    bookmarks: Mutex<HashMap<i64, Bookmark>>,
    next_id: Mutex<i64>,
}

impl MemoryStorage {
    pub fn new() -> Self { ... }

    pub fn add_bookmark(
        &self,
        url: String,
        description: String,
        tags: String,
    ) -> Result<i64, StorageError> { ... }

    pub fn remove_bookmark(&self, id: i64) -> Result<(), StorageError> { ... }

    pub fn search_bookmarks(&self, query: &str) -> Result<Vec<Bookmark>, StorageError> { ... }
}

impl Default for MemoryStorage {
    fn default() -> Self { ... }
}
```

## src/commands/add.rs

```rust
pub fn handle(
    db_path: &str,
    url: String,
    description: String,
    tags: String,
) -> Result<(), String> { ... }
```

## src/commands/list.rs

```rust
pub fn handle(db_path: &str, query: &str) -> Result<(), String> { ... }
```

## src/commands/remove.rs

```rust
pub fn handle(db_path: &str, id: i64) -> Result<(), String> { ... }
```

## src/commands/mod.rs

```rust
pub mod add;
pub mod list;
pub mod remove;

pub use add::handle as handle_add;
pub use list::handle as handle_list;
pub use remove::handle as handle_remove;
```

## src/web/mod.rs

```rust
pub mod serve;

pub use serve::run_server;
```

## src/web/serve.rs

```rust
#[derive(Clone)]
pub struct AppState {
    db_path: String,
}

#[derive(Deserialize)]
pub struct SearchQuery {
    q: Option<String>,
}

pub async fn run_server(db_path: &str, port: u16) -> Result<(), String> { ... }

pub struct ApiError(String);

impl ApiError {
    pub fn database_error(msg: String) -> Self { ... }
}

impl IntoResponse for ApiError { ... }
impl From<String> for ApiError { ... }
```