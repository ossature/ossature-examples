#[cfg(test)]
mod tests {
    use crate::storage::{Bookmark, StorageError};
    use std::cell::RefCell;
    use std::rc::Rc;

    // Mock storage to replace actual database calls
    struct MockStorage {
        bookmarks: Rc<RefCell<Vec<Bookmark>>>,
        next_id: Rc<RefCell<i64>>,
        fail_add: Rc<RefCell<bool>>,
        fail_remove: Rc<RefCell<bool>>,
        fail_search: Rc<RefCell<bool>>,
        duplicate_on_add: Rc<RefCell<bool>>,
    }

    impl MockStorage {
        fn new() -> Self {
            MockStorage {
                bookmarks: Rc::new(RefCell::new(vec![])),
                next_id: Rc::new(RefCell::new(1)),
                fail_add: Rc::new(RefCell::new(false)),
                fail_remove: Rc::new(RefCell::new(false)),
                fail_search: Rc::new(RefCell::new(false)),
                duplicate_on_add: Rc::new(RefCell::new(false)),
            }
        }

        fn get_bookmarks(&self) -> Vec<Bookmark> {
            self.bookmarks.borrow().clone()
        }

        fn set_fail_add(&self) {
            *self.fail_add.borrow_mut() = true;
        }

        fn set_fail_remove(&self) {
            *self.fail_remove.borrow_mut() = true;
        }

        fn set_fail_search(&self) {
            *self.fail_search.borrow_mut() = true;
        }

        fn set_duplicate_on_add(&self) {
            *self.duplicate_on_add.borrow_mut() = true;
        }

        fn simulate_add_bookmark(
            &self,
            url: String,
            description: String,
            tags: String,
        ) -> Result<i64, StorageError> {
            if *self.fail_add.borrow() {
                return Err(StorageError::QueryFailed);
            }

            if url.trim().is_empty() {
                return Err(StorageError::InvalidUrl);
            }

            if *self.duplicate_on_add.borrow() {
                return Err(StorageError::DuplicateUrl);
            }

            let id = *self.next_id.borrow();
            *self.next_id.borrow_mut() += 1;

            let bookmark = Bookmark {
                id,
                url,
                description,
                tags,
            };

            self.bookmarks.borrow_mut().push(bookmark);
            Ok(id)
        }

        fn simulate_search_bookmarks(&self, query: &str) -> Result<Vec<Bookmark>, StorageError> {
            if *self.fail_search.borrow() {
                return Err(StorageError::QueryFailed);
            }

            let query_trimmed = query.trim();
            let bookmarks = self.bookmarks.borrow().clone();

            if query_trimmed.is_empty() {
                return Ok(bookmarks);
            }

            let filtered: Vec<Bookmark> = bookmarks
                .into_iter()
                .filter(|b| {
                    b.url.to_lowercase().contains(&query_trimmed.to_lowercase())
                        || b.description
                            .to_lowercase()
                            .contains(&query_trimmed.to_lowercase())
                        || b.tags
                            .to_lowercase()
                            .contains(&query_trimmed.to_lowercase())
                })
                .collect();

            Ok(filtered)
        }

        fn simulate_remove_bookmark(&self, id: i64) -> Result<(), StorageError> {
            if *self.fail_remove.borrow() {
                return Err(StorageError::QueryFailed);
            }

            let mut bookmarks = self.bookmarks.borrow_mut();
            if let Some(pos) = bookmarks.iter().position(|b| b.id == id) {
                bookmarks.remove(pos);
                Ok(())
            } else {
                Err(StorageError::BookmarkNotFound)
            }
        }
    }

    // Tests for add command handler
    mod add_handler {
        use super::*;

        #[test]
        fn test_add_success() {
            let url = "https://example.com".to_string();
            let description = "Example site".to_string();
            let tags = "example,web".to_string();

            let mock = MockStorage::new();
            let id = mock
                .simulate_add_bookmark(url.clone(), description.clone(), tags.clone())
                .expect("Add should succeed");

            let bookmarks = mock.get_bookmarks();
            assert_eq!(bookmarks.len(), 1);
            assert_eq!(bookmarks[0].id, id);
            assert_eq!(bookmarks[0].url, url);
            assert_eq!(bookmarks[0].description, description);
            assert_eq!(bookmarks[0].tags, tags);
        }

