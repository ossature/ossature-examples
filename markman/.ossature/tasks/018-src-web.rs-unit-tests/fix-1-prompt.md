<error_output>
```
error: no library targets found in package `markman`
```
</error_output>

<verify_command>
cargo test --lib web
</verify_command>

<current_file path="src/web.rs" total_lines="507">
File is large. Use `read_lines` or `grep_file` to inspect the regions referenced in the error output above.
</current_file>

<task>
**src/web.rs: Unit tests**: Add `#[cfg(test)]` unit tests inside `src/web.rs` covering: HTML generation with bookmarks present, HTML generation with no bookmarks (shows 'No bookmarks found.' row), case-insensitive substring filtering against url/desc/tags, the `q` value being pre-filled in the rendered input, and correct HTML-escaping of special characters in the query parameter and bookmark fields.
</task>