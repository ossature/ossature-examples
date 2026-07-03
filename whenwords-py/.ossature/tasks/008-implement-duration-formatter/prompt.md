<project_config>
Project: whenwords-py v0.0.1
Language: python
</project_config>

<project_brief>
The Python library `whenwords-py` provides pure, side-effect-free utility functions for transforming timestamps and durations into human-friendly strings and parsing casual temporal inputs. The architecture consists of two core modules that share a common design pattern: they eliminate system clock access and side effects by defaulting to UTC and requiring explicit reference timestamps. The `CALENDAR_FORMAT` module converts timestamps into contextual labels such as "Today" or "Last Friday" and generates smartly abbreviated date ranges. Operating in tandem, the `RELATIVE_TIME` module formats time differences into human-readable strings like "3 hours ago" or "2h 30m" and parses informal duration expressions back into seconds. Together, these modules form a deterministic, stateless utility engine for localized and semantic time manipulation.
</project_brief>

<spec_brief spec="RELATIVE_TIME">
This module provides pure, side-effect-free utility functions to bi-directionally convert between numeric durations or timestamp differences and human-readable string formats. It is responsible for parsing colloquial duration inputs (e.g., "2 hours 30 minutes") into seconds and formatting time deltas without performing I/O or accessing the system clock, requiring all reference anchors to be passed explicitly. Operating with zero external dependencies, it integrates directly with user interface rendering components and input validation pipelines that require standardized, relative time representations.
</spec_brief>

<specification_context>
### Constraints

- Python 3.12+ standard library only, no third-party dependencies
- All timestamps are Unix seconds (integer or float); also accept `datetime` objects and ISO 8601 strings. Timezone-naive datetimes or naive ISO 8601 strings are to be treated as UTC when converting to Unix epoch timestamps. Timezone-naive `datetime` objects must be forced to UTC (using `replace(tzinfo=timezone.utc)` or equivalent) before converting them to Unix timestamps or performing calculations.
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

def timeago(timestamp: int | float | str | datetime,
            reference: int | float | str | datetime) -> str: ...

def duration(seconds: int | float, *, compact: bool = False, max_units: int = 2) -> str: ...

def parse_duration(text: str) -> int | float: ...
```
</architecture_context>

<dependency_files>
The following files from previous tasks are available. Use `grep_file` and `read_lines` to inspect the types, interfaces, and signatures you need.

- `src/whenwords/utils.py`
</dependency_files>

<task>
## Implement Duration Formatter

Implement the core duration formatting logic in duration.py. Handles positive numbers of seconds, conversion, plurals, verbose and compact styles, max_units truncation, negative/NaN/Inf validations, and unit cascade rules (e.g. 12 months -> 1 year). For the rounding of the smallest displayed unit and cascade rules, follow standard half-up comparison.

## Files to Produce

- `src/whenwords/duration.py`
</task>