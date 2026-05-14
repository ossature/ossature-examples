# Specification (SMD)

---
L1: ---
L2: id: CLI
L3: status: draft
L4: priority: high
L5: depends: [STORAGE]
L6: ---
L7: # CLI
L8: 
L9: ## Overview
L10: 
L11: Command-line interface for managing bookmarks. Provides three subcommands — `add`, `list`, and `remove` — plus a `serve` subcommand to start the web UI. The database path defaults to `~/.markman.db` and can be overridden with `--db <path>`.
L12: 
L13: ## Goals
L14: 
L15: - Let users add, search/list, and remove bookmarks from the terminal
L16: - Start the web server with `markman serve`
L17: 
L18: ## Non-Goals
L19: 
L20: - No interactive TUI, no pagination, no export/import commands
L21: 
L22: ## Requirements
L23: 
L24: ### add subcommand
L25: 
L26: Adds a new bookmark.
L27: 
L28: **Accepts:** url (positional string, required), --desc/-d (string, optional, default ""), --tags/-t (comma-separated string, optional, default "")
L29: 
L30: **Returns:** Prints "added: <url>" to stdout on success
L31: 
L32: **Errors:**
L33: 
L34: - Missing url argument -> prints usage hint and exits with code 2
L35: - Duplicate URL -> delegates to storage error message, exits with code 1
L36: 
L37: ### list subcommand
L38: 
L39: Lists bookmarks, optionally filtered by a search query.
L40: 
L41: **Accepts:** query (positional string, optional, default "")
L42: 
L43: **Returns:** Prints each matching bookmark to stdout, one per line, in the format: `[<id>] <url> | <desc> | tags: <tags>`. If no bookmarks match, prints "no bookmarks found."
L44: 
L45: **Errors:**
L46: 
L47: - Database read failure -> delegates to storage error message, exits with code 1
L48: 
L49: ### remove subcommand
L50: 
L51: Removes a bookmark by its numeric id.
L52: 
L53: **Accepts:** id (positional i64, required)
L54: 
L55: **Returns:** Prints "removed: <id>" to stdout on success
L56: 
L57: **Errors:**
L58: 
L59: - Missing or non-integer id -> prints "error: id must be a positive integer" and exits with code 2
L60: - Unknown id -> delegates to storage error message, exits with code 1
L61: 
L62: ### serve subcommand
L63: 
L64: Starts the HTTP server for the web UI.
L65: 
L66: **Accepts:** --port/-p (u16, optional, default 3000), --db (string path, optional, overrides global default)
L67: 
L68: **Returns:** Prints "listening on http://0.0.0.0:<port>" to stdout, then blocks serving requests
L69: 
L70: **Errors:**
L71: 
L72: - Port already in use -> prints "error: port <port> is already in use" to stderr and exits with code 1
L73: 
L74: ## Constraints
L75: 
L76: - Single entry point: `src/main.rs` handles argument parsing and dispatches to storage or web modules
L77: - Use `clap` crate with derive macros for argument parsing
L78: - Global `--db <path>` flag applies to all subcommands; default path is resolved as `~/.markman.db`
L79: - No colored output, no spinners — plain text only
L80: 
L81: ## Examples
L82: 
L83: ### Add a bookmark
L84: 
L85: **Input:**
L86: 
L87: ```
L88: markman add https://example.com -d "Example site" -t "example,test"
L89: ```
L90: 
L91: **Output:**
L92: 
L93: ```
L94: added: https://example.com
L95: ```
L96: 
L97: ### List all bookmarks
L98: 
L99: **Input:**
L100: 
L101: ```
L102: markman list
L103: ```
L104: 
L105: **Output:**
L106: 
L107: ```
L108: [1] https://example.com | Example site | tags: example,test
L109: ```
L110: 
L111: ### Search bookmarks
L112: 
L113: **Input:**
L114: 
L115: ```
L116: markman list rust
L117: ```
L118: 
L119: **Output:**
L120: 
L121: ```
L122: [2] https://rustlang.org | Official Rust site | tags: rust,programming
L123: ```
L124: 
L125: ### Remove a bookmark
L126: 
L127: **Input:**
L128: 
L129: ```
L130: markman remove 1
L131: ```
L132: 
L133: **Output:**
L134: 
L135: ```
L136: removed: 1
L137: ```
L138: 
L139: ## Acceptance Criteria
L140: 
L141: - [ ] `markman add <url>` inserts a bookmark and confirms
L142: - [ ] `markman list` shows all bookmarks
L143: - [ ] `markman list <query>` filters by query
L144: - [ ] `markman remove <id>` deletes by id
L145: - [ ] `markman serve` starts the HTTP server
L146: - [ ] `--db <path>` overrides the database path for all subcommands