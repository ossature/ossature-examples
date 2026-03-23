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
### Overview

Pure functions for human-friendly relative time formatting and parsing. Converts durations and timestamp differences into readable strings like "3 hours ago" or "2h 30m", and parses human-written duration strings like "2 hours 30 minutes" back into seconds.

All functions are pure — no side effects, no I/O, no system clock access. The reference timestamp is always passed explicitly.

### Non-Goals

- Locale or i18n support
- Timezone handling (relative functions operate on durations between timestamps)
- Calendar-aware date formatting (see CALENDAR_FORMAT spec)
- Package distribution scaffolding (no setup.py, pyproject.toml build metadata)
</specification_context>

<architecture_context>
### Overview

Two Python modules: a core library with all pure functions and a test file driven by tests.yaml.
</architecture_context>

<task>
## Project Scaffolding

Set up the basic project structure and configuration files.

## Files to Produce

- `src/whenwords/__init__.py`
- `tests/__init__.py`
</task>