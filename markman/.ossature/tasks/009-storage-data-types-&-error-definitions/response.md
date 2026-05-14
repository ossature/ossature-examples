The file defines:

- **`Bookmark`** — `Clone + Debug` struct with all five public fields (`id`, `url`, `desc`, `tags`, `created_at`) matching the interface exactly.
- **`StorageError`** — five variants wrapping either a `rusqlite::Error` or a `String` message, matching the interface exactly.
- **`Display`** — human-readable messages for each variant, suitable for the CLI to delegate to (e.g. "error: duplicate bookmark: …").
- **`std::error::Error`** — blanket impl with no `source()` override needed since the variants are self-contained for display purposes.