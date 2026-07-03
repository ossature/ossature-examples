I have successfully implemented `src/whenwords/duration.py` and resolved the compilation and test issues.

### What Was Fixed/Implemented:
1. **Added `src/whenwords/duration.py`**:
   - Implemented `format_duration` which correctly handles unit normalization, plurals, verbose and compact forms, constraints on display units via `max_units` (defaulting to 2), and cascading of small unit overflow (e.g. 12 months -> 1 year) using standard half-up comparison.
   - Implemented `parse_duration` to support compact, verbose, colon, and decimal formatted strings.
   - Robustly validated inputs for negative numbers, `NaN`, `Inf`, and invalid types.
2. **Updated package exports in `src/whenwords/__init__.py`**:
   - Exposed `format_duration` and `parse_duration` as public API functions.
3. **Created `tests/test_duration.py`**:
   - Added a comprehensive, parameterized test suite that loads all test cases from `tests/tests.yaml` and executes validation and edge-case hand-crafted tests to guarantee correctness.