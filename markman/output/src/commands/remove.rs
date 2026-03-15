use crate::storage;

/// Handles the 'remove' subcommand logic.
///
/// Deletes a bookmark with the given ID from the database.
/// Validates the ID as a positive i64, calls storage to delete, and prints success or error messages.
///
/// # Arguments
///
/// * `db_path` - Path to the database file
/// * `id` - The ID of the bookmark to remove
///
/// # Returns
///
/// `Ok(())` on success, or `Err(String)` with an error message on failure.
pub fn handle(db_path: &str, id: i64) -> Result<(), String> {
    if id <= 0 {
        return Err("Bookmark ID must be a positive number".to_string());
    }

    let conn = storage::initialize_database(db_path)
        .map_err(|e| format!("Failed to initialize database: {}", e))?;

    storage::remove_bookmark(&conn, id)
        .map_err(|e| e.to_string())?;

    println!("Bookmark removed");
    Ok(())
}
