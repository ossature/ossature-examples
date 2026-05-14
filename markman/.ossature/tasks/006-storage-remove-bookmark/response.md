The implementation is complete. Here's what `remove_bookmark` does:

1. **Executes `DELETE FROM bookmarks WHERE id = ?1`** using the provided `id` as a bound parameter.
2. **Maps any SQLite-level error** to `StorageError::Db` via `.map_err(StorageError::Db)`.
3. **Checks `affected == 0`** — if no rows were deleted, the id didn't exist, so it returns `StorageError::NotFound(...)` with a descriptive message embedding the id.
4. **Returns `Ok(())`** on success.

The `NotFound` variant holds a `String` (matching the existing definition), so the id is embedded via `format!` — consistent with how the rest of the module uses that variant.