use axum::{
    extract::{Query, State},
    http::StatusCode,
    response::{Html, IntoResponse, Response},
    routing::get,
    Router,
};
use serde::Deserialize;
use std::sync::Arc;

use crate::storage;

#[derive(Clone)]
pub struct AppState {
    db_path: String,
}

#[derive(Deserialize)]
pub struct SearchQuery {
    q: Option<String>,
}

/// Run the web server listening on the specified port
pub async fn run_server(db_path: &str, port: u16) -> Result<(), String> {
    // Initialize database connection to ensure it's ready
    let _conn = storage::initialize_database(db_path)
        .map_err(|e| format!("Failed to initialize database: {}", e))?;

    let state = Arc::new(AppState {
        db_path: db_path.to_string(),
    });

    let app = Router::new()
        .route("/", get(index))
        .route("/api/bookmarks", get(api_bookmarks))
        .with_state(state);

    let listener = tokio::net::TcpListener::bind(format!("127.0.0.1:{}", port))
        .await
        .map_err(|e| format!("Failed to bind to port {}: {}", port, e))?;

    axum::serve(listener, app)
        .await
        .map_err(|e| format!("Server error: {}", e))?;

    Ok(())
}

async fn index() -> Html<&'static str> {
    Html(include_str!("../../assets/index.html"))
}

async fn api_bookmarks(
    State(state): State<Arc<AppState>>,
    Query(search): Query<SearchQuery>,
) -> Result<axum::Json<Vec<crate::Bookmark>>, ApiError> {
    let conn = storage::initialize_database(&state.db_path)
        .map_err(|e| ApiError::database_error(e.to_string()))?;

    let query = search.q.as_deref().unwrap_or("");
    let bookmarks = storage::search_bookmarks(&conn, query)
        .map_err(|e| ApiError::database_error(e.to_string()))?;

    Ok(axum::Json(bookmarks))
}

/// API error response
pub struct ApiError(String);

impl ApiError {
    fn database_error(msg: String) -> Self {
        ApiError(msg)
    }
}

impl IntoResponse for ApiError {
    fn into_response(self) -> Response {
        (StatusCode::INTERNAL_SERVER_ERROR, self.0).into_response()
    }
}

impl From<String> for ApiError {
    fn from(msg: String) -> Self {
        ApiError(msg)
    }
}


