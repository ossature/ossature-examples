# Markman

Markman is a command-line bookmark manager written in Rust. It stores bookmarks in a local SQLite database (defaulting to `~/.markman.db`) and supports adding, listing, searching, and removing bookmarks via subcommands. It also includes a `serve` subcommand that starts a minimal, read-only web UI for browsing and searching bookmarks in a browser — all HTML and CSS are embedded in the binary with no external assets or JavaScript required. The project uses `clap` for CLI parsing, `rusqlite` (with the `bundled` feature) for SQLite storage, and `tiny_http` for the web server.

This project was created and built entirely with [Ossature](https://ossature.dev). See the [main README](../README.md#what-to-look-for) for a guide to exploring the `.ossature/` directory and understanding the artifacts Ossature produces at each stage.

## Project Structure

```
specs/
├── cli.smd                # CLI subcommands and argument parsing
├── storage.smd            # SQLite persistence layer
└── webui.smd              # Read-only web UI served from embedded HTML/CSS

output/src/
├── main.rs                # Entry point
├── lib.rs                 # Module declarations
├── storage.rs             # SQLite storage interface
├── web.rs                 # Web server module
└── commands/
    ├── mod.rs             # Commands module
    ├── add.rs             # Add subcommand handler
    ├── list.rs            # List/search subcommand handler
    ├── remove.rs          # Remove subcommand handler
    └── tests.rs           # Command handler tests
```

This is the only example with multiple SMD specs and no AMD files. Ossature infers the architecture from the three specs and their dependency relationships during audit.

## Model Configuration

- **All tasks:** `anthropic:claude-haiku-4-5-20251001`

The build uses custom setup and verify steps configured in `ossature.toml`:
- **Setup:** `cargo init --name markman`
- **Verify:** `cargo check`

## Try It

Requires [Rust](https://www.rust-lang.org/):

```bash
cd output
cargo run -- --help
```

```
Usage: markman [OPTIONS] <COMMAND>

Commands:
  add     Add a new bookmark
  list    List or search bookmarks
  remove  Remove a bookmark by id
  serve   Start the web UI server
  help    Print this message or the help of the given subcommand(s)

Options:
      --db <PATH>  Path to the database file [default: ~/.markman.db]
  -h, --help       Print help
```

## Rebuilding

See the [main README](../README.md#rebuilding-an-example) for rebuild instructions.
