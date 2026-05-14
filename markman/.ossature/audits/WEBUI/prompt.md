# Specification (SMD)

---
L1: ---
L2: id: WEBUI
L3: status: draft
L4: priority: high
L5: depends: [STORAGE]
L6: ---
L7: # Web UI
L8: 
L9: ## Overview
L10: 
L11: Minimal read-only HTTP server that lets users browse and search bookmarks in a browser. All HTML and CSS are embedded in the binary as string constants — no external files required at runtime. No JavaScript. No authentication.
L12: 
L13: ## Goals
L14: 
L15: - Serve a single-page HTML interface for viewing and searching bookmarks
L16: - Ship as a fully self-contained binary with no external static assets
L17: 
L18: ## Non-Goals
L19: 
L20: - No add, edit, or remove via the web UI
L21: - No authentication or access control
L22: - No JavaScript, no external CSS frameworks or fonts
L23: 
L24: ## Requirements
L25: 
L26: ### GET /
L27: 
L28: Returns the full HTML page. If the `q` query parameter is present and non-empty, only bookmarks matching the query (case-insensitive substring match against url, desc, or tags) are shown. If `q` is absent or empty, all bookmarks are shown ordered by insertion time descending.
L29: 
L30: **Accepts:** q (query string parameter, optional, string)
L31: 
L32: **Returns:** HTTP 200 with `Content-Type: text/html; charset=utf-8`. Body is a complete HTML document containing: a text input pre-filled with `q`, a submit button, and a table listing each bookmark's URL (as a clickable `<a>` link), description, and tags. If no bookmarks match, the table body shows a single row with the message "No bookmarks found."
L33: 
L34: **Errors:**
L35: 
L36: - Database read failure -> HTTP 500 with plain-text body "internal server error"
L37: 
L38: ### GET /health
L39: 
L40: Health check endpoint for the server.
L41: 
L42: **Accepts:** (no parameters)
L43: 
L44: **Returns:** HTTP 200 with plain-text body "ok"
L45: 
L46: **Errors:**
L47: 
L48: - Server internal failure -> HTTP 500 with plain-text body "internal server error"
L49: 
L50: ## Constraints
L51: 
L52: - Single file: all server logic lives in `src/web.rs`
L53: - Use `tiny_http` crate for the HTTP server — no async runtime required
L54: - HTML template and CSS are defined as `const &str` within `src/web.rs`; they are not read from disk at runtime
L55: - HTML must be valid and render correctly without JavaScript
L56: - CSS must be inline in the `<style>` tag within the HTML — no external stylesheets
L57: - The search form uses `method="get"` and `action="/"` so the query appears in the URL
L58: - Table columns: URL, Description, Tags
L59: 
L60: ## Examples
L61: 
L62: ### View all bookmarks
L63: 
L64: **Input:**
L65: 
L66: ```
L67: GET / HTTP/1.1
L68: ```
L69: 
L70: **Output:**
L71: 
L72: ```html
L73: HTTP/1.1 200 OK
L74: Content-Type: text/html; charset=utf-8
L75: 
L76: <!DOCTYPE html>
L77: <html>...table with all bookmarks...</html>
L78: ```
L79: 
L80: ### Search bookmarks
L81: 
L82: **Input:**
L83: 
L84: ```
L85: GET /?q=rust HTTP/1.1
L86: ```
L87: 
L88: **Output:**
L89: 
L90: ```html
L91: HTTP/1.1 200 OK
L92: Content-Type: text/html; charset=utf-8
L93: 
L94: <!DOCTYPE html>
L95: <html>...table filtered to bookmarks matching "rust"...</html>
L96: ```
L97: 
L98: ## Acceptance Criteria
L99: 
L100: - [ ] `GET /` returns all bookmarks as an HTML table
L101: - [ ] `GET /?q=<term>` returns only matching bookmarks
L102: - [ ] All HTML and CSS are embedded in the binary — no files read from disk
L103: - [ ] Bookmark URLs in the table are rendered as clickable `<a>` links
L104: - [ ] Empty result set shows "No bookmarks found." row instead of an empty table
L105: - [ ] `GET /health` returns 200 with body "ok"