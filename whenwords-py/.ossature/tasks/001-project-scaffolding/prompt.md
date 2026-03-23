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
### Overview

Pure functions for contextual calendar date formatting. Converts timestamps into human-friendly date strings like "Today", "Yesterday", "Last Friday", or "March 5, 2024", and formats date ranges with smart abbreviation like "March 5–7, 2024".

All functions are pure — no side effects, no I/O, no system clock access. The reference timestamp is always passed explicitly. All timestamps are interpreted in UTC by default.

### Constraints

- Python 3.12+ standard library only, no third-party dependencies
- All timestamps are Unix seconds (integer or float); also accept `datetime` objects and ISO 8601 strings
- Strings are UTF-8
- Deterministic: same inputs always produce same output
- All calendar calculations use UTC
- Use en-dash (–) for date range separators, not hyphen (-)
</specification_context>

<architecture_context>
### Overview

Two Python modules: a core library with calendar formatting functions and a test file driven by tests.yaml.

### Dependencies

- stdlib: Python 3.12+ standard library only, no third-party runtime dependencies
- pytest: test runner for parameterized test cases
</architecture_context>

<task>
## Project Scaffolding

Set up the basic project structure, including directories and initial configuration files.

## Files to Produce

- `src/whenwords/__init__.py`
- `tests/__init__.py`
- `pyproject.toml`
</task>