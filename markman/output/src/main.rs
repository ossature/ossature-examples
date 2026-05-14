use markman::cli;
use markman::storage;
use markman::web;

use clap::Parser;
use cli::{Cli, Commands};

fn resolve_db_path(db: &str) -> String {
    if db.starts_with("~/") {
        let home = std::env::var("HOME").unwrap_or_else(|_| ".".to_string());
        format!("{}/{}", home, &db[2..])
    } else {
        db.to_string()
    }
}

fn main() {
    let cli = Cli::parse();
    let db_path = resolve_db_path(&cli.db);

    match cli.command {
        Commands::Add { url, desc, tags } => {
            let conn = match storage::init_db(&db_path) {
                Ok(c) => c,
                Err(e) => {
                    eprintln!("error: {}", e);
                    std::process::exit(1);
                }
            };
            match storage::add_bookmark(&conn, &url, &desc, &tags) {
                Ok(_) => println!("added: {}", url),
                Err(e) => {
                    eprintln!("error: {}", e);
                    std::process::exit(1);
                }
            }
        }

        Commands::List { query } => {
            let conn = match storage::init_db(&db_path) {
                Ok(c) => c,
                Err(e) => {
                    eprintln!("error: {}", e);
                    std::process::exit(1);
                }
            };
            match storage::search_bookmarks(&conn, &query) {
                Ok(bookmarks) => {
                    if bookmarks.is_empty() {
                        println!("no bookmarks found.");
                    } else {
                        for b in bookmarks {
                            println!("[{}] {} | {} | tags: {}", b.id, b.url, b.desc, b.tags);
                        }
                    }
                }
                Err(e) => {
                    eprintln!("error: {}", e);
                    std::process::exit(1);
                }
            }
        }

        Commands::Remove { id } => {
            if id <= 0 {
                eprintln!("error: id must be a positive integer");
                std::process::exit(2);
            }
            let conn = match storage::init_db(&db_path) {
                Ok(c) => c,
                Err(e) => {
                    eprintln!("error: {}", e);
                    std::process::exit(1);
                }
            };
            match storage::remove_bookmark(&conn, id) {
                Ok(()) => println!("removed: {}", id),
                Err(e) => {
                    eprintln!("error: {}", e);
                    std::process::exit(1);
                }
            }
        }

        Commands::Serve { port } => {
            let conn = match storage::init_db(&db_path) {
                Ok(c) => c,
                Err(e) => {
                    eprintln!("error: {}", e);
                    std::process::exit(1);
                }
            };
            web::serve(conn, port);
        }
    }
}