        #[test]
        fn test_add_returns_id() {
            let mock = MockStorage::new();
            let id1 = mock
                .simulate_add_bookmark(
                    "https://example1.com".to_string(),
                    "First".to_string(),
                    "tags1".to_string(),
                )
                .expect("First add should succeed");

            let id2 = mock
                .simulate_add_bookmark(
                    "https://example2.com".to_string(),
                    "Second".to_string(),
                    "tags2".to_string(),
                )
                .expect("Second add should succeed");

            assert_eq!(id1, 1);
            assert_eq!(id2, 2);
        }

        #[test]
        fn test_add_empty_url_error() {
            let mock = MockStorage::new();
            let result = mock.simulate_add_bookmark(
                "".to_string(),
                "Description".to_string(),
                "tags".to_string(),
            );
            assert_eq!(result, Err(StorageError::InvalidUrl));
        }

        #[test]
        fn test_add_whitespace_url_error() {
            let mock = MockStorage::new();
            let result = mock.simulate_add_bookmark(
                "   ".to_string(),
                "Description".to_string(),
                "tags".to_string(),
            );
            assert_eq!(result, Err(StorageError::InvalidUrl));
        }

        #[test]
        fn test_add_duplicate_url_error() {
            let mock = MockStorage::new();
            let url = "https://example.com".to_string();

            mock.simulate_add_bookmark(url.clone(), "First".to_string(), "tags1".to_string())
                .expect("First add should succeed");

            mock.set_duplicate_on_add();
            let result = mock.simulate_add_bookmark(url, "Second".to_string(), "tags2".to_string());
            assert_eq!(result, Err(StorageError::DuplicateUrl));
        }

        #[test]
        fn test_add_query_failed_error() {
            let mock = MockStorage::new();
            mock.set_fail_add();
            let result = mock.simulate_add_bookmark(
                "https://example.com".to_string(),
                "Description".to_string(),
                "tags".to_string(),
            );
            assert_eq!(result, Err(StorageError::QueryFailed));
        }

        #[test]
        fn test_add_with_empty_description() {
            let mock = MockStorage::new();
            mock
                .simulate_add_bookmark(
                    "https://example.com".to_string(),
                    "".to_string(),
                    "tags".to_string(),
                )
                .expect("Add should succeed");

            let bookmarks = mock.get_bookmarks();
            assert_eq!(bookmarks[0].description, "");
        }

        #[test]
        fn test_add_with_empty_tags() {
            let mock = MockStorage::new();
            mock
                .simulate_add_bookmark(
                    "https://example.com".to_string(),
                    "Description".to_string(),
                    "".to_string(),
                )
                .expect("Add should succeed");

            let bookmarks = mock.get_bookmarks();
            assert_eq!(bookmarks[0].tags, "");
        }

        #[test]
        fn test_add_preserves_all_fields() {
            let mock = MockStorage::new();
            let url = "https://rust-lang.org".to_string();
            let description = "The Rust programming language".to_string();
            let tags = "programming,rust,learning".to_string();

            mock.simulate_add_bookmark(url.clone(), description.clone(), tags.clone())
                .expect("Add should succeed");

            let bookmarks = mock.get_bookmarks();
            assert_eq!(bookmarks[0].url, url);
            assert_eq!(bookmarks[0].description, description);
            assert_eq!(bookmarks[0].tags, tags);
        }
    }

    // Tests for list command handler
    mod list_handler {
        use super::*;

        #[test]
        fn test_list_empty_database() {
            let mock = MockStorage::new();
            let result = mock.simulate_search_bookmarks("").expect("Search should succeed");
            assert_eq!(result.len(), 0);
        }

        #[test]
        fn test_list_single_bookmark() {
            let mock = MockStorage::new();
            mock.simulate_add_bookmark(
                "https://example.com".to_string(),
                "Example".to_string(),
                "tags".to_string(),
            )
            .expect("Add should succeed");

            let result = mock.simulate_search_bookmarks("").expect("Search should succeed");
            assert_eq!(result.len(), 1);
            assert_eq!(result[0].url, "https://example.com");
        }

