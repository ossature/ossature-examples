use std::process::Command;
use tempfile::NamedTempFile;

fn bin() -> std::path::PathBuf {
    let mut p = std::env::current_exe().unwrap();
    // current_exe is something like target/debug/deps/cli-<hash>
    // binary lives at target/debug/markman
    p.pop(); // deps
    p.pop(); // debug
    p.push("markman");
    p
}

fn tmp_db() -> NamedTempFile {
    NamedTempFile::new().unwrap()
}

fn cmd(db: &str) -> Command {
    let mut c = Command::new(bin());
    c.arg("--db").arg(db);
    c
}

// ─── add ──────────────────────────────────────────────────────────────────────

#[test]
fn add_basic() {
    let db = tmp_db();
    let out = cmd(db.path().to_str().unwrap())
        .args(["add", "https://example.com"])
        .output()
        .unwrap();
    assert!(out.status.success(), "exit code: {:?}", out.status.code());
    assert_eq!(
        String::from_utf8_lossy(&out.stdout).trim(),
        "added: https://example.com"
    );
}

#[test]
fn add_with_desc_and_tags() {
    let db = tmp_db();
    let out = cmd(db.path().to_str().unwrap())
        .args([
            "add",
            "https://example.com",
            "-d",
            "Example site",
            "-t",
            "example,test",
        ])
        .output()
        .unwrap();
    assert!(out.status.success());
    assert_eq!(
        String::from_utf8_lossy(&out.stdout).trim(),
        "added: https://example.com"
    );
}

#[test]
fn add_duplicate_url_exits_1() {
    let db = tmp_db();
    let db_path = db.path().to_str().unwrap();

    // First insertion should succeed
    cmd(db_path)
        .args(["add", "https://example.com"])
        .output()
        .unwrap();

    // Second insertion with the same URL should fail
    let out = cmd(db_path)
        .args(["add", "https://example.com"])
        .output()
        .unwrap();
    assert_eq!(out.status.code(), Some(1));
    let stderr = String::from_utf8_lossy(&out.stderr);
    assert!(
        stderr.contains("error:"),
        "expected error on stderr, got: {stderr}"
    );
}

#[test]
fn add_missing_url_exits_2() {
    let db = tmp_db();
    let out = cmd(db.path().to_str().unwrap())
        .arg("add")
        .output()
        .unwrap();
    assert_eq!(out.status.code(), Some(2));
}

// ─── list ─────────────────────────────────────────────────────────────────────

#[test]
fn list_empty_db() {
    let db = tmp_db();
    let out = cmd(db.path().to_str().unwrap())
        .arg("list")
        .output()
        .unwrap();
    assert!(out.status.success());
    assert_eq!(
        String::from_utf8_lossy(&out.stdout).trim(),
        "no bookmarks found."
    );
}

#[test]
fn list_shows_bookmarks() {
    let db = tmp_db();
    let db_path = db.path().to_str().unwrap();

    cmd(db_path)
        .args([
            "add",
            "https://example.com",
            "-d",
            "Example site",
            "-t",
            "example,test",
        ])
        .output()
        .unwrap();

    let out = cmd(db_path).arg("list").output().unwrap();
    assert!(out.status.success());
    let stdout = String::from_utf8_lossy(&out.stdout);
    assert!(stdout.contains("https://example.com"), "stdout: {stdout}");
    assert!(stdout.contains("Example site"), "stdout: {stdout}");
    assert!(stdout.contains("tags: example,test"), "stdout: {stdout}");
    // check format prefix
    assert!(stdout.contains("[1]"), "stdout: {stdout}");
}

#[test]
fn list_format() {
    let db = tmp_db();
    let db_path = db.path().to_str().unwrap();

    cmd(db_path)
        .args(["add", "https://example.com", "-d", "desc", "-t", "t1,t2"])
        .output()
        .unwrap();

    let out = cmd(db_path).arg("list").output().unwrap();
    assert!(out.status.success());
    let stdout = String::from_utf8_lossy(&out.stdout);
    let line = stdout.trim();
    assert_eq!(line, "[1] https://example.com | desc | tags: t1,t2");
}

#[test]
fn list_with_query_matches() {
    let db = tmp_db();
    let db_path = db.path().to_str().unwrap();

    cmd(db_path)
        .args(["add", "https://rustlang.org", "-d", "Official Rust site", "-t", "rust,programming"])
        .output()
        .unwrap();
    cmd(db_path)
        .args(["add", "https://example.com", "-d", "Example", "-t", "misc"])
        .output()
        .unwrap();

    let out = cmd(db_path).args(["list", "rust"]).output().unwrap();
    assert!(out.status.success());
    let stdout = String::from_utf8_lossy(&out.stdout);
    assert!(stdout.contains("rustlang.org"), "stdout: {stdout}");
    assert!(!stdout.contains("example.com"), "stdout should not contain example.com: {stdout}");
}

