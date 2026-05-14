use crate::storage;
use rusqlite::Connection;
use std::io::Cursor;
use tiny_http::{Header, Response, Server, StatusCode};

// ── Embedded HTML/CSS ────────────────────────────────────────────────────────

const HTML_TEMPLATE: &str = r#"<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Markman</title>
<style>
* { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: sans-serif; background: #f5f5f5; color: #222; padding: 2rem; }
h1 { margin-bottom: 1.5rem; font-size: 1.5rem; }
form { margin-bottom: 1.5rem; display: flex; gap: 0.5rem; }
input[type=text] { padding: 0.4rem 0.6rem; border: 1px solid #ccc; border-radius: 4px; font-size: 1rem; flex: 1; max-width: 400px; }
button { padding: 0.4rem 1rem; border: none; border-radius: 4px; background: #0066cc; color: #fff; font-size: 1rem; cursor: pointer; }
button:hover { background: #0055aa; }
table { width: 100%; border-collapse: collapse; background: #fff; border-radius: 4px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
th { background: #0066cc; color: #fff; text-align: left; padding: 0.6rem 0.8rem; font-weight: 600; }
td { padding: 0.55rem 0.8rem; border-bottom: 1px solid #eee; vertical-align: top; }
tr:last-child td { border-bottom: none; }
tr:hover td { background: #f0f4ff; }
a { color: #0066cc; text-decoration: none; }
a:hover { text-decoration: underline; }
.no-results td { color: #888; font-style: italic; text-align: center; }
</style>
</head>
<body>
<h1>Markman</h1>
<form method="get" action="/">
  <input type="text" name="q" placeholder="Search bookmarks…" value="{{QUERY}}">
  <button type="submit">Search</button>
</form>
<table>
<thead><tr><th>URL</th><th>Description</th><th>Tags</th></tr></thead>
<tbody>
{{ROWS}}
</tbody>
</table>
</body>
</html>"#;

// ── HTML helpers ─────────────────────────────────────────────────────────────

fn html_escape(s: &str) -> String {
    s.replace('&', "&amp;")
        .replace('<', "&lt;")
        .replace('>', "&gt;")
        .replace('"', "&quot;")
}

fn render_rows(bookmarks: &[crate::storage::Bookmark]) -> String {
    if bookmarks.is_empty() {
        return r#"<tr class="no-results"><td colspan="3">No bookmarks found.</td></tr>"#
            .to_string();
    }
    bookmarks
        .iter()
        .map(|b| {
            let url_esc = html_escape(&b.url);
            let desc_esc = html_escape(&b.desc);
            let tags_esc = html_escape(&b.tags);
            format!(
                r#"<tr><td><a href="{url}" target="_blank" rel="noopener noreferrer">{url}</a></td><td>{desc}</td><td>{tags}</td></tr>"#,
                url = url_esc,
                desc = desc_esc,
                tags = tags_esc,
            )
        })
        .collect::<Vec<_>>()
        .join("\n")
}

fn render_page(bookmarks: &[crate::storage::Bookmark], query: &str) -> String {
    HTML_TEMPLATE
        .replace("{{QUERY}}", &html_escape(query))
        .replace("{{ROWS}}", &render_rows(bookmarks))
}

// ── URL parsing ──────────────────────────────────────────────────────────────

fn parse_q(url: &str) -> String {
    let qs = match url.find('?') {
        Some(pos) => &url[pos + 1..],
        None => return String::new(),
    };
    for part in qs.split('&') {
        if let Some(val) = part.strip_prefix("q=") {
            return percent_decode(val);
        }
    }
    String::new()
}

fn percent_decode(s: &str) -> String {
    let mut out = String::with_capacity(s.len());
    let bytes = s.as_bytes();
    let mut i = 0;
    while i < bytes.len() {
        if bytes[i] == b'%' && i + 2 < bytes.len() {
            if let (Some(h), Some(l)) = (hex_val(bytes[i + 1]), hex_val(bytes[i + 2])) {
                out.push(char::from(h * 16 + l));
                i += 3;
                continue;
            }
        } else if bytes[i] == b'+' {
            out.push(' ');
            i += 1;
            continue;
        }
        out.push(char::from(bytes[i]));
        i += 1;
    }
    out
}

fn hex_val(b: u8) -> Option<u8> {
    match b {
        b'0'..=b'9' => Some(b - b'0'),
        b'a'..=b'f' => Some(b - b'a' + 10),
        b'A'..=b'F' => Some(b - b'A' + 10),
        _ => None,
    }
}

// ── Response helpers ─────────────────────────────────────────────────────────

fn content_type_header(value: &str) -> Header {
    Header::from_bytes(b"Content-Type", value.as_bytes()).expect("valid header")
}

fn respond_html(request: tiny_http::Request, body: String, status: u16) {
    let bytes = body.into_bytes();
    let len = bytes.len();
    let response = Response::new(
        StatusCode(status),
        vec![content_type_header("text/html; charset=utf-8")],
        Cursor::new(bytes),
        Some(len),
        None,
    );
    let _ = request.respond(response);
}

fn respond_text(request: tiny_http::Request, body: &str, status: u16) {
    let bytes = body.as_bytes().to_vec();
    let len = bytes.len();
    let response = Response::new(
        StatusCode(status),
        vec![content_type_header("text/plain; charset=utf-8")],
        Cursor::new(bytes),
        Some(len),
        None,
    );
    let _ = request.respond(response);
}

// ── Request dispatch ─────────────────────────────────────────────────────────

fn handle(request: tiny_http::Request, conn: &Connection) {
    let url = request.url().to_string();
    let path = url.splitn(2, '?').next().unwrap_or("/");

    match path {
        "/health" => {
            respond_text(request, "ok", 200);
        }
        "/" => {
            let query = parse_q(&url);
            match storage::search_bookmarks(conn, &query) {
                Ok(bookmarks) => {
                    let page = render_page(&bookmarks, &query);
                    respond_html(request, page, 200);
                }
                Err(_) => {
                    respond_text(request, "internal server error", 500);
                }
            }
        }
        _ => {
            respond_text(request, "not found", 404);
        }
    }
}

// ── Public API ───────────────────────────────────────────────────────────────

/// Start the HTTP server bound to `addr`, serving bookmarks from `conn`.
/// Blocks the calling thread indefinitely.
pub fn run(addr: &str, conn: Connection) {
    let server = Server::http(addr).expect("failed to bind HTTP server");
    println!("listening on http://{}", addr);
    for request in server.incoming_requests() {
        handle(request, &conn);
    }
}

/// Convenience wrapper used by the CLI `serve` subcommand.
pub fn serve(conn: Connection, port: u16) {
    let addr = format!("0.0.0.0:{}", port);
    let server = match Server::http(&addr) {
        Ok(s) => s,
        Err(e) => {
            let msg = e.to_string();
            if msg.contains("Address already in use")
                || msg.contains("address already in use")
                || msg.contains("os error 98")
                || msg.contains("os error 48")
            {
                eprintln!("error: port {} is already in use", port);
            } else {
                eprintln!("error: {}", msg);
            }
            std::process::exit(1);
        }
    };

    println!("listening on http://0.0.0.0:{}", port);
    for request in server.incoming_requests() {
        handle(request, &conn);
    }
}

// ── Tests ─────────────────────────────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;
    use crate::storage::Bookmark;

    fn make_bookmark(id: i64, url: &str, desc: &str, tags: &str) -> Bookmark {
        Bookmark {
            id,
            url: url.to_string(),
            desc: desc.to_string(),
            tags: tags.to_string(),
            created_at: "2024-01-01 00:00:00".to_string(),
        }
    }

    // ── render_rows / render_page ─────────────────────────────────────────

    #[test]
    fn test_render_rows_with_bookmarks() {
        let bookmarks = vec![
            make_bookmark(1, "https://example.com", "Example site", "web,example"),
            make_bookmark(2, "https://rust-lang.org", "Rust language", "rust,programming"),
        ];
        let html = render_rows(&bookmarks);
        assert!(html.contains(r#"href="https://example.com""#));
        assert!(html.contains("Example site"));
        assert!(html.contains("web,example"));
        assert!(html.contains(r#"href="https://rust-lang.org""#));
        assert!(html.contains("Rust language"));
        assert!(html.contains("rust,programming"));
        assert!(!html.contains("No bookmarks found."));
    }

    #[test]
    fn test_render_rows_empty_shows_no_bookmarks_found() {
        let html = render_rows(&[]);
        assert!(html.contains("No bookmarks found."));
        assert!(html.contains(r#"class="no-results""#));
        assert!(html.contains(r#"colspan="3""#));
    }

    #[test]
    fn test_render_page_contains_bookmark_data() {
        let bookmarks = vec![make_bookmark(1, "https://example.com", "A site", "a,b")];
        let page = render_page(&bookmarks, "");
        assert!(html_is_well_formed(&page));
        assert!(page.contains("https://example.com"));
        assert!(page.contains("A site"));
        assert!(page.contains("a,b"));
    }

    #[test]
    fn test_render_page_empty_bookmarks_shows_no_results() {
        let page = render_page(&[], "");
        assert!(html_is_well_formed(&page));
        assert!(page.contains("No bookmarks found."));
    }

    // ── Query pre-fill ────────────────────────────────────────────────────

    #[test]
    fn test_render_page_prefills_query_in_input() {
        let page = render_page(&[], "rust");
        assert!(page.contains(r#"value="rust""#));
    }

    #[test]
    fn test_render_page_prefills_empty_query_when_no_search() {
        let page = render_page(&[], "");
        assert!(page.contains(r#"value="""#));
    }

    // ── HTML escaping ─────────────────────────────────────────────────────

    #[test]
    fn test_html_escape_ampersand() {
        assert_eq!(html_escape("a&b"), "a&amp;b");
    }

    #[test]
    fn test_html_escape_less_than() {
        assert_eq!(html_escape("a<b"), "a&lt;b");
    }

    #[test]
    fn test_html_escape_greater_than() {
        assert_eq!(html_escape("a>b"), "a&gt;b");
    }

    #[test]
    fn test_html_escape_double_quote() {
        assert_eq!(html_escape(r#"say "hi""#), "say &quot;hi&quot;");
    }

    #[test]
    fn test_html_escape_combined() {
        assert_eq!(html_escape("<script>alert(\"xss\")</script>"), "&lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;");
    }

    #[test]
    fn test_html_escape_no_special_chars() {
        assert_eq!(html_escape("hello world"), "hello world");
    }

    #[test]
    fn test_render_rows_escapes_special_chars_in_url() {
        let bookmarks = vec![make_bookmark(1, "https://ex.com?a=1&b=2", "desc", "tags")];
        let html = render_rows(&bookmarks);
        assert!(html.contains("https://ex.com?a=1&amp;b=2"));
        assert!(!html.contains("https://ex.com?a=1&b=2"));
    }

    #[test]
    fn test_render_rows_escapes_special_chars_in_desc() {
        let bookmarks = vec![make_bookmark(1, "https://ex.com", "<b>bold</b>", "tags")];
        let html = render_rows(&bookmarks);
        assert!(html.contains("&lt;b&gt;bold&lt;/b&gt;"));
        assert!(!html.contains("<b>bold</b>"));
    }

    #[test]
    fn test_render_rows_escapes_special_chars_in_tags() {
        let bookmarks = vec![make_bookmark(1, "https://ex.com", "desc", "a&b")];
        let html = render_rows(&bookmarks);
        assert!(html.contains("a&amp;b"));
    }

    #[test]
    fn test_render_page_escapes_query_in_input_value() {
        let page = render_page(&[], r#"<script>"#);
        assert!(page.contains(r#"value="&lt;script&gt;""#));
        assert!(!page.contains(r#"value="<script>""#));
    }

    #[test]
    fn test_render_page_escapes_double_quote_in_query() {
        let page = render_page(&[], r#"say "hi""#);
        assert!(page.contains(r#"value="say &quot;hi&quot;""#));
    }

    // ── URLs are clickable links ──────────────────────────────────────────

    #[test]
    fn test_render_rows_url_is_anchor_link() {
        let bookmarks = vec![make_bookmark(1, "https://example.com", "desc", "tags")];
        let html = render_rows(&bookmarks);
        assert!(html.contains(r#"<a href="https://example.com""#));
        assert!(html.contains("target=\"_blank\""));
    }

    // ── Filtering (case-insensitive substring) ────────────────────────────

    #[test]
    fn test_filtering_by_url_case_insensitive() {
        let conn = crate::storage::init_db(":memory:").unwrap();
        crate::storage::add_bookmark(&conn, "https://RUST-lang.org", "Rust", "pl").unwrap();
        crate::storage::add_bookmark(&conn, "https://python.org", "Python", "pl").unwrap();

        let results = crate::storage::search_bookmarks(&conn, "rust").unwrap();
        assert_eq!(results.len(), 1);
        assert!(results[0].url.contains("RUST"));
    }

    #[test]
    fn test_filtering_by_desc_case_insensitive() {
        let conn = crate::storage::init_db(":memory:").unwrap();
        crate::storage::add_bookmark(&conn, "https://a.com", "Awesome Site", "tag").unwrap();
        crate::storage::add_bookmark(&conn, "https://b.com", "boring site", "tag").unwrap();

        let results = crate::storage::search_bookmarks(&conn, "AWESOME").unwrap();
        assert_eq!(results.len(), 1);
        assert_eq!(results[0].url, "https://a.com");
    }

    #[test]
    fn test_filtering_by_tags_case_insensitive() {
        let conn = crate::storage::init_db(":memory:").unwrap();
        crate::storage::add_bookmark(&conn, "https://a.com", "desc", "Rust,Systems").unwrap();
        crate::storage::add_bookmark(&conn, "https://b.com", "desc", "python,web").unwrap();

        let results = crate::storage::search_bookmarks(&conn, "systems").unwrap();
        assert_eq!(results.len(), 1);
        assert_eq!(results[0].url, "https://a.com");
    }

    #[test]
    fn test_filtering_no_match_returns_empty() {
        let conn = crate::storage::init_db(":memory:").unwrap();
        crate::storage::add_bookmark(&conn, "https://a.com", "hello", "tag").unwrap();

        let results = crate::storage::search_bookmarks(&conn, "zzznomatch").unwrap();
        assert!(results.is_empty());
    }

    #[test]
    fn test_filtering_empty_query_returns_all() {
        let conn = crate::storage::init_db(":memory:").unwrap();
        crate::storage::add_bookmark(&conn, "https://a.com", "a", "").unwrap();
        crate::storage::add_bookmark(&conn, "https://b.com", "b", "").unwrap();

        let results = crate::storage::search_bookmarks(&conn, "").unwrap();
        assert_eq!(results.len(), 2);
    }

    // ── parse_q ───────────────────────────────────────────────────────────

    #[test]
    fn test_parse_q_extracts_query() {
        assert_eq!(parse_q("/?q=rust"), "rust");
    }

    #[test]
    fn test_parse_q_no_query_string() {
        assert_eq!(parse_q("/"), "");
    }

    #[test]
    fn test_parse_q_empty_q_param() {
        assert_eq!(parse_q("/?q="), "");
    }

    #[test]
    fn test_parse_q_percent_decoded() {
        assert_eq!(parse_q("/?q=hello%20world"), "hello world");
    }

    #[test]
    fn test_parse_q_plus_as_space() {
        assert_eq!(parse_q("/?q=hello+world"), "hello world");
    }

    #[test]
    fn test_parse_q_multiple_params() {
        assert_eq!(parse_q("/?foo=bar&q=rust&other=x"), "rust");
    }

    // ── HTML template structure ───────────────────────────────────────────

    #[test]
    fn test_html_template_has_form_with_get_method() {
        assert!(HTML_TEMPLATE.contains(r#"method="get""#));
        assert!(HTML_TEMPLATE.contains(r#"action="/""#));
    }

    #[test]
    fn test_html_template_has_table_columns() {
        assert!(HTML_TEMPLATE.contains("<th>URL</th>"));
        assert!(HTML_TEMPLATE.contains("<th>Description</th>"));
        assert!(HTML_TEMPLATE.contains("<th>Tags</th>"));
    }

    #[test]
    fn test_html_template_has_style_tag() {
        assert!(HTML_TEMPLATE.contains("<style>"));
        assert!(HTML_TEMPLATE.contains("</style>"));
    }

    #[test]
    fn test_html_template_no_javascript() {
        assert!(!HTML_TEMPLATE.contains("<script"));
        assert!(!HTML_TEMPLATE.contains("</script>"));
    }

    // ── Helper ────────────────────────────────────────────────────────────

    /// Minimal structural check: the output starts with a doctype and
    /// contains opening/closing html, head, and body tags.
    fn html_is_well_formed(html: &str) -> bool {
        html.contains("<!DOCTYPE html>")
            && html.contains("<html")
            && html.contains("</html>")
            && html.contains("<head>")
            && html.contains("</head>")
            && html.contains("<body>")
            && html.contains("</body>")
    }
}
