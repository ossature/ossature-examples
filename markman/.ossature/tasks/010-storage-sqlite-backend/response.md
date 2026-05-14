All 10 tests pass. Here's a summary of what was done:

**`src/storage/mod.rs`** implements the storage backend as a module directory alongside the existing `src/storage/types.rs`:

- **`mod types; pub use types::{Bookmark, StorageError};`** — declares and re-exports the types from the sibling `types.rs` file so callers can use `storage::Bookmark` and `storage::StorageError` directly.

- **`init_db`** — opens (or creates) the SQLite database at the given path using `rusqlite::Connection::open`, then runs a `CREATE TABLE IF NOT EXISTS` DDL to ensure the `bookmarks` table exists. Maps `Open` errors to `StorageError::Open` and DDL errors to `StorageError::Db`.

- **`add_bookmark`** — validates the URL is non-blank (returning `StorageError::InvalidInput`), performs an `INSERT`, and maps SQLite constraint violations to `StorageError::Duplicate`, other errors to `StorageError::Db`. Returns the new row's id via `last_insert_rowid()`.

- **`remove_bookmark`** — executes a `DELETE WHERE id = ?1`, checks `affected == 0` to return `StorageError::NotFound`, otherwise maps any SQLite error to `StorageError::Db`.

- **`search_bookmarks`** — uses a branching prepare: empty query fetches all rows ordered by `created_at DESC`; non-empty query uses a `LIKE` pattern against `url`, `desc`, and `tags`. All row errors map to `StorageError::Db`.

The pre-existing flat `src/storage.rs` was removed since Rust's module system does not allow both `src/storage.rs` and `src/storage/mod.rs` to coexist.