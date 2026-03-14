use clap::Parser;
use markman::web;

#[derive(Parser)]
#[command(name = "markman")]
#[command(about = "A lightweight bookmark manager", long_about = None)]
struct Args {
    /// Port to run the web server on
    #[arg(short, long, default_value = "8080")]
    port: u16,

    /// Path to the SQLite database
    #[arg(short, long, default_value = "~/.markman.db")]
    db: String,
}

fn expand_path(path: &str) -> String {
    if path.starts_with('~') {
        match std::env::var("HOME") {
            Ok(home) => path.replacen('~', &home, 1),
            Err(_) => path.to_string(),
        }
    } else {
        path.to_string()
    }
}

#[tokio::main]
async fn main() {
    let args = Args::parse();
    let db_path = expand_path(&args.db);

    // Start the web server
    match web::run_server(&db_path, args.port).await {
        Ok(()) => {
            println!("Server started on http://127.0.0.1:{}", args.port);
        }
        Err(e) => {
            eprintln!("Failed to start server: {}", e);
            std::process::exit(1);
        }
    }
}
