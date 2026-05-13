Perfect! All tests pass. Let me verify that the implementation covers all the requirements from the task:

1. ✅ `load()` with a missing file (auto-creates empty store) - `test_load_missing_file_auto_creates_empty_store`
2. ✅ `load()` with valid JSON - `test_load_valid_json`
3. ✅ `load()` with corrupted JSON (exits code 1) - `test_load_corrupted_json_exits_code_1`
4. ✅ `save()` writes pretty-printed JSON with string amounts - `test_save_writes_pretty_printed_json_with_string_amounts`
5. ✅ Round-trip fidelity - `test_round_trip_fidelity`

The tests cover all the specified requirements and handle the error cases mentioned in the specification (corrupted JSON file). The implementation is idiomatic Python and follows the interface defined in the architecture exactly.