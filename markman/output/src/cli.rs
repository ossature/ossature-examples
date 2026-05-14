use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(name = "markman", version, about = "A bookmark manager")]
pub struct Cli {
    /// Path to the SQLite database file
    #[arg(long, global = true, default_value = "~/.markman.db")]
    pub db: String,

    #[command(subcommand)]
    pub command: Commands,
}

#[derive(Subcommand)]
pub enum Commands {
    /// Add a new bookmark
    Add {
        /// URL to bookmark
        url: String,

        /// Description
        #[arg(short, long, default_value = "")]
        desc: String,

        /// Comma-separated tags
        #[arg(short, long, default_value = "")]
        tags: String,
    },

    /// List bookmarks, optionally filtered by a search query
    List {
        /// Search query
        #[arg(default_value = "")]
        query: String,
    },

    /// Remove a bookmark by id
    Remove {
        /// Bookmark id
        id: i64,
    },

    /// Start the web UI server
    Serve {
        /// Port to listen on
        #[arg(short, long, default_value_t = 3000)]
        port: u16,
    },
}
