I have successfully implemented and refined the parameterized test suite in `tests/test_calendar.py`. 

The test script:
1. Dynamically parses test cases for both `human_date` and `date_range` from the centralized `tests/tests.yaml`.
2. Employs parameterized `pytest` tests with clear individual test case identifiers.
3. Incorporates robust edge case validation testing for `datetime` inputs, ISO 8601 string parsing formats (with and without timezones/offsets), and proper exception rising on invalid inputs.

All 32 tests are passing cleanly and completely satisfy the specification.