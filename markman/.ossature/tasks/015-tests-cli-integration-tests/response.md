All 17 tests pass. Here's a summary of what was implemented:

## `tests/cli.rs`

The integration test suite invokes the compiled `markman` binary as a subprocess (via `std::process::Command`) and asserts stdout, stderr, and exit codes. It uses `tempfile::NamedTempFile` for isolated, throwaway SQLite databases so tests don't interfere with each other.

**Tests covered:**

| Subcommand | Scenario | Exit code |
|---|---|---|
| `add` | Basic add with URL only | 0 |
| `add` | Add with `--desc` and `--tags` | 0 |
| `add` | Duplicate URL | 1 + `error:` on stderr |
| `add` | Missing URL argument | 2 (clap error) |
| `list` | Empty database | 0, `"no bookmarks found."` |
| `list` | Shows bookmark in `[id] url \| desc \| tags: …` format | 0 |
| `list` | Exact format assertion | 0 |
| `list` | Query that matches | 0, filtered results |
| `list` | Query with no match | 0, `"no bookmarks found."` |
| `remove` | Existing id | 0, `"removed: 1"` + bookmark gone |
| `remove` | Unknown id | 1 + `error:` on stderr |
| `remove` | Missing id argument | 2 (clap error) |
| `remove` | Non-integer id | 2 (clap error) |
| `remove` | Zero id | 2 |
| `remove` | Negative id | 2 |
| `--db` | Two separate databases stay isolated | 0 |
| unknown subcommand | Bogus command | non-zero |

A `tempfile = "3"` dev-dependency was added to `Cargo.toml` to support isolated per-test databases.