Done. The changes made:

- Corrected `version` to `"0.0.1"` to match the project config
- Added `rusqlite = { version = "0.31", features = ["bundled"] }` — the `bundled` feature compiles SQLite directly into the binary, satisfying the constraint that no system SQLite is required