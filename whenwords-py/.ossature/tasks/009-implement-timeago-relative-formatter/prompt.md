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
- `src/whenwords/duration.py`
</dependency_files>

<task>
## Implement Timeago Relative Formatter

Implement raw timeago formatting logic in timeago.py. Normalizes both the target timestamp and the reference timestamp, calculates the difference, and formats it as relative time (e.g. '3 hours ago' or 'in 5 minutes') based on unit thresholds. Invalid formats raise a ValueError.

## Files to Produce

- `src/whenwords/timeago.py`
</task>