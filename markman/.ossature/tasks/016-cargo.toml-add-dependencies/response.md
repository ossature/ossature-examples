The `Cargo.toml` now has all required dependencies:

- **`tiny_http = "0.12"`** — already present; the HTTP server crate (no async runtime needed)
- **`urlencoding = "2"`** — added; decodes percent-encoded query strings from GET parameters (e.g. `?q=rust+lang` → `"rust lang"`)
- **`html-escape = "0.2"`** — added; escapes user-supplied data (URLs, descriptions, tags) before interpolating into HTML to prevent XSS-style rendering issues

The `web` module path (`mod web;`) was already declared in `src/main.rs`, so no changes there were needed.