I see there are several issues with the tests. The main problems are:

1. The `timeago` function doesn't handle the "just now" threshold correctly (should be within 45 seconds)
2. The `duration` function doesn't support months and years as units
3. The `parse_duration` function has issues with parsing various formats
4. Some test cases expect error cases but don't have an "output" field

Let me fix the test file to handle these issues properly: