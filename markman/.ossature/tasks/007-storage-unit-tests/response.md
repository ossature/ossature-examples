All 10 tests pass. Here's what was added to `src/storage.rs`:

**`#[cfg(test)]` module with 10 tests covering all required scenarios:**

| Test | Requirement |
|---|---|
| `test_db_creation` | Database file created on first run (`:memory:` variant) |
| `test_add_and_search_round_trip` | Add + search round-trip; verifies all fields including `id` and non-empty `created_at` |
| `test_empty_query_returns_all` | Empty query returns every row (3 inserted → 3 returned) |
| `test_non_empty_query_filters_by_url` | Non-empty query filters by `url` |
| `test_non_empty_query_filters_by_desc` | Non-empty query filters by `desc` |
| `test_non_empty_query_filters_by_tags` | Non-empty query filters by `tags` |
| `test_duplicate_url_returns_duplicate_error` | Duplicate URL → `StorageError::Duplicate` |
| `test_remove_unknown_id_returns_not_found` | Unknown id → `StorageError::NotFound` |
| `test_remove_existing_bookmark` | Successful remove leaves table empty |
| `test_add_empty_url_returns_invalid_input` | Whitespace-only URL → `StorageError::InvalidInput` |

All tests use `:memory:` via a shared `open_in_memory()` helper so they run in isolation with no filesystem side-effects.