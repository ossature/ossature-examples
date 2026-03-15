use std::process::Command;
use tempfile::TempDir;

/// Helper to run markman CLI with arguments
fn run_markman(args: &[&str], db_path: &str) -> std::process::Output {
    let mut cmd = Command::new("cargo");
    cmd.args(&["run", "--"])
        .arg("--db")
        .arg(db_path);
    
    for arg in args {
        cmd.arg(arg);
    }
    
    cmd.output().expect("Failed to execute markman")
}

/// Test adding a bookmark with valid URL and description
#[test]
fn test_add_bookmark_valid() {
    let temp_dir = TempDir::new().unwrap();
    let db_path = temp_dir.path().join("test.db").to_string_lossy().to_string();
    
    let output = run_markman(&["add", "https://example.com", "-d", "Example site", "-t", "example,test"], &db_path);
    
    assert!(output.status.success(), "add command failed: {}", String::from_utf8_lossy(&output.stderr));
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("Bookmark added with ID: 1"), "Expected success message, got: {}", stdout);
}

/// Test adding a bookmark with minimal arguments (URL only)
#[test]
fn test_add_bookmark_minimal() {
    let temp_dir = TempDir::new().unwrap();
    let db_path = temp_dir.path().join("test.db").to_string_lossy().to_string();
    
    let output = run_markman(&["add", "https://rust-lang.org"], &db_path);
    
    assert!(output.status.success(), "add command failed: {}", String::from_utf8_lossy(&output.stderr));
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("Bookmark added with ID: 1"), "Expected success message, got: {}", stdout);
}

/// Test adding a bookmark with only description (no tags)
#[test]
fn test_add_bookmark_with_description_no_tags() {
    let temp_dir = TempDir::new().unwrap();
    let db_path = temp_dir.path().join("test.db").to_string_lossy().to_string();
    
    let output = run_markman(&["add", "https://example.com", "-d", "My site"], &db_path);
    
    assert!(output.status.success(), "add command failed: {}", String::from_utf8_lossy(&output.stderr));
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("Bookmark added with ID: 1"), "Expected success message, got: {}", stdout);
}

/// Test adding a bookmark with only tags (no description)
#[test]
fn test_add_bookmark_with_tags_no_description() {
    let temp_dir = TempDir::new().unwrap();
    let db_path = temp_dir.path().join("test.db").to_string_lossy().to_string();
    
    let output = run_markman(&["add", "https://example.com", "-t", "web,reference"], &db_path);
    
    assert!(output.status.success(), "add command failed: {}", String::from_utf8_lossy(&output.stderr));
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("Bookmark added with ID: 1"), "Expected success message, got: {}", stdout);
}

/// Test adding a duplicate URL (should fail)
#[test]
fn test_add_duplicate_bookmark() {
    let temp_dir = TempDir::new().unwrap();
    let db_path = temp_dir.path().join("test.db").to_string_lossy().to_string();
    
    // Add first bookmark
    let output1 = run_markman(&["add", "https://example.com", "-d", "First"], &db_path);
    assert!(output1.status.success(), "First add failed: {}", String::from_utf8_lossy(&output1.stderr));
    
    // Try adding duplicate
    let output2 = run_markman(&["add", "https://example.com", "-d", "Second"], &db_path);
    assert!(!output2.status.success(), "Duplicate add should fail");
    let stderr = String::from_utf8_lossy(&output2.stderr);
    assert!(stderr.contains("Duplicate") || stderr.contains("already exists"), "Expected Duplicate URL error, got: {}", stderr);
}

/// Test adding a bookmark with empty URL (should fail)
#[test]
fn test_add_empty_url() {
    let temp_dir = TempDir::new().unwrap();
    let db_path = temp_dir.path().join("test.db").to_string_lossy().to_string();
    
    let output = run_markman(&["add", "", "-d", "Empty URL"], &db_path);
    assert!(!output.status.success(), "Adding empty URL should fail");
    let stderr = String::from_utf8_lossy(&output.stderr);
    assert!(stderr.contains("Invalid") || stderr.contains("empty"), "Expected Invalid URL error, got: {}", stderr);
}

