use super::*;

fn open_in_memory() -> rusqlite::Connection {
    init_db(":memory:").expect("in-memory db should open")
}

#[test]
fn test_db_creation() {
    let conn = open_in_memory();
    let count: i64 = conn
        .query_row("SELECT COUNT(*) FROM bookmarks", [], |r| r.get(0))
        .expect("table should exist");
    assert_eq!(count, 0);
}

#[test]
fn test_add_and_search_round_trip() {
    let conn = open_in_memory();
    let id = add_bookmark(&conn, "https://example.com", "Example site", "example,test")
        .expect("add should succeed");
    assert!(id > 0);

    let results = search_bookmarks(&conn, "").expect("search should succeed");
    assert_eq!(results.len(), 1);
    assert_eq!(results[0].id, id);
    assert_eq!(results[0].url, "https://example.com");
    assert_eq!(results[0].desc, "Example site");
    assert_eq!(results[0].tags, "example,test");
    assert!(!results[0].created_at.is_empty());
}

#[test]
fn test_list_all_returns_empty_when_no_bookmarks() {
    let conn = open_in_memory();
    let results = search_bookmarks(&conn, "").expect("search should succeed");
    assert!(results.is_empty());
}

#[test]
fn test_empty_query_returns_all() {
    let conn = open_in_memory();
    add_bookmark(&conn, "https://one.com", "One", "a").unwrap();
    add_bookmark(&conn, "https://two.com", "Two", "b").unwrap();
    add_bookmark(&conn, "https://three.com", "Three", "c").unwrap();

    let results = search_bookmarks(&conn, "").expect("search should succeed");
    assert_eq!(results.len(), 3);
}

#[test]
fn test_query_filters_by_url() {
    let conn = open_in_memory();
    add_bookmark(&conn, "https://rust-lang.org", "Rust", "systems").unwrap();
    add_bookmark(&conn, "https://python.org", "Python", "scripting").unwrap();

    let results = search_bookmarks(&conn, "rust").expect("search should succeed");
    assert_eq!(results.len(), 1);
    assert_eq!(results[0].url, "https://rust-lang.org");
}

#[test]
fn test_query_filters_by_desc() {
    let conn = open_in_memory();
    add_bookmark(&conn, "https://alpha.com", "Alpha site", "misc").unwrap();
    add_bookmark(&conn, "https://beta.com", "Beta site", "misc").unwrap();

    let results = search_bookmarks(&conn, "Alpha").expect("search should succeed");
    assert_eq!(results.len(), 1);
    assert_eq!(results[0].url, "https://alpha.com");
}

#[test]
fn test_query_filters_by_tags() {
    let conn = open_in_memory();
    add_bookmark(&conn, "https://news.com", "News", "news,daily").unwrap();
    add_bookmark(&conn, "https://blog.com", "Blog", "writing,personal").unwrap();

    let results = search_bookmarks(&conn, "daily").expect("search should succeed");
    assert_eq!(results.len(), 1);
    assert_eq!(results[0].url, "https://news.com");
}

#[test]
fn test_query_is_case_insensitive() {
    let conn = open_in_memory();
    add_bookmark(&conn, "https://rust-lang.org", "Rust Programming", "systems").unwrap();

    let results = search_bookmarks(&conn, "RUST").expect("search should succeed");
    assert_eq!(results.len(), 1);
}

#[test]
fn test_query_no_match_returns_empty() {
    let conn = open_in_memory();
    add_bookmark(&conn, "https://example.com", "Example", "misc").unwrap();

    let results = search_bookmarks(&conn, "zzznomatch").expect("search should succeed");
    assert!(results.is_empty());
}

#[test]
fn test_duplicate_url_returns_duplicate_error() {
    let conn = open_in_memory();
    add_bookmark(&conn, "https://dup.com", "First", "").unwrap();
    let err = add_bookmark(&conn, "https://dup.com", "Second", "")
        .expect_err("duplicate should fail");
    assert!(
        matches!(err, StorageError::Duplicate(_)),
        "expected Duplicate, got {:?}",
        err
    );
}

#[test]
fn test_remove_unknown_id_returns_not_found() {
    let conn = open_in_memory();
    let err = remove_bookmark(&conn, 9999).expect_err("remove of unknown id should fail");
    assert!(
        matches!(err, StorageError::NotFound(_)),
        "expected NotFound, got {:?}",
        err
    );
}

#[test]
fn test_remove_existing_bookmark() {
    let conn = open_in_memory();
    let id = add_bookmark(&conn, "https://remove.me", "To remove", "").unwrap();
    remove_bookmark(&conn, id).expect("remove should succeed");

    let results = search_bookmarks(&conn, "").unwrap();
    assert!(results.is_empty());
}

#[test]
fn test_remove_does_not_affect_other_bookmarks() {
    let conn = open_in_memory();
    let id1 = add_bookmark(&conn, "https://keep.com", "Keep", "").unwrap();
    let id2 = add_bookmark(&conn, "https://remove.me", "Remove", "").unwrap();

    remove_bookmark(&conn, id2).expect("remove should succeed");

    let results = search_bookmarks(&conn, "").unwrap();
    assert_eq!(results.len(), 1);
    assert_eq!(results[0].id, id1);
}

#[test]
fn test_add_empty_url_returns_invalid_input() {
    let conn = open_in_memory();
    let err = add_bookmark(&conn, "  ", "desc", "tags").expect_err("empty url should fail");
    assert!(
        matches!(err, StorageError::InvalidInput(_)),
        "expected InvalidInput, got {:?}",
        err
    );
}

#[test]
fn test_add_with_empty_desc_and_tags() {
    let conn = open_in_memory();
    let id = add_bookmark(&conn, "https://minimal.com", "", "").expect("add should succeed");
    assert!(id > 0);

    let results = search_bookmarks(&conn, "").unwrap();
    assert_eq!(results.len(), 1);
    assert_eq!(results[0].desc, "");
    assert_eq!(results[0].tags, "");
}
