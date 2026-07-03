---
id: RELATIVE_TIME
status: draft
priority: high
depends: []
---

# Relative Time

## Overview

Pure functions for human-friendly relative time formatting and parsing. Converts durations and timestamp differences into readable strings like "3 hours ago" or "2h 30m", and parses human-written duration strings like "2 hours 30 minutes" back into seconds.

All functions are pure — no side effects, no I/O, no system clock access. The reference timestamp is always passed explicitly.

## Goals

- Format timestamp differences as relative time strings ("3 hours ago", "in 5 minutes")
- Format raw durations in verbose ("1 hour, 30 minutes") or compact ("1h 30m") style
- Parse a wide variety of human-written duration strings into seconds
- English output only (v0.1)

## Non-Goals

- Locale or i18n support
- Timezone handling (relative functions operate on durations between timestamps)
- Calendar-aware date formatting (see CALENDAR_FORMAT spec)
- Package distribution scaffolding (no setup.py, pyproject.toml build metadata)

## Requirements

### timeago

Convert a timestamp difference into a human-readable relative time string. The reference timestamp represents "now" and must be passed explicitly.

**Accepts:** timestamp (Unix seconds, datetime, or ISO 8601 string), reference (Unix seconds, datetime, or ISO 8601 string)

**Returns:** A relative time string

**Errors:**

- Invalid timestamp format -> raise ValueError with descriptive message

### duration

Format a number of seconds as a human-readable duration string. Not relative to any reference time.

**Accepts:** seconds (non-negative number), and optional keyword arguments: `compact` (bool, default False), `max_units` (int, default 2)

**Returns:** A formatted duration string

**Errors:**

- Negative seconds -> raise ValueError with descriptive message
- NaN or infinite -> raise ValueError with descriptive message

### parse_duration

Parse a human-written duration string into total seconds.

**Accepts:** A string in any of these formats: compact ("2h30m", "2h 30m", "2h, 30m"), verbose ("2 hours 30 minutes", "2 hours and 30 minutes"), decimal ("2.5 hours", "1.5h"), single unit ("90 minutes", "90m", "90min"), colon notation ("2:30" as h:mm, "2:30:00" as h:mm:ss)

**Returns:** Total seconds as a number

**Errors:**

- Empty string -> raise ValueError
- No parseable units found -> raise ValueError
- Negative values -> raise ValueError
- Bare number with no unit -> raise ValueError

## Constraints

- Python 3.12+ standard library only, no third-party dependencies
- All timestamps are Unix seconds (integer or float); also accept `datetime` objects and ISO 8601 strings. Timezone-naive datetimes or naive ISO 8601 strings are to be treated as UTC when converting to Unix epoch timestamps.
- Strings are UTF-8
- Deterministic: same inputs always produce same output
- Use half-up rounding (2.5 rounds to 3, 2.4 rounds to 2)
- Pluralization: 1 = singular ("1 minute"), 0 or 2+ = plural ("0 seconds", "2 minutes")

## Examples

### timeago basic

**Input:**

```
timeago(1704067110, reference=1704067200)
```

**Output:**

```
2 minutes ago
```

### timeago future

**Input:**

```
timeago(1704078000, reference=1704067200)
```

**Output:**

```
in 3 hours
```

### duration verbose

**Input:**

```
duration(3661)
```

**Output:**

```
1 hour, 1 minute
```

### duration compact

**Input:**

```
duration(3661, compact=True)
```

**Output:**

```
1h 1m
```

### parse_duration mixed

**Input:**

```
parse_duration("1 day, 2 hours, and 30 minutes")
```

**Output:**

```
95400
```

### parse_duration colon

**Input:**

```
parse_duration("2:30")
```

**Output:**

```
9000
```

## Acceptance Criteria

- [ ] All timeago, duration, and parse_duration test cases from tests.yaml pass
- [ ] Functions accept `datetime` objects and ISO 8601 strings in addition to Unix timestamps
- [ ] Errors raise `ValueError` with descriptive messages
- [ ] Pluralization is correct for all unit counts
- [ ] Future timestamps produce "in X" format
- [ ] Zero duration returns "0 seconds" (verbose) or "0s" (compact)
- [ ] parse_duration handles all documented unit aliases case-insensitively

## Notes



## Architecture Documents (AMD)

---
spec: RELATIVE_TIME
status: draft
---

# Architecture: Architecture: Relative Time

## Overview

Two Python modules: a core library with all pure functions and a test file driven by tests.yaml.

## Components

### Relative Time Module

@path: src/whenwords/relative.py

All relative-time functions: timeago, duration, parse_duration. Pure functions with no side effects.

**Interface:**

```python
from datetime import datetime

def timeago(timestamp: int | float | str | datetime,
            reference: int | float | str | datetime) -> str: ...

def duration(seconds: int | float, *, compact: bool = False, max_units: int = 2) -> str: ...

def parse_duration(text: str) -> int | float: ...
```

### Relative Time Tests

@path: tests/test_relative.py

Test file that loads test cases from tests.yaml and runs them against the relative time functions. Covers timeago, duration, and parse_duration sections.

**Interface:**

```python
import pytest

# Test functions are generated from tests.yaml
# Each test case becomes a parameterized test
```

**Depends on:** Relative Time Module

## Flow

```
```
test_relative.py
  ├── loads tests.yaml
  ├── timeago tests   -> relative.timeago()
  ├── duration tests  -> relative.duration()
  └── parse_duration tests -> relative.parse_duration()
```
```

## Dependencies

- stdlib: Python 3.12+ standard library only, no third-party runtime dependencies
- pytest: test runner for parameterized test cases

## Notes

