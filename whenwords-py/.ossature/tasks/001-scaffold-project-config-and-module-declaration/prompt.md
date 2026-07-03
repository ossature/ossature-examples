<project_config>
Project: whenwords-py v0.0.1
Language: python
</project_config>

<project_brief>
The Python library `whenwords-py` provides pure, side-effect-free utility functions for transforming timestamps and durations into human-friendly strings and parsing casual temporal inputs. The architecture consists of two core modules that share a common design pattern: they eliminate system clock access and side effects by defaulting to UTC and requiring explicit reference timestamps. The `CALENDAR_FORMAT` module converts timestamps into contextual labels such as "Today" or "Last Friday" and generates smartly abbreviated date ranges. Operating in tandem, the `RELATIVE_TIME` module formats time differences into human-readable strings like "3 hours ago" or "2h 30m" and parses informal duration expressions back into seconds. Together, these modules form a deterministic, stateless utility engine for localized and semantic time manipulation.
</project_brief>

<spec_brief spec="CALENDAR_FORMAT">
This module provides pure, stateless functions that format timestamps into contextual, human-readable strings (such as "Today" or "Yesterday") and generate smart, abbreviated date ranges. It operates with zero system side effects, interpreting all inputs in UTC and requiring reference timestamps to be passed explicitly rather than accessing the system clock. As a zero-dependency utility, it integrates with any presentation, UI, or notification component that requires localized temporal formatting.
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
### Dependencies

- stdlib: Python 3.12+ standard library only, no third-party runtime dependencies
- pytest: test runner for parameterized test cases
</architecture_context>

<task>
## Scaffold: Project Config and Module Declaration

Create pyproject.toml with python version constraints (>=3.12) and dev dependencies (pytest, PyYAML), and initialize the package namespace directory with src/whenwords/__init__.py.

## Files to Produce

- `pyproject.toml`
- `src/whenwords/__init__.py`
</task>