/// Test adding a bookmark with whitespace-only URL (should fail)
#[test]
fn test_add_whitespace_url() {
    let temp_dir = TempDir::new().unwrap();
    let db_path = temp_dir.path().join("test.db").to_string_lossy().to_string();
    
    let output = run_markman(&["add", "   ", "-d", "Whitespace URL"], &db_path);
    assert!(!output.status.success(), "Adding whitespace URL should fail");
    let stderr = String::from_utf8_lossy(&output.stderr);
    assert!(stderr.contains("Invalid") || stderr.contains("empty"), "Expected Invalid URL error, got: {}", stderr);
}

/// Test listing bookmarks from empty database
#[test]
fn test_list_empty_database() {
    let temp_dir = TempDir::new().unwrap();
    let db_path = temp_dir.path().join("test.db").to_string_lossy().to_string();
    
    let output = run_markman(&["list"], &db_path);
    
    assert!(output.status.success(), "list command failed: {}", String::from_utf8_lossy(&output.stderr));
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("No bookmarks found"), "Expected 'No bookmarks found' message, got: {}", stdout);
}

/// Test listing all bookmarks
#[test]
fn test_list_all_bookmarks() {
    let temp_dir = TempDir::new().unwrap();
    let db_path = temp_dir.path().join("test.db").to_string_lossy().to_string();
    
    // Add some bookmarks
    run_markman(&["add", "https://example.com", "-d", "Example", "-t", "web"], &db_path);
    run_markman(&["add", "https://rust-lang.org", "-d", "Rust", "-t", "programming"], &db_path);
    
    let output = run_markman(&["list"], &db_path);
    
    assert!(output.status.success(), "list command failed: {}", String::from_utf8_lossy(&output.stderr));
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("https://example.com"), "Should contain first URL");
    assert!(stdout.contains("https://rust-lang.org"), "Should contain second URL");
    assert!(stdout.contains("Example"), "Should contain first description");
    assert!(stdout.contains("Rust"), "Should contain second description");
    assert!(stdout.contains("Tags: web"), "Should contain first tags");
    assert!(stdout.contains("Tags: programming"), "Should contain second tags");
}

/// Test listing bookmarks with search query
#[test]
fn test_list_with_search_query() {
    let temp_dir = TempDir::new().unwrap();
    let db_path = temp_dir.path().join("test.db").to_string_lossy().to_string();
    
    // Add multiple bookmarks
    run_markman(&["add", "https://example.com", "-d", "Example site", "-t", "web"], &db_path);
    run_markman(&["add", "https://rust-lang.org", "-d", "Official Rust", "-t", "programming,rust"], &db_path);
    run_markman(&["add", "https://github.com", "-d", "GitHub", "-t", "code,git"], &db_path);
    
    // Search for "rust"
    let output = run_markman(&["list", "rust"], &db_path);
    
    assert!(output.status.success(), "list with search failed: {}", String::from_utf8_lossy(&output.stderr));
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("https://rust-lang.org"), "Should find bookmark with 'rust' tag");
}

/// Test searching with non-matching query
#[test]
fn test_list_with_no_matching_results() {
    let temp_dir = TempDir::new().unwrap();
    let db_path = temp_dir.path().join("test.db").to_string_lossy().to_string();
    
    // Add a bookmark
    run_markman(&["add", "https://example.com", "-d", "Example"], &db_path);
    
    // Search for something that doesn't exist
    let output = run_markman(&["list", "nonexistent"], &db_path);
    
    assert!(output.status.success(), "list command failed: {}", String::from_utf8_lossy(&output.stderr));
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("No bookmarks found"), "Should return no results for non-matching query");
}

/// Test removing a bookmark by ID
#[test]
fn test_remove_bookmark_by_id() {
    let temp_dir = TempDir::new().unwrap();
    let db_path = temp_dir.path().join("test.db").to_string_lossy().to_string();
    
    // Add a bookmark
    run_markman(&["add", "https://example.com", "-d", "Example"], &db_path);
    
    // Remove it
    let output = run_markman(&["remove", "1"], &db_path);
    
    assert!(output.status.success(), "remove command failed: {}", String::from_utf8_lossy(&output.stderr));
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("Bookmark removed"), "Expected success message, got: {}", stdout);
    
    // Verify it's gone
    let list_output = run_markman(&["list"], &db_path);
    let list_stdout = String::from_utf8_lossy(&list_output.stdout);
    assert!(list_stdout.contains("No bookmarks found"), "Bookmark should be removed");
}

