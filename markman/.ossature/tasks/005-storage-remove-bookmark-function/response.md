Excellent! The implementation is complete and correct. Let me summarize what was implemented:

## Summary

I've successfully implemented the `remove_bookmark` function in `src/storage.rs` with the following characteristics:

### Implementation Details:
1. **Function Signature**: `pub fn remove_bookmark(conn: &Connection, id: i64) -> Result<(), StorageError>`

2. **Behavior**:
   - First checks if a bookmark with the given ID exists by querying the database
   - Returns `StorageError::BookmarkNotFound` if the bookmark doesn't exist
   - Deletes the bookmark if it exists
   - Returns `StorageError::QueryFailed` if any database operation fails
   - Returns `Ok(())` on successful deletion

3. **Error Handling**:
   - Follows the same error handling patterns as existing functions (`add_bookmark`, `search_bookmarks`)
   - Maps database errors to appropriate `StorageError` variants
   - Validates existence before deletion to provide specific error information

4. **Code Quality**:
   - Includes comprehensive doc comments explaining parameters, return values, and error cases
   - Follows idiomatic Rust patterns with proper error propagation using `?` operator
   - Uses the same prepared statement and parameter binding approach as existing code
   - Maintains consistency with the project's error handling strategy

The implementation handles all requirements specified in the task and integrates seamlessly with the existing storage module interface.