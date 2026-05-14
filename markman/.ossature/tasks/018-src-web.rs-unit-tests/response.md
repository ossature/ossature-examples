All 48 tests pass (38 web tests + 10 storage tests) plus 17 CLI integration tests. Here's a summary of what the `#[cfg(test)]` module covers:

**HTML generation with bookmarks present** — `test_render_rows_with_bookmarks`, `test_render_page_contains_bookmark_data`: verifies URLs, descriptions, and tags appear in output.

**No bookmarks shows "No bookmarks found."** — `test_render_rows_empty_shows_no_bookmarks_found`, `test_render_page_empty_bookmarks_shows_no_results`: checks the `.no-results` row with `colspan="3"`.

**Case-insensitive substring filtering** — `test_filtering_by_url_case_insensitive`, `test_filtering_by_desc_case_insensitive`, `test_filtering_by_tags_case_insensitive`, `test_filtering_no_match_returns_empty`, `test_filtering_empty_query_returns_all`: exercises `storage::search_bookmarks` against an in-memory DB.

**`q` value pre-filled in input** — `test_render_page_prefills_query_in_input`, `test_render_page_prefills_empty_query_when_no_search`: checks `value="rust"` appears in the rendered `<input>`.

**HTML-escaping of special characters** — `test_html_escape_*` for individual characters, plus `test_render_rows_escapes_special_chars_in_url/desc/tags` and `test_render_page_escapes_query_in_input_value`/`test_render_page_escapes_double_quote_in_query`: ensures `&`, `<`, `>`, `"` are all safely escaped in both bookmark fields and the query parameter.