#[test]
fn list_with_query_no_match() {
    let db = tmp_db();
    let db_path = db.path().to_str().unwrap();

    cmd(db_path)
        .args(["add", "https://example.com"])
        .output()
        .unwrap();

    let out = cmd(db_path)
        .args(["list", "zzznomatch"])
        .output()
        .unwrap();
    assert!(out.status.success());
    assert_eq!(
        String::from_utf8_lossy(&out.stdout).trim(),
        "no bookmarks found."
    );
}

// ─── remove ───────────────────────────────────────────────────────────────────

#[test]
fn remove_existing() {
    let db = tmp_db();
    let db_path = db.path().to_str().unwrap();

    cmd(db_path)
        .args(["add", "https://example.com"])
        .output()
        .unwrap();

    let out = cmd(db_path).args(["remove", "1"]).output().unwrap();
    assert!(out.status.success());
    assert_eq!(
        String::from_utf8_lossy(&out.stdout).trim(),
        "removed: 1"
    );

    // Confirm it is gone
    let list = cmd(db_path).arg("list").output().unwrap();
    assert_eq!(
        String::from_utf8_lossy(&list.stdout).trim(),
        "no bookmarks found."
    );
}

#[test]
fn remove_unknown_id_exits_1() {
    let db = tmp_db();
    let out = cmd(db.path().to_str().unwrap())
        .args(["remove", "9999"])
        .output()
        .unwrap();
    assert_eq!(out.status.code(), Some(1));
    let stderr = String::from_utf8_lossy(&out.stderr);
    assert!(
        stderr.contains("error:"),
        "expected error on stderr, got: {stderr}"
    );
}

#[test]
fn remove_missing_id_exits_2() {
    let db = tmp_db();
    let out = cmd(db.path().to_str().unwrap())
        .arg("remove")
        .output()
        .unwrap();
    assert_eq!(out.status.code(), Some(2));
}

#[test]
fn remove_non_integer_id_exits_2() {
    let db = tmp_db();
    let out = cmd(db.path().to_str().unwrap())
        .args(["remove", "abc"])
        .output()
        .unwrap();
    assert_eq!(out.status.code(), Some(2));
}

#[test]
fn remove_zero_id_exits_2() {
    let db = tmp_db();
    let out = cmd(db.path().to_str().unwrap())
        .args(["remove", "0"])
        .output()
        .unwrap();
    assert_eq!(out.status.code(), Some(2));
}

#[test]
fn remove_negative_id_exits_2() {
    let db = tmp_db();
    let out = cmd(db.path().to_str().unwrap())
        .args(["remove", "--", "-5"])
        .output()
        .unwrap();
    assert_eq!(out.status.code(), Some(2));
}

// ─── --db flag ────────────────────────────────────────────────────────────────

#[test]
fn db_flag_uses_different_files() {
    let db1 = tmp_db();
    let db2 = tmp_db();

    cmd(db1.path().to_str().unwrap())
        .args(["add", "https://db1.example.com"])
        .output()
        .unwrap();

    cmd(db2.path().to_str().unwrap())
        .args(["add", "https://db2.example.com"])
        .output()
        .unwrap();

    // db1 should only have db1's bookmark
    let out1 = cmd(db1.path().to_str().unwrap())
        .arg("list")
        .output()
        .unwrap();
    let stdout1 = String::from_utf8_lossy(&out1.stdout);
    assert!(stdout1.contains("db1.example.com"), "stdout: {stdout1}");
    assert!(!stdout1.contains("db2.example.com"), "stdout: {stdout1}");

    // db2 should only have db2's bookmark
    let out2 = cmd(db2.path().to_str().unwrap())
        .arg("list")
        .output()
        .unwrap();
    let stdout2 = String::from_utf8_lossy(&out2.stdout);
    assert!(stdout2.contains("db2.example.com"), "stdout: {stdout2}");
    assert!(!stdout2.contains("db1.example.com"), "stdout: {stdout2}");
}

// ─── unknown subcommand ───────────────────────────────────────────────────────

#[test]
fn unknown_subcommand_exits_nonzero() {
    let db = tmp_db();
    let out = cmd(db.path().to_str().unwrap())
        .arg("bogus")
        .output()
        .unwrap();
    assert!(!out.status.success());
}
