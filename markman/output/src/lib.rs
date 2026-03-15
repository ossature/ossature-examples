#[path = "storage/mod.rs"]
pub mod storage;
pub mod commands;
pub mod web;

pub use storage::{Bookmark, StorageError};
pub use commands::{handle_add, handle_list, handle_remove};
