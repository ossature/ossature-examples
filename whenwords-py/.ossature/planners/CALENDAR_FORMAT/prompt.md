# Project: whenwords-py v0.0.1 (python)

## Specification (SMD)

---
id: CALENDAR_FORMAT
status: draft
priority: high
depends: []
---

# Calendar Format

## Overview

Pure functions for contextual calendar date formatting. Converts timestamps into human-friendly date strings like "Today", "Yesterday", "Last Friday", or "March 5, 2024", and formats date ranges with smart abbreviation like "March 5–7, 2024".

All functions are pure — no side effects, no I/O, no system clock access. The reference timestamp is always passed explicitly. All timestamps are interpreted in UTC by default.

## Goals

- Format timestamps as contextual date strings relative to a reference date
- Format date ranges with intelligent abbreviation (eliding repeated month/year)
- English output only (v0.1)

## Non-Goals

- Timezone conversion (interpret all timestamps in UTC; timezone parameter may be added in future versions)
- Locale or i18n support
- Relative time strings like "3 hours ago" (see RELATIVE_TIME spec)
- Package distribution scaffolding

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

## Constraints

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

## Acceptance Criteria

- [ ] All human_date and date_range test cases from tests.yaml pass
- [ ] Functions accept `datetime` objects and ISO 8601 strings in addition to Unix timestamps
- [ ] Errors raise `ValueError` with descriptive messages
- [ ] En-dash (–) is used for range separators, not hyphen
- [ ] Swapped start/end inputs are auto-corrected silently
- [ ] Day/month names are full English words with no abbreviations

## Notes



## Architecture Documents (AMD)

---
spec: CALENDAR_FORMAT
status: draft
---

# Architecture: Architecture: Calendar Format

## Overview

Two Python modules: a core library with calendar formatting functions and a test file driven by tests.yaml.

## Components

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

### Calendar Format Tests

@path: tests/test_calendar.py

Test file that loads test cases from tests.yaml and runs them against the calendar format functions. Covers human_date and date_range sections.

**Interface:**

```python
import pytest

# Test functions are generated from tests.yaml
# Each test case becomes a parameterized test
```

**Depends on:** Calendar Format Module

## Flow

```
```
test_calendar.py
  ├── loads tests.yaml
  ├── human_date tests   -> calendar.human_date()
  └── date_range tests   -> calendar.date_range()
```
```

## Dependencies

- stdlib: Python 3.12+ standard library only, no third-party runtime dependencies
- pytest: test runner for parameterized test cases

## Notes



## Audit Findings
Account for the following findings when planning. Avoid generating tasks that would hit these known spec issues:

- [WARNING] Constraints, L31: The specification states that all calendar calculations use UTC and timestamps are interpreted in UTC by default, but it does not clarify how timezone-aware input datetime objects or ISO 8601 strings with offsets (e.g., '+05:00') should be handled. If one implementation converts timezone-aware inputs to UTC while another discards the offset and processes local times directly, they will produce incompatible date boundaries near UTC midnight.
- [WARNING] Acceptance Criteria, L176: The acceptance criteria and architecture specify that tests are parameterized from a `tests.yaml` file, but the exact format, schema, or location of this YAML file is not defined, making it impossible to implement the parser in `test_calendar.py` compatibly.

## Context Files

The following files are available in the project's context directory. These are pre-existing assets (audio, images, reference code, documentation, and so on) that may be useful during implementation.

- `tests.yaml` (text/yaml)

Two ways to use them in a task. For files the LLM should READ as reference (example code, docs, spec snippets), list them in the task's `context_files` field. Text files get included in the task's prompt; binary assets are exposed via tools so the implementer can copy them into the output directory (often under `assets/` or `sounds/`).

For files that should be copied verbatim with no transformation (binary assets, fixtures, reference data), emit a copy task instead. Set `source = ["context://<path-or-glob>"]` and leave `verify` empty. The build system copies matched files directly without calling the LLM. Source and output patterns pair 1:1 by index, and any `*` or `**` wildcard in source must align with one in outputs so each matched basename is preserved. Typical candidates are opaque/binary assets like `.mp3`, `.wav`, `.png`, `.ttf`, `.pdf`, fonts, and fixtures where the output is byte-identical to the context file.