# Audit Report: markman v0.0.1

**Date:** 2026-05-14T20:04:33Z
**Specs:** STORAGE, CLI, WEBUI

## Cross-Spec Findings

### WARNING: CLI <-> WEBUI

**Issue:** The CLI's `serve` subcommand is responsible for starting the web UI server, but neither spec defines the interface between them — specifically, how the CLI passes the resolved database path to the web server. The CLI accepts a `--db <path>` override, but WEBUI's spec makes no mention of receiving a database path at startup. If implemented independently, CLI might pass the path as a constructor argument while WEBUI expects a global/config mechanism, or WEBUI might hardcode a default path ignoring the CLI-provided one.

**Suggestion:** Explicitly specify in either the CLI or WEBUI spec (or both) how the database path is communicated to the web server at startup — e.g., as a function argument to an `fn start_server(db_path: PathBuf)` entry point. This ensures both teams agree on the handoff contract for the `serve` subcommand.

### INFO: CLI <-> WEBUI

**Issue:** WEBUI is described as a 'read-only' interface exposing only `GET /` and `GET /health`, but the CLI spec lists `add`, `list`, and `remove` as the full set of mutating operations. There is no ambiguity in ownership of mutations, but the WEBUI spec does not reference the STORAGE `Search Bookmarks` requirement by name, leaving it implicit that `GET /` uses STORAGE's search capability. A team implementing WEBUI in isolation might not realise search/filter functionality is expected on the index page.

**Suggestion:** Add a note in the WEBUI spec that `GET /` should support bookmark browsing/searching via STORAGE's Search Bookmarks function, to make the dependency on that specific STORAGE capability explicit.

## STORAGE Findings

### WARNING: Requirements > Search Bookmarks, L57

**Issue:** The spec states results are ordered by `created_at` descending when the query is empty, but does not specify the ordering when a non-empty query is provided. Two implementers could reasonably choose different orderings (e.g., insertion order, ascending created_at, or relevance), producing different user-visible output.

**Suggestion:** Explicitly state the sort order for non-empty query results, e.g. 'ordered by created_at descending in all cases' or define a separate ordering for filtered results.

### WARNING: Requirements > Search Bookmarks, L57

**Issue:** The spec says 'case-insensitive ASCII substring match using SQLite `LIKE`', but SQLite's `LIKE` is only case-insensitive for ASCII alphabetic characters (A-Z) by default — it is case-sensitive for non-ASCII Unicode characters. This boundary condition is not acknowledged, so an implementer might add `PRAGMA case_sensitive_like` or a custom collation while another relies on SQLite's default, producing different results for non-ASCII queries.

**Suggestion:** Clarify whether non-ASCII case-insensitivity is required. If ASCII-only is acceptable, explicitly state that Unicode case folding is out of scope. If full Unicode case-insensitivity is needed, specify the mechanism (e.g., `COLLATE NOCASE` with ICU, or Rust-side lowercasing).

### WARNING: Requirements > Add Bookmark, L52

**Issue:** The duplicate-URL detection is described as a returned `StorageError::Duplicate`, but it is not specified whether this check is performed in Rust before the INSERT (e.g., a prior SELECT) or by relying on the SQLite UNIQUE constraint violation. These approaches differ in behavior under concurrent writes (though the spec is single-connection/CLI). More critically, if detection is via the UNIQUE constraint, the error must be distinguished from a generic `StorageError::Db`, and the spec does not describe how to identify the constraint violation from `rusqlite`'s error type.

**Suggestion:** Clarify whether duplicate detection is done via a pre-INSERT SELECT or by catching a UNIQUE constraint error from rusqlite (e.g., `Error::SqliteFailure` with `SQLITE_CONSTRAINT_UNIQUE`). This matters for correctness of the Duplicate vs Db error discrimination.

### INFO: Requirements > Initialize Database > Connection-lifetime model, L34

**Issue:** The spec notes that `rusqlite::Connection` is neither `Send` nor `Clone` and defers web UI connection sharing to a future spec. However, the function signatures use `conn (Connection)` by value in subsequent calls (e.g., Add Bookmark, Search Bookmarks, Remove Bookmark at L45, L59, L71). Passing `Connection` by value would consume it on the first call, making subsequent calls impossible. The intent is almost certainly to pass by shared or mutable reference, but this is not stated.

**Suggestion:** Specify that storage functions accept `&Connection` or `&mut Connection` rather than an owned `Connection`. Clarify the borrow type (shared vs. mutable) given that rusqlite requires `&Connection` for most operations.

## CLI Findings

### WARNING: Requirements > serve subcommand, L66

