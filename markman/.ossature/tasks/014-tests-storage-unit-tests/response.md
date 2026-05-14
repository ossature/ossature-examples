All 15 tests pass. Here's what was produced:

**`src/storage/tests.rs`** — a separate test file wired into `mod.rs` via `#[cfg(test)] mod tests;`, covering:

| Test | Requirement |
|---|---|
| `test_db_creation` | Schema initialises cleanly with 0 rows |
| `test_add_and_search_round_trip` | Add a bookmark, retrieve it with all fields intact |
| `test_list_all_returns_empty_when_no_bookmarks` | List on empty DB returns empty vec |
| `test_empty_query_returns_all` | Empty query → all rows returned |
| `test_query_filters_by_url` | Query matches against `url` field |
| `test_query_filters_by_desc` | Query matches against `desc` field |
| `test_query_filters_by_tags` | Query matches against `tags` field |
| `test_query_is_case_insensitive` | LIKE match is case-insensitive |
| `test_query_no_match_returns_empty` | Non-matching query returns empty vec |
| `test_duplicate_url_returns_duplicate_error` | Second insert with same URL → `StorageError::Duplicate` |
| `test_remove_unknown_id_returns_not_found` | Remove non-existent id → `StorageError::NotFound` |
| `test_remove_existing_bookmark` | Remove by id deletes the row |
| `test_remove_does_not_affect_other_bookmarks` | Remove is id-scoped, doesn't touch other rows |
| `test_add_empty_url_returns_invalid_input` | Blank/whitespace URL → `StorageError::InvalidInput` |
| `test_add_with_empty_desc_and_tags` | Empty `desc`/`tags` strings are stored as-is |