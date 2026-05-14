Build succeeds cleanly. Here's what `src/main.rs` does:

- **`resolve_db_path`** — expands a leading `~/` using `$HOME`, falling back to `.` if `HOME` is unset; everything else passes through verbatim.
- **`add`** — opens the DB, calls `add_bookmark`, prints `added: <url>` on success, or prints the `StorageError` and exits 1.
- **`list`** — opens the DB, calls `search_bookmarks`, prints each bookmark as `[<id>] <url> | <desc> | tags: <tags>`, or `"no bookmarks found."` if the result is empty. Storage errors exit 1.
- **`remove`** — rejects `id <= 0` immediately with exit code 2 and the required message, then calls `remove_bookmark`; storage errors (including `NotFound`) exit 1.
- **`serve`** — opens the DB and delegates entirely to `web::serve(conn, port)`, which already handles the port-in-use error message and the `"listening on …"` print.