**Issue:** The `serve` subcommand defines its own `--db` flag as a local override, but the global `--db` flag (L78) already applies to all subcommands. It is ambiguous whether `serve` has two separate `--db` flags (one global, one local), whether the local one shadows the global, or whether the local one is redundant. Two implementors could produce incompatible CLI surfaces — one with a duplicated/conflicting flag, one that omits the local flag entirely.

**Suggestion:** Clarify whether the `--db` in the `serve` subcommand definition is intentionally a subcommand-level override that takes precedence over the global flag, or whether it is simply a reminder that the global `--db` applies. If the global flag already covers all subcommands, remove the per-subcommand mention to avoid ambiguity.

### WARNING: Requirements > remove subcommand, L53 and L59

**Issue:** The `id` argument is typed as `i64` (L53), but the error message says 'id must be a positive integer' (L59). It is ambiguous whether a negative or zero i64 value is a valid input that should produce an application-level error, or whether the type constraint itself (i64 vs u64/usize) is intentional and only non-integer strings are rejected by the parser. Two implementors could differ: one accepts `-5` and then errors at the storage layer; another rejects it at parse time with code 2.

**Suggestion:** Specify explicitly whether negative or zero values for `id` should be rejected at the CLI layer (exit code 2) or passed through to storage. If only positive integers are valid, consider typing the argument as a positive integer (e.g., NonZeroU64) or add an explicit validation step with a defined exit code.

### INFO: Requirements > list subcommand, L43

**Issue:** The output format for tags in the list subcommand (`tags: example,test`) is shown in the example (L108), but it is not specified what is printed when a bookmark has no tags — whether it renders as `tags: ` (empty string), `tags: none`, or is omitted. This is a minor display ambiguity.

**Suggestion:** Specify the display format for a bookmark with an empty tags field, e.g., 'tags: ' (empty) or a placeholder like 'tags: -'.

### INFO: Requirements > serve subcommand > Errors, L72

**Issue:** The spec defines only one error case for `serve` (port in use). It is unspecified what happens if the database path is invalid or inaccessible when the server starts — no error behavior or exit code is defined for this case, even though the serve subcommand depends on storage.

**Suggestion:** Add an error case for database initialization failure in the `serve` subcommand (e.g., invalid path, permission denied), specifying the error message format and exit code, consistent with how other subcommands handle storage errors.

## WEBUI Findings

### WARNING: Requirements > GET /, L28

**Issue:** The spec says 'all bookmarks are shown ordered by insertion time descending' when no query is present, but does not specify the ordering when a search query IS present. Two developers could reasonably implement search results ordered by insertion time descending, relevance score, or insertion time ascending, producing different user-visible behavior.

**Suggestion:** Specify the sort order for filtered results, e.g. 'matching bookmarks are also ordered by insertion time descending.'

### WARNING: Requirements > GET /, L28

**Issue:** The substring match is defined as case-insensitive against 'url, desc, or tags' but 'tags' is ambiguous: it is unclear whether tags are matched as a single concatenated string, matched individually per-tag, or matched against a space/comma-separated serialization. For a bookmark with tags ['rust-lang', 'async'], a query of 'lang' would match under whole-string or per-tag-substring approaches but could behave differently depending on the delimiter assumed.

**Suggestion:** Clarify how tags are matched — e.g. 'each tag is individually matched as a case-insensitive substring' or 'the tags field is treated as a space-separated string for substring matching.'

### WARNING: Requirements > GET /health, L46-L48

**Issue:** The /health endpoint error condition ('Server internal failure -> HTTP 500') is undefined for a static endpoint that only returns the string 'ok'. There is no meaningful failure path described, making it impossible to know what condition should trigger the 500 or what implementation code would produce it. This may lead one developer to add no error handling and another to add a database ping check.

**Suggestion:** Either remove the error clause (the endpoint trivially cannot fail if it only returns a constant string), or define what 'server internal failure' means concretely — e.g. specifying that a database liveness check is performed.

### INFO: Requirements > GET /, L32

**Issue:** The spec requires the text input to be 'pre-filled with q' but does not address HTML-escaping of the q value in the input's value attribute. A query containing characters like `"`, `<`, or `>` could break the HTML or create injection artifacts in the rendered page.

**Suggestion:** Explicitly require that the q parameter value is HTML-escaped before being interpolated into the value attribute of the input element.

### INFO: Requirements > GET /, L32

**Issue:** The spec requires bookmark URLs to be rendered as clickable <a> links but does not specify whether URL values should be HTML-escaped or sanitized before insertion into the href attribute. A stored URL containing characters like `"` or `'` could break the anchor tag structure.

**Suggestion:** Specify that URL, description, and tag values must be HTML-escaped when inserted into the HTML template to prevent malformed output.

