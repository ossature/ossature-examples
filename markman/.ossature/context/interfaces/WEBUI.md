# Interface: WEBUI

@source: build

# `src/web.rs` Public Interface

```rust
use rusqlite::Connection;

/// Start the HTTP server bound to `addr`, serving bookmarks from `conn`.
/// Blocks the calling thread indefinitely.
pub fn run(addr: &str, conn: Connection);

/// Convenience wrapper used by the CLI `serve` subcommand.
/// Binds to `0.0.0.0:{port}`. Exits the process if the port is already in use.
/// Blocks the calling thread indefinitely.
pub fn serve(conn: Connection, port: u16);
```