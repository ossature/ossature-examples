# Project: markman v0.0.1 (rust)

## Specification (SMD)

---
id: CLI
status: draft
priority: high
depends: [STORAGE]
---

# CLI

## Overview

Command-line interface for managing bookmarks. Provides three subcommands — `add`, `list`, and `remove` — plus a `serve` subcommand to start the web UI. The database path defaults to `~/.markman.db` and can be overridden with `--db <path>`.

## Goals

- Let users add, search/list, and remove bookmarks from the terminal
- Start the web server with `markman serve`

## Non-Goals

- No interactive TUI, no pagination, no export/import commands

## Requirements

### add subcommand

Adds a new bookmark.

**Accepts:** url (positional string, required), --desc/-d (string, optional, default ""), --tags/-t (comma-separated string, optional, default "")

**Returns:** Prints "added: <url>" to stdout on success

**Errors:**

- Missing url argument -> prints usage hint and exits with code 2
- Duplicate URL -> delegates to storage error message, exits with code 1

### list subcommand

Lists bookmarks, optionally filtered by a search query.

**Accepts:** query (positional string, optional, default "")

**Returns:** Prints each matching bookmark to stdout, one per line, in the format: `[<id>] <url> | <desc> | tags: <tags>`. If no bookmarks match, prints "no bookmarks found."

**Errors:**

- Database read failure -> delegates to storage error message, exits with code 1

### remove subcommand

Removes a bookmark by its numeric id.

**Accepts:** id (positional i64, required)

**Returns:** Prints "removed: <id>" to stdout on success

**Errors:**

- Missing or non-integer id -> prints "error: id must be a positive integer" and exits with code 2
- Unknown id -> delegates to storage error message, exits with code 1

### serve subcommand

Starts the HTTP server for the web UI.

**Accepts:** --port/-p (u16, optional, default 3000), --db (string path, optional, overrides global default)

**Returns:** Prints "listening on http://0.0.0.0:<port>" to stdout, then blocks serving requests

**Errors:**

- Port already in use -> prints "error: port <port> is already in use" to stderr and exits with code 1

## Constraints

- Single entry point: `src/main.rs` handles argument parsing and dispatches to storage or web modules
- Use `clap` crate with derive macros for argument parsing
- Global `--db <path>` flag applies to all subcommands; default path is resolved as `~/.markman.db`
- No colored output, no spinners — plain text only

## Examples

### Add a bookmark

**Input:**

```
markman add https://example.com -d "Example site" -t "example,test"
```

**Output:**

```
added: https://example.com
```

### List all bookmarks

**Input:**

```
markman list
```

**Output:**

```
[1] https://example.com | Example site | tags: example,test
```

### Search bookmarks

**Input:**

```
markman list rust
```

**Output:**

```
[2] https://rustlang.org | Official Rust site | tags: rust,programming
```

### Remove a bookmark

**Input:**

```
markman remove 1
```

**Output:**

```
removed: 1
```

## Acceptance Criteria

- [ ] [ ] `markman add <url>` inserts a bookmark and confirms
- [ ] [ ] `markman list` shows all bookmarks
- [ ] [ ] `markman list <query>` filters by query
- [ ] [ ] `markman remove <id>` deletes by id
- [ ] [ ] `markman serve` starts the HTTP server
- [ ] [ ] `--db <path>` overrides the database path for all subcommands

## Notes



## Audit Findings (avoid these issues in planning)

- [WARNING] Requirements > serve subcommand, L66: The `serve` subcommand defines its own `--db` flag as a local override, but the global `--db` flag (L78) already applies to all subcommands. It is ambiguous whether `serve` has two separate `--db` flags (one global, one local), whether the local one shadows the global, or whether the local one is redundant. Two implementors could produce incompatible CLI surfaces — one with a duplicated/conflicting flag, one that omits the local flag entirely.
- [WARNING] Requirements > remove subcommand, L53 and L59: The `id` argument is typed as `i64` (L53), but the error message says 'id must be a positive integer' (L59). It is ambiguous whether a negative or zero i64 value is a valid input that should produce an application-level error, or whether the type constraint itself (i64 vs u64/usize) is intentional and only non-integer strings are rejected by the parser. Two implementors could differ: one accepts `-5` and then errors at the storage layer; another rejects it at parse time with code 2.
- [INFO] Requirements > list subcommand, L43: The output format for tags in the list subcommand (`tags: example,test`) is shown in the example (L108), but it is not specified what is printed when a bookmark has no tags — whether it renders as `tags: ` (empty string), `tags: none`, or is omitted. This is a minor display ambiguity.
- [INFO] Requirements > serve subcommand > Errors, L72: The spec defines only one error case for `serve` (port in use). It is unspecified what happens if the database path is invalid or inaccessible when the server starts — no error behavior or exit code is defined for this case, even though the serve subcommand depends on storage.

## Build Setup Command
The following setup command runs before the first task:
```
['cargo init --name markman']
```
Do not generate tasks that duplicate what this command does.