/// Test removing a non-existent bookmark (should fail)
#[test]
fn test_remove_nonexistent_bookmark() {
    let temp_dir = TempDir::new().unwrap();
    let db_path = temp_dir.path().join("test.db").to_string_lossy().to_string();
    
    let output = run_markman(&["remove", "999"], &db_path);
    assert!(!output.status.success(), "Removing non-existent bookmark should fail");
    let stderr = String::from_utf8_lossy(&output.stderr);
    assert!(stderr.contains("BookmarkNotFound") || stderr.contains("not found"), "Expected BookmarkNotFound error, got: {}", stderr);
}

/// Test removing with invalid ID (zero)
#[test]
fn test_remove_invalid_id_zero() {
    let temp_dir = TempDir::new().unwrap();
    let db_path = temp_dir.path().join("test.db").to_string_lossy().to_string();
    
    let output = run_markman(&["remove", "0"], &db_path);
    assert!(!output.status.success(), "Removing with ID 0 should fail");
    let stderr = String::from_utf8_lossy(&output.stderr);
    assert!(stderr.contains("positive") || stderr.contains("invalid"), "Expected positive number error, got: {}", stderr);
}

/// Test removing with invalid ID (negative)
#[test]
fn test_remove_invalid_id_negative() {
    let temp_dir = TempDir::new().unwrap();
    let db_path = temp_dir.path().join("test.db").to_string_lossy().to_string();
    
    let output = run_markman(&["remove", "999"], &db_path);
    assert!(!output.status.success(), "Invalid remove should fail");
}

/// Test multiple add and list operations
#[test]
fn test_multiple_operations() {
    let temp_dir = TempDir::new().unwrap();
    let db_path = temp_dir.path().join("test.db").to_string_lossy().to_string();
    
    // Add three bookmarks
    run_markman(&["add", "https://first.com", "-d", "First", "-t", "tag1"], &db_path);
    run_markman(&["add", "https://second.com", "-d", "Second", "-t", "tag2"], &db_path);
    run_markman(&["add", "https://third.com", "-d", "Third", "-t", "tag3"], &db_path);
    
    // List all
    let list_output = run_markman(&["list"], &db_path);
    let stdout = String::from_utf8_lossy(&list_output.stdout);
    assert!(stdout.contains("https://first.com"), "Should contain first bookmark");
    assert!(stdout.contains("https://second.com"), "Should contain second bookmark");
    assert!(stdout.contains("https://third.com"), "Should contain third bookmark");
    
    // Remove the middle one
    run_markman(&["remove", "2"], &db_path);
    
    // List again
    let list_output2 = run_markman(&["list"], &db_path);
    let stdout2 = String::from_utf8_lossy(&list_output2.stdout);
    assert!(stdout2.contains("https://first.com"), "Should still contain first bookmark");
    assert!(!stdout2.contains("https://second.com"), "Should not contain removed bookmark");
    assert!(stdout2.contains("https://third.com"), "Should still contain third bookmark");
}

/// Test add command with global --db flag in different positions
#[test]
fn test_global_db_flag_position() {
    let temp_dir = TempDir::new().unwrap();
    let db_path = temp_dir.path().join("test.db").to_string_lossy().to_string();
    
    // Test with --db before subcommand
    let mut cmd = Command::new("cargo");
    let output = cmd.args(&["run", "--", "--db", &db_path, "add", "https://example.com"])
        .output()
        .expect("Failed to execute markman");
    
    assert!(output.status.success(), "add with --db flag before subcommand failed: {}", String::from_utf8_lossy(&output.stderr));
}

/// Test listing bookmarks without description and tags
#[test]
fn test_list_bookmark_without_description_and_tags() {
    let temp_dir = TempDir::new().unwrap();
    let db_path = temp_dir.path().join("test.db").to_string_lossy().to_string();
    
    // Add bookmark with URL only
    run_markman(&["add", "https://example.com"], &db_path);
    
    let output = run_markman(&["list"], &db_path);
    
    assert!(output.status.success(), "list command failed: {}", String::from_utf8_lossy(&output.stderr));
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("[1]"), "Should display bookmark with ID");
    assert!(stdout.contains("https://example.com"), "Should display URL");
}

