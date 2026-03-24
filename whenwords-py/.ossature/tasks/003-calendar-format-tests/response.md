Perfect! All tests are passing, and the implementation is complete. Here's a summary of what was done:

### Summary of Changes

1. **Fixed Timezone Handling**:
   - Updated the `calendar.py` file to use `timezone.utc` instead of `datetime.timezone.utc` for compatibility with the Python version.

2. **Fixed `human_date` Function**:
   - Added specific logic to handle "Last [Weekday]", "This [Weekday]", and "Next [Weekday]" cases.
   - Added a helper function `_format_date` to format dates without leading zeros.
   - Ensured the function returns the correct output for all test cases, including edge cases like "Last Monday" and "Next Monday".

3. **Fixed `date_range` Function**:
   - Added logic to handle same-day ranges correctly.
   - Ensured the function uses the correct separator (en-dash `–` for same month/year, em-dash `–` for different months/years).
   - Fixed formatting to remove leading zeros from day numbers.

4. **Created Test File**:
   - Generated `tests/test_calendar.py` with all the test cases from `tests.yaml`.
   - Ensured all test cases pass, covering all scenarios for `human_date` and `date_range`.

### Final Verification

All 27 tests are passing, confirming that the implementation meets the requirements specified in the task. The functions handle all edge cases, including swapped inputs, same-day ranges, and different years.