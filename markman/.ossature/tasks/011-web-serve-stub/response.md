Clean build — only `dead_code` warnings from functions not yet wired into `main.rs`, which is expected at this stage. The implementation is complete.

Here's a summary of what `src/web/mod.rs` implements:

**`pub fn serve(conn: Connection, port: u16)`**
- Attempts to bind `tiny_http::Server` to `0.0.0.0:<port>`
- On bind failure: detects "address already in use" in the error message, prints `"error: port <port> is already in use"` to stderr, and exits with code 1 (any other bind error also exits 1 with its message)
- On success: prints `"listening on http://0.0.0.0:<port>"` to stdout, then enters the blocking request loop

**Request handling:**
- Parses `?q=<value>` from the URL (with `+`-space and `%XX` percent-decoding)
- Calls `storage::search_bookmarks` with the query; returns HTTP 500 on error
- Renders a self-contained HTML page (embedded `STYLE` constant, no JS, no external files) with a search form and bookmark list