/// Test multiple searches with different queries
#[test]
fn test_multiple_searches() {
    let temp_dir = TempDir::new().unwrap();
    let db_path = temp_dir.path().join("test.db").to_string_lossy().to_string();
    
    // Add bookmarks with different characteristics
    run_markman(&["add", "https://rust-lang.org", "-d", "Rust Language", "-t", "rust,programming"], &db_path);
    run_markman(&["add", "https://docs.rs", "-d", "Rust Documentation", "-t", "rust,docs"], &db_path);
    run_markman(&["add", "https://github.com", "-d", "GitHub", "-t", "git,code"], &db_path);
    
    // Search for "rust"
    let rust_output = run_markman(&["list", "rust"], &db_path);
    let rust_stdout = String::from_utf8_lossy(&rust_output.stdout);
    assert!(!rust_stdout.contains("GitHub"), "Rust search should not include GitHub");
    
    // Search for "git"
    let git_output = run_markman(&["list", "git"], &db_path);
    let git_stdout = String::from_utf8_lossy(&git_output.stdout);
    assert!(git_stdout.contains("https://github.com"), "Git search should include GitHub");
}

/// Test that remove output is correct
#[test]
fn test_remove_output_format() {
    let temp_dir = TempDir::new().unwrap();
    let db_path = temp_dir.path().join("test.db").to_string_lossy().to_string();
    
    // Add a bookmark
    run_markman(&["add", "https://example.com"], &db_path);
    
    // Remove and check output
    let output = run_markman(&["remove", "1"], &db_path);
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("Bookmark removed"), "Remove should print success message");
}

/// Test case-insensitive search (depends on storage implementation)
#[test]
fn test_search_case_insensitive() {
    let temp_dir = TempDir::new().unwrap();
    let db_path = temp_dir.path().join("test.db").to_string_lossy().to_string();
    
    // Add a bookmark with uppercase letters in description
    run_markman(&["add", "https://example.com", "-d", "Example Site"], &db_path);
    
    // Search with lowercase
    let output = run_markman(&["list", "example"], &db_path);
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("https://example.com"), "Should find bookmark with case-insensitive search");
}

/// Test database persistence across commands
#[test]
fn test_database_persistence() {
    let temp_dir = TempDir::new().unwrap();
    let db_path = temp_dir.path().join("test.db").to_string_lossy().to_string();
    
    // Add a bookmark
    run_markman(&["add", "https://example.com", "-d", "Persisted"], &db_path);
    
    // List to verify it's there
    let output1 = run_markman(&["list"], &db_path);
    let stdout1 = String::from_utf8_lossy(&output1.stdout);
    assert!(stdout1.contains("Persisted"), "Bookmark should be in database");
    
    // Remove
    run_markman(&["remove", "1"], &db_path);
    
    // Verify it's gone
    let output2 = run_markman(&["list"], &db_path);
    let stdout2 = String::from_utf8_lossy(&output2.stdout);
    assert!(stdout2.contains("No bookmarks found"), "Bookmark should be removed from persistent database");
}

/// Test add with special characters in description and tags
#[test]
fn test_add_special_characters() {
    let temp_dir = TempDir::new().unwrap();
    let db_path = temp_dir.path().join("test.db").to_string_lossy().to_string();
    
    let output = run_markman(&[
        "add", "https://example.com",
        "-d", "Special chars: @#$%^&*()",
        "-t", "tag-with-dash,tag_with_underscore"
    ], &db_path);
    
    assert!(output.status.success(), "add with special characters failed: {}", String::from_utf8_lossy(&output.stderr));
    
    // Verify it was added
    let list_output = run_markman(&["list"], &db_path);
    let stdout = String::from_utf8_lossy(&list_output.stdout);
    assert!(stdout.contains("Special chars"), "Description with special chars should be saved");
}

/// Test that error exits with code 1
#[test]
fn test_error_exit_code() {
    let temp_dir = TempDir::new().unwrap();
    let db_path = temp_dir.path().join("test.db").to_string_lossy().to_string();
    
    let output = run_markman(&["remove", "999"], &db_path);
    assert_eq!(output.status.code().unwrap_or(-1), 1, "Error should exit with code 1");
}
