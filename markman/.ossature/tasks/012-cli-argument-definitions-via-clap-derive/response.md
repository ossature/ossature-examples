The implementation covers all spec requirements:

- **`Cli` struct**: top-level `--db` flag with `global = true` (propagates to all subcommands automatically) and `default_value = "~/.markman.db"`. The default is stored as the literal string `~/.markman.db` — path expansion to the actual home directory is left to the caller in `main.rs`, as is idiomatic.

- **`add`**: positional `url` (required), `-d`/`--desc` (optional, default `""`), `-t`/`--tags` (optional, default `""`).

- **`list`**: optional positional `query` (default `""`).

- **`remove`**: positional `id` as `i64` (required); clap will reject non-integer values at parse time, letting `main.rs` emit the specified error message.

- **`serve`**: `-p`/`--port` (optional `u16`, default `3000`). No duplicate `--db` flag — the global one on `Cli` is used, resolving the ambiguity noted in the task.