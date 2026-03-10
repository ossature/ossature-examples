The tests for the storage module have been implemented in `tests/test_storage.py`. The tests cover the following scenarios:

1. **Default Data Handling**: Verifies that `load()` returns the default empty data structure when the file does not exist.
2. **JSON Writing**: Ensures that `save()` writes valid, pretty-printed JSON to the file.
3. **Round-Trip Data**: Confirms that data saved by `save()` can be correctly loaded back using `load()`.
4. **Corrupted JSON Handling**: Tests that `load()` exits with code 1 when encountering corrupted JSON.

The tests use the `tmp_path` fixture to avoid touching the real filesystem, ensuring isolation and cleanliness.