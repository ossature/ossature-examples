All acceptance criteria are covered. Here's the summary of what was implemented in `src/web/mod.rs`:

**Acceptance criteria coverage:**

| Criteria | Implementation |
|---|---|
| `GET /` returns all bookmarks as HTML table | `"/"` arm calls `search_bookmarks(conn, "")` and renders with `render_page` |
| `GET /?q=<term>` returns matching bookmarks | `parse_q` extracts `q` from query string; passed to `search_bookmarks` |
| All HTML/CSS embedded — no disk reads | `HTML_TEMPLATE` and CSS are `const &str` literals |
| URLs rendered as clickable `<a>` links | `render_rows` wraps each URL in `<a href="..." target="_blank">` |
| Empty set shows "No bookmarks found." | `render_rows` returns a `colspan="3"` row when the slice is empty |
| `GET /health` returns 200 with body "ok" | Explicit `"/health"` match arm |
| 404 catch-all | `_` arm returns 404 plain text |
| HTTP 500 on DB read failure | `Err(_)` branch returns `"internal server error"` with status 500 |
| HTML-escape `q` in input `value` attribute | `html_escape(query)` used in `render_page` |
| HTML-escape bookmark fields | `html_escape` applied to url/desc/tags in `render_rows` |
| Search form uses `method="get"` and `action="/"` | Present in `HTML_TEMPLATE` |