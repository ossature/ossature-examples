## Spec Dependency Graph

- CALENDAR_FORMAT: depends on [(none)]
- RELATIVE_TIME: depends on [(none)]

## Spec Summaries

### CALENDAR_FORMAT: Calendar Format

**Overview:** Pure functions for contextual calendar date formatting. Converts timestamps into human-friendly date strings like "Today", "Yesterday", "Last Friday", or "March 5, 2024", and formats date ranges with smart abbreviation like "March 5–7, 2024".

All functions are pure — no side effects, no I/O, no system clock access. The reference timestamp is always passed explicitly. All timestamps are interpreted in UTC by default.

**Requirements:**
- human_date
- date_range

**Components:**
- Calendar Format Module: Calendar date formatting functions: human_date and date_range. Pure functions with no side effects. All calendar calculations use UTC.
  ```python
  from datetime import datetime

def human_date(timestamp: int | float | str | datetime,
               reference: int | float | str | datetime) -> str: ...

def date_range(start: int | float | str | datetime,
               end: int | float | str | datetime) -> str: ...
  ```
- Calendar Format Tests: Test file that loads test cases from tests.yaml and runs them against the calendar format functions. Covers human_date and date_range sections. [depends: Calendar Format Module]
  ```python
  import pytest

# Test functions are generated from tests.yaml
# Each test case becomes a parameterized test
  ```

**External Dependencies:**
- stdlib: Python 3.12+ standard library only, no third-party runtime dependencies
- pytest: test runner for parameterized test cases

### RELATIVE_TIME: Relative Time

**Overview:** Pure functions for human-friendly relative time formatting and parsing. Converts durations and timestamp differences into readable strings like "3 hours ago" or "2h 30m", and parses human-written duration strings like "2 hours 30 minutes" back into seconds.

All functions are pure — no side effects, no I/O, no system clock access. The reference timestamp is always passed explicitly.

**Requirements:**
- timeago
- duration
- parse_duration

**Components:**
- Relative Time Module: All relative-time functions: timeago, duration, parse_duration. Pure functions with no side effects.
  ```python
  from datetime import datetime

def timeago(timestamp: int | float | str | datetime,
            reference: int | float | str | datetime) -> str: ...

def duration(seconds: int | float, *, compact: bool = False, max_units: int = 2) -> str: ...

def parse_duration(text: str) -> int | float: ...
  ```
- Relative Time Tests: Test file that loads test cases from tests.yaml and runs them against the relative time functions. Covers timeago, duration, and parse_duration sections. [depends: Relative Time Module]
  ```python
  import pytest

# Test functions are generated from tests.yaml
# Each test case becomes a parameterized test
  ```

**External Dependencies:**
- stdlib: Python 3.12+ standard library only, no third-party runtime dependencies
- pytest: test runner for parameterized test cases
