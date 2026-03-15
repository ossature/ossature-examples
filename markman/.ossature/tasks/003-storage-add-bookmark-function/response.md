Perfect! Let me verify the implementation compiles and meets all requirements:

1. ✅ **Non-empty URL validation**: The function checks `url.trim().is_empty()` and returns `InvalidUrl` if true
2. ✅ **Duplicate URL check**: Queries the database to see if the URL already exists and returns `DuplicateUrl` if it does
3. ✅ **Insertion**: Inserts the bookmark with URL, description, and tags into the database
4. ✅ **Row ID return**: Returns `Ok(conn.last_insert_rowid())` on success
5. ✅ **Error handling**: Returns appropriate `StorageError` variants for each failure case
6. ✅ **Result type**: Returns `Result<i64, StorageError>` as specified

The implementation follows the specification requirements:
- Validates non-empty URL
- Checks for duplicates  
- Returns the row id on success
- Uses the existing `StorageError` enum for error cases
- Accepts a database connection reference (for flexibility in connection management by callers)
- Uses idiomatic Rust with proper error mapping via `map_err`