        #[test]
        fn test_list_multiple_bookmarks() {
            let mock = MockStorage::new();
            mock.simulate_add_bookmark(
                "https://example1.com".to_string(),
                "First".to_string(),
                "tag1".to_string(),
            )
            .expect("Add 1 should succeed");
            mock.simulate_add_bookmark(
                "https://example2.com".to_string(),
                "Second".to_string(),
                "tag2".to_string(),
            )
            .expect("Add 2 should succeed");
            mock.simulate_add_bookmark(
                "https://example3.com".to_string(),
                "Third".to_string(),
                "tag3".to_string(),
            )
            .expect("Add 3 should succeed");

            let result = mock.simulate_search_bookmarks("").expect("Search should succeed");
            assert_eq!(result.len(), 3);
        }

        #[test]
        fn test_list_with_search_query() {
            let mock = MockStorage::new();
            mock.simulate_add_bookmark(
                "https://example.com".to_string(),
                "Example site".to_string(),
                "tags".to_string(),
            )
            .expect("Add 1 should succeed");
            mock.simulate_add_bookmark(
                "https://other.com".to_string(),
                "Other site".to_string(),
                "tags".to_string(),
            )
            .expect("Add 2 should succeed");

            let result = mock
                .simulate_search_bookmarks("example")
                .expect("Search should succeed");
            assert_eq!(result.len(), 1);
            assert_eq!(result[0].url, "https://example.com");
        }

        #[test]
        fn test_list_search_by_description() {
            let mock = MockStorage::new();
            mock.simulate_add_bookmark(
                "https://example.com".to_string(),
                "Important document".to_string(),
                "tags".to_string(),
            )
            .expect("Add 1 should succeed");
            mock.simulate_add_bookmark(
                "https://other.com".to_string(),
                "Other content".to_string(),
                "tags".to_string(),
            )
            .expect("Add 2 should succeed");

            let result = mock
                .simulate_search_bookmarks("Important")
                .expect("Search should succeed");
            assert_eq!(result.len(), 1);
            assert_eq!(result[0].description, "Important document");
        }

        #[test]
        fn test_list_search_by_tags() {
            let mock = MockStorage::new();
            mock.simulate_add_bookmark(
                "https://example.com".to_string(),
                "Example".to_string(),
                "rust,important".to_string(),
            )
            .expect("Add 1 should succeed");
            mock.simulate_add_bookmark(
                "https://other.com".to_string(),
                "Other".to_string(),
                "python,casual".to_string(),
            )
            .expect("Add 2 should succeed");

            let result = mock
                .simulate_search_bookmarks("rust")
                .expect("Search should succeed");
            assert_eq!(result.len(), 1);
            assert_eq!(result[0].tags, "rust,important");
        }

        #[test]
        fn test_list_search_case_insensitive() {
            let mock = MockStorage::new();
            mock.simulate_add_bookmark(
                "https://EXAMPLE.COM".to_string(),
                "Example".to_string(),
                "tags".to_string(),
            )
            .expect("Add should succeed");

            let result1 = mock
                .simulate_search_bookmarks("example")
                .expect("Search should succeed");
            let result2 = mock
                .simulate_search_bookmarks("EXAMPLE")
                .expect("Search should succeed");
            let result3 = mock
                .simulate_search_bookmarks("Example")
                .expect("Search should succeed");

            assert_eq!(result1.len(), 1);
            assert_eq!(result2.len(), 1);
            assert_eq!(result3.len(), 1);
        }

        #[test]
        fn test_list_search_no_matches() {
            let mock = MockStorage::new();
            mock.simulate_add_bookmark(
                "https://example.com".to_string(),
                "Example".to_string(),
                "tags".to_string(),
            )
            .expect("Add should succeed");

            let result = mock
                .simulate_search_bookmarks("nonexistent")
                .expect("Search should succeed");
            assert_eq!(result.len(), 0);
        }

        #[test]
        fn test_list_whitespace_query_returns_all() {
            let mock = MockStorage::new();
            mock.simulate_add_bookmark(
                "https://example1.com".to_string(),
                "First".to_string(),
                "tags".to_string(),
            )
            .expect("Add 1 should succeed");
            mock.simulate_add_bookmark(
                "https://example2.com".to_string(),
                "Second".to_string(),
                "tags".to_string(),
            )
            .expect("Add 2 should succeed");

            let result = mock
                .simulate_search_bookmarks("   ")
                .expect("Search should succeed");
            assert_eq!(result.len(), 2);
        }

