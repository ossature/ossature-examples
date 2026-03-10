Excellent! All the tests in `tests/test_storage.py` are now passing. The issue was resolved by adding `pytest` to the `dev-dependencies` section in the `pyproject.toml` file and installing the dependencies using `uv sync`.

The tests cover the following scenarios:
1. `test_load_returns_empty_default_when_file_absent`: Verifies that the `load` function returns default data when the file does not exist.
2. `test_save_writes_valid_pretty_printed_json`: Ensures that the `save` function writes valid, pretty-printed JSON.
3. `test_load_round_trips_saved_data_correctly`: Confirms that the `load` function correctly round-trips saved data.
4. `test_load_exits_with_code_1_on_corrupted_json`: Checks that the `load` function exits with code 1 when encountering corrupted JSON.

All tests are passing, and the environment is now properly set up.