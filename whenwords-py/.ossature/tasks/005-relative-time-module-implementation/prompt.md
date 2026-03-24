<project_config>
Project: whenwords-py v0.0.1
Language: python
</project_config>

<project_brief>
The whenwords-py project provides pure Python functions for human-friendly date and time formatting. It consists of two main modules: **Calendar Format** and **Relative Time**. The **Calendar Format** module converts timestamps into contextual date strings (e.g., "Today", "Last Friday") and abbreviates date ranges (e.g., "March 5–7, 2024"). The **Relative Time** module formats durations into readable strings (e.g., "3 hours ago") and parses human-written durations (e.g., "2h 30m") into seconds. Both modules operate as pure functions, requiring explicit reference timestamps and avoiding side effects or I/O. The project uses Python as its core technology, ensuring UTC-based timestamp handling by default. The modules are independent but share a common design philosophy of immutability and explicit input handling, making them composable for broader time-formatting tasks.
</project_brief>

<spec_brief spec="RELATIVE_TIME">
This module provides pure functions for formatting and parsing human-readable relative time and duration strings. It converts timestamp differences into phrases like "3 hours ago" or "in 5 minutes," formats raw durations in verbose or compact styles, and parses human-written duration strings into seconds. It integrates with timestamp and datetime handling systems but operates independently without I/O or system clock access.
</spec_brief>

<specification_context>
### Constraints

- Python 3.12+ standard library only, no third-party dependencies
- All timestamps are Unix seconds (integer or float); also accept `datetime` objects and ISO 8601 strings
- Strings are UTF-8
- Deterministic: same inputs always produce same output
- Use half-up rounding (2.5 rounds to 3, 2.4 rounds to 2)
- Pluralization: 1 = singular ("1 minute"), 0 or 2+ = plural ("0 seconds", "2 minutes")
</specification_context>

<architecture_context>
### Relative Time Module

@path: src/whenwords/relative.py

All relative-time functions: timeago, duration, parse_duration. Pure functions with no side effects.

**Interface:**

```python
from datetime import datetime
from typing import TypedDict

class DurationOptions(TypedDict, total=False):
    compact: bool
    max_units: int

def timeago(timestamp: int | float | str | datetime,
            reference: int | float | str | datetime | None = None) -> str: ...

def duration(seconds: int | float,
             options: DurationOptions | None = None) -> str: ...

def parse_duration(text: str) -> int | float: ...
```
</architecture_context>

<dependency_files>
The following files from previous tasks are available. Use `grep_file` and `read_lines` to inspect the types, interfaces, and signatures you need.

- `src/whenwords/__init__.py` (13 lines)
- `tests/__init__.py` (5 lines)
</dependency_files>

<task>
## Relative Time Module Implementation

Implement the core relative time functions: timeago, duration, and parse_duration.

## Files to Produce

- `src/whenwords/relative.py`
</task>