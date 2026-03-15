use crate::storage::{search_bookmarks, initialize_database, Bookmark};
use tiny_http::{Server, Request, Response as TinyResponse, Header};
use std::thread;

const HTML_TEMPLATE: &str = r#"<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Markman - Bookmark Manager</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background-color: #f5f5f5;
            padding: 20px;
            line-height: 1.6;
        }

        .container {
            max-width: 1000px;
            margin: 0 auto;
            background-color: #ffffff;
            border-radius: 8px;
            padding: 30px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

        h1 {
            color: #333;
            margin-bottom: 20px;
            font-size: 28px;
        }

        .search-section {
            margin-bottom: 30px;
            display: flex;
            gap: 10px;
        }

        .search-input {
            flex: 1;
            padding: 10px 15px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 16px;
        }

        .search-input:focus {
            outline: none;
            border-color: #007bff;
            box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.1);
        }

        .search-button {
            padding: 10px 25px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.2s;
        }

        .search-button:hover {
            background-color: #0056b3;
        }

        .search-button:active {
            background-color: #003d82;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        thead {
            background-color: #f8f9fa;
            border-bottom: 2px solid #dee2e6;
        }

        th {
            padding: 15px;
            text-align: left;
            font-weight: 600;
            color: #333;
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        td {
            padding: 15px;
            border-bottom: 1px solid #dee2e6;
        }

        tbody tr:hover {
            background-color: #f8f9fa;
        }

        a {
            color: #007bff;
            text-decoration: none;
            word-break: break-all;
        }

        a:hover {
            text-decoration: underline;
        }

        .tags {
            color: #666;
            font-size: 14px;
        }

        .description {
            color: #555;
            max-width: 300px;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .no-results {
            text-align: center;
            padding: 40px 20px;
            color: #999;
            font-size: 16px;
        }

        form {
            display: flex;
            gap: 10px;
        }

        @media (max-width: 768px) {
            .container {
                padding: 20px;
            }

            h1 {
                font-size: 22px;
            }

            .search-section {
                flex-direction: column;
            }

            table {
                font-size: 14px;
            }

            th, td {
                padding: 10px;
            }

            .description {
                max-width: 150px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Bookmarks</h1>
        <div class="search-section">
            <form action="/" method="get">
                <input type="text" name="q" class="search-input" placeholder="Search bookmarks..." value="{query}">
                <button type="submit" class="search-button">Search</button>
            </form>
        </div>
        <table>
            <thead>
                <tr>
                    <th>URL</th>
                    <th>Description</th>
                    <th>Tags</th>
                </tr>
            </thead>
            <tbody>
                {table_rows}
            </tbody>
        </table>
    </div>
</body>
</html>"#;

/// Generate HTML table rows for bookmarks
fn generate_table_rows(bookmarks: &[Bookmark]) -> String {
    if bookmarks.is_empty() {
        return r#"<tr><td colspan="3" class="no-results">No bookmarks found.</td></tr>"#.to_string();
    }

    bookmarks
        .iter()
        .map(|bookmark| {
            format!(
                r#"<tr><td><a href="{}" target="_blank">{}</a></td><td class="description">{}</td><td class="tags">{}</td></tr>"#,
                escape_html(&bookmark.url),
                escape_html(&bookmark.url),
                escape_html(&bookmark.description),
                escape_html(&bookmark.tags),
            )
        })
        .collect::<Vec<_>>()
        .join("\n")
}

/// Escape HTML special characters
fn escape_html(s: &str) -> String {
    s.replace('&', "&amp;")
        .replace('<', "&lt;")
        .replace('>', "&gt;")
        .replace('"', "&quot;")
        .replace('\'', "&#39;")
}

/// Decode URL-encoded string
fn url_decode(s: &str) -> String {
    let mut result = Vec::new();
    let bytes = s.as_bytes();
    let mut i = 0;
    while i < bytes.len() {
        match bytes[i] {
            b'%' if i + 2 < bytes.len() => {
                if let Ok(hex_str) = std::str::from_utf8(&bytes[i + 1..i + 3]) {
                    if let Ok(byte) = u8::from_str_radix(hex_str, 16) {
                        result.push(byte);
                        i += 3;
                        continue;
                    }
                }
                result.push(b'%');
                i += 1;
            }
            b'+' => {
                result.push(b' ');
                i += 1;
            }
            c => {
                result.push(c);
                i += 1;
            }
        }
    }
    String::from_utf8_lossy(&result).to_string()
}

/// Parse query string from URL
fn parse_query_string(url: &str) -> Option<String> {
    url.split('?').nth(1)?.split('&').find_map(|param| {
        let mut parts = param.splitn(2, '=');
        match (parts.next(), parts.next()) {
            (Some("q"), Some(value)) => {
                // URL decode the value
                Some(url_decode(value))
            }
            _ => None,
        }
    })
}

/// Run the HTTP server on the specified port with the given database path
pub async fn run_server(db_path: &str, port: u16) -> Result<(), String> {
    // Initialize database connection to ensure it's ready
    let _conn = initialize_database(db_path)
        .map_err(|e| format!("Failed to initialize database: {}", e))?;

    let db_path = db_path.to_string();
    let addr = format!("127.0.0.1:{}", port);
    
    // Spawn the server in a blocking thread since tiny_http is synchronous
    let result = thread::spawn(move || {
        run_server_sync(&db_path, &addr)
    }).join();

    match result {
        Ok(server_result) => server_result,
        Err(_) => Err("Server thread panicked".to_string()),
    }
}

fn run_server_sync(db_path: &str, addr: &str) -> Result<(), String> {
    let server = Server::http(addr).map_err(|e| format!("Failed to bind to address {}: {}", addr, e))?;

    for request in server.incoming_requests() {
        handle_request(request, db_path);
    }

    Ok(())
}

/// Handle a single HTTP request
fn handle_request(request: Request, db_path: &str) {
    let path = request.url();

    let response = if path == "/health" {
        handle_health()
    } else if path == "/" || path.starts_with("/?") {
        handle_root(path, db_path)
    } else {
        TinyResponse::from_string("Not Found")
            .with_status_code(404)
    };

    let _ = request.respond(response);
}

/// Handle GET /health
fn handle_health() -> TinyResponse {
    TinyResponse::from_string("ok")
        .with_header(Header::from_bytes(&b"Content-Type"[..], &b"text/plain; charset=utf-8"[..]).unwrap())
        .with_status_code(200)
}

/// Handle GET / and GET /?q=...
fn handle_root(url: &str, db_path: &str) -> TinyResponse {
    // Extract query parameter
    let query = parse_query_string(url).unwrap_or_default();

    // Get bookmarks from database
    let bookmarks = match initialize_database(db_path) {
        Ok(conn) => match search_bookmarks(&conn, &query) {
            Ok(bm) => bm,
            Err(_) => {
                return TinyResponse::from_string("internal server error")
                    .with_status_code(500)
                    .with_header(Header::from_bytes(&b"Content-Type"[..], &b"text/plain; charset=utf-8"[..]).unwrap());
            }
        },
        Err(_) => {
            return TinyResponse::from_string("internal server error")
                .with_status_code(500)
                .with_header(Header::from_bytes(&b"Content-Type"[..], &b"text/plain; charset=utf-8"[..]).unwrap());
        }
    };

    // Generate table rows
    let table_rows = generate_table_rows(&bookmarks);

    // Build HTML response
    let html = HTML_TEMPLATE
        .replace("{query}", &escape_html(&query))
        .replace("{table_rows}", &table_rows);

    TinyResponse::from_string(html)
        .with_header(Header::from_bytes(&b"Content-Type"[..], &b"text/html; charset=utf-8"[..]).unwrap())
        .with_status_code(200)
}
