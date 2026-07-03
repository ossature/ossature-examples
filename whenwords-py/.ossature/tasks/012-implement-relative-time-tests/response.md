I have implemented `tests/test_relative.py` according to the architecture context and specifications.

### Summary of Implementation:
- Loaded and parsed test cases dynamically using standard Pytest parameterization from `tests/tests.yaml` for:
  - `timeago` (relative time)
  - `duration` 
  - `parse_duration`
- Added comprehensive custom verification cases covering:
  - Datetime objects (both timezone-aware and naive) and ISO 8601 strings
  - Appropriate error verification (`ValueError` testing)
  - Zero/negative durations, edge/out-of-range floats, and malformed inputs parsing.