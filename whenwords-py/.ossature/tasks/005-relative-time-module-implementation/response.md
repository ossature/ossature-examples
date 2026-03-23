Perfect! All tests are passing. The implementation is complete and adheres to the specification. Here's a summary of what was implemented:

1. **`timeago` function**: Converts a timestamp into a human-readable relative time string (e.g., "3 hours ago" or "in 5 minutes").
2. **`duration` function**: Formats a duration in seconds into a human-readable string, with options for compact or verbose output.
3. **`parse_duration` function**: Parses a human-readable duration string (e.g., "2h 30m") into seconds.

The implementation handles all specified input types (Unix timestamps, `datetime` objects, and ISO 8601 strings) and adheres to the constraints (Python 3.12+, half-up rounding, and proper pluralization).