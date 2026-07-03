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
### Overview

Pure functions for human-friendly relative time formatting and parsing. Converts durations and timestamp differences into readable strings like "3 hours ago" or "2h 30m", and parses human-written duration strings like "2 hours 30 minutes" back into seconds.

All functions are pure — no side effects, no I/O, no system clock access. The reference timestamp is always passed explicitly.
</specification_context>

<task>
## Scaffold Package Initializer

Scaffold the main package initializer. This creates the primary module declaration for whenwords.

## Files to Produce

- `src/whenwords/__init__.py`
</task>