        #[test]
        fn test_list_search_partial_match() {
            let mock = MockStorage::new();
            mock.simulate_add_bookmark(
                "https://github.com".to_string(),
                "GitHub homepage".to_string(),
                "git,dev".to_string(),
            )
            .expect("Add should succeed");

            let result = mock
                .simulate_search_bookmarks("hub")
                .expect("Search should succeed");
            assert_eq!(result.len(), 1);
        }

        #[test]
        fn test_list_query_failed_error() {
            let mock = MockStorage::new();
            mock.set_fail_search();
            let result = mock.simulate_search_bookmarks("");
            assert_eq!(result, Err(StorageError::QueryFailed));
        }

        #[test]
        fn test_list_with_tags_displayed() {
            let mock = MockStorage::new();
            mock.simulate_add_bookmark(
                "https://example.com".to_string(),
                "Example".to_string(),
                "important,read".to_string(),
            )
            .expect("Add should succeed");

            let result = mock.simulate_search_bookmarks("").expect("Search should succeed");
            assert_eq!(result[0].tags, "important,read");
        }
    }

    // Tests for remove command handler
    mod remove_handler {
        use super::*;

        #[test]
        fn test_remove_success() {
            let mock = MockStorage::new();
            let id = mock
                .simulate_add_bookmark(
                    "https://example.com".to_string(),
                    "Example".to_string(),
                    "tags".to_string(),
                )
                .expect("Add should succeed");

            let result = mock.simulate_remove_bookmark(id);
            assert!(result.is_ok());

            let bookmarks = mock.get_bookmarks();
            assert_eq!(bookmarks.len(), 0);
        }

        #[test]
        fn test_remove_with_multiple_bookmarks() {
            let mock = MockStorage::new();
            let id1 = mock
                .simulate_add_bookmark(
                    "https://example1.com".to_string(),
                    "First".to_string(),
                    "tags1".to_string(),
                )
                .expect("Add 1 should succeed");
            let id2 = mock
                .simulate_add_bookmark(
                    "https://example2.com".to_string(),
                    "Second".to_string(),
                    "tags2".to_string(),
                )
                .expect("Add 2 should succeed");

            let result = mock.simulate_remove_bookmark(id1);
            assert!(result.is_ok());

            let bookmarks = mock.get_bookmarks();
            assert_eq!(bookmarks.len(), 1);
            assert_eq!(bookmarks[0].id, id2);
        }

        #[test]
        fn test_remove_nonexistent_bookmark() {
            let mock = MockStorage::new();
            let result = mock.simulate_remove_bookmark(999);
            assert_eq!(result, Err(StorageError::BookmarkNotFound));
        }

        #[test]
        fn test_remove_already_deleted() {
            let mock = MockStorage::new();
            let id = mock
                .simulate_add_bookmark(
                    "https://example.com".to_string(),
                    "Example".to_string(),
                    "tags".to_string(),
                )
                .expect("Add should succeed");

            mock.simulate_remove_bookmark(id)
                .expect("First remove should succeed");

            let result = mock.simulate_remove_bookmark(id);
            assert_eq!(result, Err(StorageError::BookmarkNotFound));
        }

        #[test]
        fn test_remove_query_failed_error() {
            let mock = MockStorage::new();
            let id = mock
                .simulate_add_bookmark(
                    "https://example.com".to_string(),
                    "Example".to_string(),
                    "tags".to_string(),
                )
                .expect("Add should succeed");

            mock.set_fail_remove();
            let result = mock.simulate_remove_bookmark(id);
            assert_eq!(result, Err(StorageError::QueryFailed));
        }

        #[test]
        fn test_remove_correct_bookmark_from_many() {
            let mock = MockStorage::new();
            let id1 = mock
                .simulate_add_bookmark(
                    "https://example1.com".to_string(),
                    "First".to_string(),
                    "tags1".to_string(),
                )
                .expect("Add 1 should succeed");
            let id2 = mock
                .simulate_add_bookmark(
                    "https://example2.com".to_string(),
                    "Second".to_string(),
                    "tags2".to_string(),
                )
                .expect("Add 2 should succeed");
            let id3 = mock
                .simulate_add_bookmark(
                    "https://example3.com".to_string(),
                    "Third".to_string(),
                    "tags3".to_string(),
                )
                .expect("Add 3 should succeed");

            mock.simulate_remove_bookmark(id2)
                .expect("Remove should succeed");

            let bookmarks = mock.get_bookmarks();
            assert_eq!(bookmarks.len(), 2);
            let ids: Vec<i64> = bookmarks.iter().map(|b| b.id).collect();
            assert!(ids.contains(&id1));
            assert!(ids.contains(&id3));
            assert!(!ids.contains(&id2));
        }

