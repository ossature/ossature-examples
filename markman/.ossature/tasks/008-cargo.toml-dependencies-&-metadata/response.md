All dependencies resolve successfully. The `Cargo.toml` is complete with:

- **`rusqlite = { version = "0.31", features = ["bundled"] }`** — SQLite storage with the SQLite C library bundled (no system dependency)
- **`clap = { version = "4", features = ["derive"] }`** — CLI argument parsing with derive macros for `add`, `list`, `remove`, `serve` subcommands
- **`tiny_http = "0.12"`** — minimal, dependency-light HTTP server for the read-only web UI (no async runtime, no JS framework needed)
- **`edition = "2021"`** — corrected from the invalid `"2024"` that was in the original stub
- **`[[bin]]`** — explicit binary target named `markman` pointing to `src/main.rs`