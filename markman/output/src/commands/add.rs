use crate::storage;

/// Handles the 'add' subcommand logic.
///
/// Adds a new bookmark to the database with the given URL, description, and tags.
/// Validates input, calls storage to insert, and prints success or error messages.
///
/// # Arguments
///
/// * `db_path` - Path to the database file
/// * `url` - The URL to bookmark
/// * `description` - Description of the bookmark
/// * `tags` - Tags for the bookmark (comma-separated)
///
/// # Returns
///
/// `Ok(())` on success, or `Err(String)` with an error message on failure.
pub fn handle(
    db_path: &str,
    url: String,
    description: String,
    tags: String,
) -> Result<(), String> {
    let conn = storage::initialize_database(db_path)
        .map_err(|e| format!("Failed to initialize database: {}", e))?;

    let id = storage::add_bookmark(&conn, url, description, tags)
        .map_err(|e| e.to_string())?;

    println!("Bookmark added with ID: {}", id);
    Ok(())
}