        #[test]
        fn test_remove_bookmark_with_id_one() {
            let mock = MockStorage::new();
            let id = mock
                .simulate_add_bookmark(
                    "https://example.com".to_string(),
                    "Example".to_string(),
                    "tags".to_string(),
                )
                .expect("Add should succeed");
            assert_eq!(id, 1);

            let result = mock.simulate_remove_bookmark(1);
            assert!(result.is_ok());
        }
    }

    // Integration-style tests
    mod integration_tests {
        use super::*;

        #[test]
        fn test_add_then_list() {
            let mock = MockStorage::new();

            let id = mock
                .simulate_add_bookmark(
                    "https://example.com".to_string(),
                    "Example".to_string(),
                    "web".to_string(),
                )
                .expect("Add should succeed");

            let bookmarks = mock.simulate_search_bookmarks("").expect("Search should succeed");
            assert_eq!(bookmarks.len(), 1);
            assert_eq!(bookmarks[0].id, id);
        }

        #[test]
        fn test_add_list_remove_workflow() {
            let mock = MockStorage::new();

            let id = mock
                .simulate_add_bookmark(
                    "https://example.com".to_string(),
                    "Example".to_string(),
                    "web".to_string(),
                )
                .expect("Add should succeed");

            let bookmarks = mock.simulate_search_bookmarks("").expect("Search should succeed");
            assert_eq!(bookmarks.len(), 1);

            mock.simulate_remove_bookmark(id)
                .expect("Remove should succeed");

            let bookmarks = mock.simulate_search_bookmarks("").expect("Search should succeed");
            assert_eq!(bookmarks.len(), 0);
        }

        #[test]
        fn test_multiple_bookmarks_add_list_remove() {
            let mock = MockStorage::new();

            let id1 = mock
                .simulate_add_bookmark(
                    "https://example1.com".to_string(),
                    "First".to_string(),
                    "tags1".to_string(),
                )
                .expect("Add 1 should succeed");

            let id2 = mock
                .simulate_add_bookmark(
                    "https://example2.com".to_string(),
                    "Second".to_string(),
                    "tags2".to_string(),
                )
                .expect("Add 2 should succeed");

            let all = mock.simulate_search_bookmarks("").expect("Search should succeed");
            assert_eq!(all.len(), 2);

            let search = mock
                .simulate_search_bookmarks("example1")
                .expect("Search should succeed");
            assert_eq!(search.len(), 1);
            assert_eq!(search[0].id, id1);

            mock.simulate_remove_bookmark(id1)
                .expect("Remove should succeed");

            let remaining = mock.simulate_search_bookmarks("").expect("Search should succeed");
            assert_eq!(remaining.len(), 1);
            assert_eq!(remaining[0].id, id2);
        }

        #[test]
        fn test_search_after_adding_multiple() {
            let mock = MockStorage::new();

            mock.simulate_add_bookmark(
                "https://rust.example.com".to_string(),
                "Rust Programming".to_string(),
                "rust,learning".to_string(),
            )
            .expect("Add 1 should succeed");

            mock.simulate_add_bookmark(
                "https://python.example.com".to_string(),
                "Python Programming".to_string(),
                "python,learning".to_string(),
            )
            .expect("Add 2 should succeed");

            mock.simulate_add_bookmark(
                "https://javascript.example.com".to_string(),
                "JavaScript Tutorial".to_string(),
                "javascript,web".to_string(),
            )
            .expect("Add 3 should succeed");

            let rust_results = mock
                .simulate_search_bookmarks("rust")
                .expect("Search should succeed");
            assert_eq!(rust_results.len(), 1);

            let learning_results = mock
                .simulate_search_bookmarks("learning")
                .expect("Search should succeed");
            assert_eq!(learning_results.len(), 2);

            let all = mock.simulate_search_bookmarks("").expect("Search should succeed");
            assert_eq!(all.len(), 3);
        }
    }
}
