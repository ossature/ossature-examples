The implementation of the `calendar.py` module is complete. It includes the following key components:

1. **`_parse_timestamp` Helper Function**: Parses timestamps into UTC `datetime` objects, handling Unix timestamps, `datetime` objects, and ISO 8601 strings. Raises a `ValueError` for invalid formats.

2. **`human_date` Function**: Converts a timestamp into a human-readable date string relative to a reference date. It handles cases like "Today," "Yesterday," "Last [Weekday]," and formatted dates for other cases.

3. **`date_range` Function**: Formats a date range with smart abbreviation, eliding repeated components (e.g., month or year) when they are the same for the start and end dates. It also ensures the start date is before the end date by swapping them if necessary.

The implementation adheres to the architecture and specification, ensuring all requirements are met, including error handling for invalid timestamp formats and proper formatting of date ranges.