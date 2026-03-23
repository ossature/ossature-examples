<project_config>
Project: whenwords-py v0.0.1
Language: python
</project_config>

<project_brief>
The whenwords-py project provides pure Python functions for human-friendly date and time formatting. It consists of two main modules: **Calendar Format** and **Relative Time**. The **Calendar Format** module converts timestamps into contextual date strings (e.g., "Today", "Last Friday") and abbreviates date ranges (e.g., "March 5–7, 2024"). The **Relative Time** module formats durations into readable strings (e.g., "3 hours ago") and parses human-written durations (e.g., "2h 30m") into seconds. Both modules operate as pure functions, requiring explicit reference timestamps and avoiding side effects or I/O. The project uses Python as its core technology, ensuring UTC-based timestamp handling by default. The modules are independent but share a common design philosophy of immutability and explicit input handling, making them composable for broader time-formatting tasks.
</project_brief>

<spec_brief spec="CALENDAR_FORMAT">
This module provides pure functions for converting timestamps into human-readable date strings (e.g., "Today", "Last Friday") and formatting date ranges with smart abbreviation (e.g., "March 5–7, 2024"). It handles UTC-based calendar calculations without side effects, accepting Unix timestamps, `datetime` objects, or ISO 8601 strings. It integrates with time-aware applications but defers timezone handling and relative time formatting (e.g., "3 hours ago") to other modules.
</spec_brief>

<specification_context>
## Requirements

### human_date

Return a contextual date string describing when a timestamp falls relative to a reference date. Prioritizes human-friendly labels ("Today", "Yesterday", "Last Friday") over raw dates.

**Accepts:** timestamp (Unix seconds, datetime, or ISO 8601 string), reference (Unix seconds, datetime, or ISO 8601 string)

**Returns:** A contextual date string

**Errors:**

- Invalid timestamp format -> raise ValueError with descriptive message

### date_range

Format a start and end timestamp as a human-readable date range with smart abbreviation. Elides repeated components (month, year) when they are the same for start and end.

**Accepts:** start (Unix seconds, datetime, or ISO 8601 string), end (Unix seconds, datetime, or ISO 8601 string)

**Returns:** A formatted date range string

**Errors:**

- Invalid timestamp format -> raise ValueError with descriptive message

### Constraints

- Python 3.12+ standard library only, no third-party dependencies
- All timestamps are Unix seconds (integer or float); also accept `datetime` objects and ISO 8601 strings
- Strings are UTF-8
- Deterministic: same inputs always produce same output
- All calendar calculations use UTC
- Use en-dash (–) for date range separators, not hyphen (-)

## Examples

### human_date today

**Input:**

```
human_date(1705276800, reference=1705276800)
```

**Output:**

```
Today
```

### human_date last weekday

**Input:**

```
human_date(1705104000, reference=1705276800)
```

**Output:**

```
Last Saturday
```

### human_date different year

**Input:**

```
human_date(1672531200, reference=1705276800)
```

**Output:**

```
January 1, 2023
```

### date_range same month

**Input:**

```
date_range(1705276800, 1705881600)
```

**Output:**

```
January 15–22, 2024
```

### date_range different years

**Input:**

```
date_range(1703721600, 1705276800)
```

**Output:**

```
December 28, 2023 – January 15, 2024
```

### date_range swapped

**Input:**

```
date_range(1705881600, 1705276800)
```

**Output:**

```
January 15–22, 2024
```
</specification_context>

<architecture_context>
### Calendar Format Module

@path: src/whenwords/calendar.py

Calendar date formatting functions: human_date and date_range. Pure functions with no side effects. All calendar calculations use UTC.

**Interface:**

```python
from datetime import datetime

def human_date(timestamp: int | float | str | datetime,
               reference: int | float | str | datetime) -> str: ...

def date_range(start: int | float | str | datetime,
               end: int | float | str | datetime) -> str: ...
```
</architecture_context>

<dependency_files>
The following files from previous tasks are available. Use `grep_file` and `read_lines` to inspect the types, interfaces, and signatures you need.

- `src/whenwords/__init__.py` (9 lines)
- `tests/__init__.py` (6 lines)
- `pyproject.toml` (25 lines)
</dependency_files>

<task>
## Calendar Format Module

Implement the core calendar formatting functions: human_date and date_range.

## Files to Produce

- `src/whenwords/calendar.py`
</task>