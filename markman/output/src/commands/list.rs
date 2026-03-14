use crate::storage;

/// Handles the 'list' subcommand logic.
///
/// Searches for bookmarks using an optional query and displays the results.
/// If no bookmarks are found, displays a "No bookmarks found" message.
///
/// # Arguments
///
/// * `db_path` - Path to the database file
/// * `query` - Optional search query (empty string to list all bookmarks)
///
/// # Returns
///
/// `Ok(())` on success, or `Err(String)` with an error message on failure.
pub fn handle(db_path: &str, query: &str) -> Result<(), String> {
    let conn = storage::initialize_database(db_path)
        .map_err(|e| format!("Failed to initialize database: {}", e))?;

    let bookmarks = storage::search_bookmarks(&conn, query)
        .map_err(|e| e.to_string())?;

    if bookmarks.is_empty() {
        println!("No bookmarks found");
        return Ok(());
    }

    for bookmark in bookmarks {
        println!(
            "[{}] {} - {}",
            bookmark.id, bookmark.url, bookmark.description
        );
        if !bookmark.tags.is_empty() {
            println!("    Tags: {}", bookmark.tags);
        }
    }

    Ok(())
}
