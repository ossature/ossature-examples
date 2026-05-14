All 33 tests pass. Here's a summary of what was done and why:

---

### Root cause

`cargo test --lib web` looks for a **library target** (`[lib]`) in `Cargo.toml`. The project only had a `[[bin]]` target, so the toolchain immediately bailed with:

```
error: no library targets found in package `markman`
```

The `#[cfg(test)]` block in `src/web.rs` was already correct — the problem was purely the missing library target, not the test code itself.

### Fix (3 minimal changes)

1. **`src/lib.rs` (new file)** — A thin library root that publicly re-exports the three existing modules (`cli`, `storage`, `web`). This makes `src/lib.rs` the library target entry point.

2. **`Cargo.toml`** — Added a `[lib]` section pointing at `src/lib.rs`, alongside the existing `[[bin]]` entry. Cargo now knows the crate has both a library and a binary target.

3. **`src/main.rs`** — Replaced the `mod cli; mod storage; mod web;` declarations (which would conflict with the library's own module ownership) with `use markman::{cli, storage, web};` — consuming them from the library crate instead of re-declaring them.