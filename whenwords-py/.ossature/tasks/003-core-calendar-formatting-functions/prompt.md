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

### Acceptance Criteria

- All human_date and date_range test cases from tests.yaml pass
- Functions accept `datetime` objects and ISO 8601 strings in addition to Unix timestamps
- Errors raise `ValueError` with descriptive messages
- En-dash (–) is used for range separators, not hyphen
- Swapped start/end inputs are auto-corrected silently
- Day/month names are full English words with no abbreviations
</specification_context>

<dependency_files>
The following files from previous tasks are available. Use `grep_file` and `read_lines` to inspect the types, interfaces, and signatures you need.

- `pyproject.toml`
- `src/whenwords/__init__.py`
</dependency_files>

<context_files>
The following files from the project's context directory are assigned to this task. Use `copy_context_file(context_path, dest_path)` to copy assets into the appropriate location within the output directory (choose a destination path that fits the project structure, e.g. `assets/audio/music.mp3` or `sounds/correct.wav`). Use `read_context_file(context_path)` to read text files on demand.

### tests.yaml

**MIME type:** `text/yaml` (12801 bytes)

```
version: "0.1.0"

# All timestamps are Unix seconds.
# Reference timestamp for most timeago tests: 1704067200 (2024-01-01 00:00:00 UTC)

timeago:
  - name: "just now - identical timestamps"
    input: { timestamp: 1704067200, reference: 1704067200 }
    output: "just now"

  - name: "just now - 30 seconds ago"
    input: { timestamp: 1704067170, reference: 1704067200 }
    output: "just now"

  - name: "just now - 44 seconds ago"
    input: { timestamp: 1704067156, reference: 1704067200 }
    output: "just now"

  - name: "1 minute ago - 45 seconds"
    input: { timestamp: 1704067155, reference: 1704067200 }
    output: "1 minute ago"

  - name: "1 minute ago - 89 seconds"
    input: { timestamp: 1704067111, reference: 1704067200 }
    output: "1 minute ago"

  - name: "2 minutes ago - 90 seconds"
    input: { timestamp: 1704067110, reference: 1704067200 }
    output: "2 minutes ago"

  - name: "30 minutes ago"
    input: { timestamp: 1704065400, reference: 1704067200 }
    output: "30 minutes ago"

  - name: "44 minutes ago"
    input: { timestamp: 1704064560, reference: 1704067200 }
    output: "44 minutes ago"

  - name: "1 hour ago - 45 minutes"
    input: { timestamp: 1704064500, reference: 1704067200 }
    output: "1 hour ago"

  - name: "1 hour ago - 89 minutes"
    input: { timestamp: 1704061860, reference: 1704067200 }
    output: "1 hour ago"

  - name: "2 hours ago - 90 minutes"
    input: { timestamp: 1704061800, reference: 1704067200 }
    output: "2 hours ago"

  - name: "5 hours ago"
    input: { timestamp: 1704049200, reference: 1704067200 }
    output: "5 hours ago"

  - name: "21 hours ago"
    input: { timestamp: 1703991600, reference: 1704067200 }
    output: "21 hours ago"

  - name: "1 day ago - 22 hours"
    input: { timestamp: 1703988000, reference: 1704067200 }
    output: "1 day ago"

  - name: "1 day ago - 35 hours"
    input: { timestamp: 1703941200, reference: 1704067200 }
    output: "1 day ago"

  - name: "2 days ago - 36 hours"
    input: { timestamp: 1703937600, reference: 1704067200 }
    output: "2 days ago"

  - name: "7 days ago"
    input: { timestamp: 1703462400, reference: 1704067200 }
    output: "7 days ago"

  - name: "25 days ago"
    input: { timestamp: 1701907200, reference: 1704067200 }
    output: "25 days ago"

  - name: "1 month ago - 26 days"
    input: { timestamp: 1701820800, reference: 1704067200 }
    output: "1 month ago"

  - name: "1 month ago - 45 days"
    input: { timestamp: 1700179200, reference: 1704067200 }
    output: "1 month ago"

  - name: "2 months ago - 46 days"
    input: { timestamp: 1700092800, reference: 1704067200 }
    output: "2 months ago"

  - name: "6 months ago"
    input: { timestamp: 1688169600, reference: 1704067200 }
    output: "6 months ago"

  - name: "11 months ago - 319 days"
    input: { timestamp: 1676505600, reference: 1704067200 }
    output: "11 months ago"

  - name: "1 year ago - 320 days"
    input: { timestamp: 1676419200, reference: 1704067200 }
    output: "1 year ago"

  - name: "1 year ago - 547 days"
    input: { timestamp: 1656806400, reference: 1704067200 }
    output: "1 year ago"

  - name: "2 years ago - 548 days"
    input: { timestamp: 1656720000, reference: 1704067200 }
    output: "2 years ago"

  - name: "5 years ago"
    input: { timestamp: 1546300800, reference: 1704067200 }
    output: "5 years ago"

  - name: "future - in just now (30 seconds)"
    input: { timestamp: 1704067230, reference: 1704067200 }
    output: "just now"

  - name: "future - in 1 minute"
    input: { timestamp: 1704067260, reference: 1704067200 }
    output: "in 1 minute"

  - name: "future - in 5 minutes"
    input: { timestamp: 1704067500, reference: 1704067200 }
    output: "in 5 minutes"

  - name: "future - in 1 hour"
    input: { timestamp: 1704070200, reference: 1704067200 }
    output: "in 1 hour"

  - name: "future - in 3 hours"
    input: { timestamp: 1704078000, reference: 1704067200 }
    output: "in 3 hours"

  - name: "future - in 1 day"
    input: { timestamp: 1704150000, reference: 1704067200 }
    output: "in 1 day"

  - name: "future - in 2 days"
    input: { timestamp: 1704240000, reference: 1704067200 }
    output: "in 2 days"

  - name: "future - in 1 month"
    input: { timestamp: 1706745600, reference: 1704067200 }
    output: "in 1 month"

  - name: "future - in 1 year"
    input: { timestamp: 1735689600, reference: 1704067200 }
    output: "in 1 year"


duration:
  - name: "zero seconds"
    input: { seconds: 0 }
    output: "0 seconds"

  - name: "1 second"
    input: { seconds: 1 }
    output: "1 second"

  - name: "45 seconds"
    input: { seconds: 45 }
    output: "45 seconds"

  - name: "1 minute"
    input: { seconds: 60 }
    output: "1 minute"

  - name: "1 minute 30 seconds"
    input: { seconds: 90 }
    output: "1 minute, 30 seconds"

  - name: "2 minutes"
    input: { seconds: 120 }
    output: "2 minutes"

  - name: "1 hour"
    input: { seconds: 3600 }
    output: "1 hour"

  - name: "1 hour 1 minute"
    input: { seconds: 3661 }
    output: "1 hour, 1 minute"

  - name: "1 hour 30 minutes"
    input: { seconds: 5400 }
    output: "1 hour, 30 minutes"

  - name: "2 hours 30 minutes"
    input: { seconds: 9000 }
    output: "2 hours, 30 minutes"

  - name: "1 day"
    input: { seconds: 86400 }
    output: "1 day"

  - name: "1 day 2 hours"
    input: { seconds: 93600 }
    output: "1 day, 2 hours"

  - name: "7 days"
    input: { seconds: 604800 }
    output: "7 days"

  - name: "1 month (30 days)"
    input: { seconds: 2592000 }
    output: "1 month"

  - name: "1 year (365 days)"
    input: { seconds: 31536000 }
    output: "1 year"

  - name: "1 year 2 months"
    input: { seconds: 36720000 }
    output: "1 year, 2 months"

  - name: "compact - 1h 1m"
    input: { seconds: 3661, options: { compact: true } }
    output: "1h 1m"

  - name: "compact - 2h 30m"
    input: { seconds: 9000, options: { compact: true } }
    output: "2h 30m"

  - name: "compact - 1d 2h"
    input: { seconds: 93600, options: { compact: true } }
    output: "1d 2h"

  - name: "compact - 45s"
    input: { seconds: 45, options: { compact: true } }
    output: "45s"

  - name: "compact - 0s"
    input: { seconds: 0, options: { compact: true } }
    output: "0s"

  - name: "max_units 1 - hours only"
    input: { seconds: 3661, options: { max_units: 1 } }
    output: "1 hour"

  - name: "max_units 1 - days only"
    input: { seconds: 93600, options: { max_units: 1 } }
    output: "1 day"

  - name: "max_units 3"
    input: { seconds: 93661, options: { max_units: 3 } }
    output: "1 day, 2 hours, 1 minute"

  - name: "compact max_units 1"
    input: { seconds: 9000, options: { compact: true, max_units: 1 } }
    output: "3h"

  - name: "error - negative seconds"
    input: { seconds: -100 }
    error: true


parse_duration:
  - name: "compact hours minutes"
    input: "2h30m"
    output: 9000

  - name: "compact with space"
    input: "2h 30m"
    output: 9000

  - name: "compact with comma"
    input: "2h, 30m"
    output: 9000

  - name: "verbose"
    input: "2 hours 30 minutes"
    output: 9000

  - name: "verbose with and"
    input: "2 hours and 30 minutes"
    output: 9000

  - name: "verbose with comma and"
    input: "2 hours, and 30 minutes"
    output: 9000

  - name: "decimal hours"
    input: "2.5 hours"
    output: 9000

  - name: "decimal compact"
    input: "1.5h"
    output: 5400

  - name: "single unit minutes verbose"
    input: "90 minutes"
    output: 5400

  - name: "single unit minutes compact"
    input: "90m"
    output: 5400

  - name: "single unit min"
    input: "90min"
    output: 5400

  - name: "colon notation h:mm"
    input: "2:30"
    output: 9000

  - name: "colon notation h:mm:ss"
    input: "1:30:00"
    output: 5400

  - name: "colon notation with seconds"
    input: "0:05:30"
    output: 330

  - name: "days verbose"
    input: "2 days"
    output: 172800

  - name: "days compact"
    input: "2d"
    output: 172800

  - name: "weeks verbose"
    input: "1 week"
    output: 604800

  - name: "weeks compact"
    input: "1w"
    output: 604800

  - name: "mixed verbose"
    input: "1 day, 2 hours, and 30 minutes"
    output: 95400

  - name: "mixed compact"
    input: "1d 2h 30m"
    output: 95400

  - name: "seconds only verbose"
    input: "45 seconds"
    output: 45

  - name: "seconds compact s"
    input: "45s"
    output: 45

  - name: "seconds compact sec"
    input: "45sec"
    output: 45

  - name: "hours hr"
    input: "2hr"
    output: 7200

  - name: "hours hrs"
    input: "2hrs"
    output: 7200

  - name: "minutes mins"
    input: "30mins"
    output: 1800

  - name: "case insensitive"
    input: "2H 30M"
    output: 9000

  - name: "whitespace tolerance"
    input: "  2 hours   30 minutes  "
    output: 9000

  - name: "error - empty string"
    input: ""
    error: true

  - name: "error - no units"
    input: "hello world"
    error: true

  - name: "error - negative"
    input: "-5 hours"
    error: true

  - name: "error - just number"
    input: "42"
    error: true


human_date:
  # Reference: 2024-01-15 00:00:00 UTC (Monday)
  # timestamp 1705276800

  - name: "today"
    input: { timestamp: 1705276800, reference: 1705276800 }
    output: "Today"

  - name: "today - same day different time"
    input: { timestamp: 1705320000, reference: 1705276800 }
    output: "Today"

  - name: "yesterday"
    input: { timestamp: 1705190400, reference: 1705276800 }
    output: "Yesterday"

  - name: "tomorrow"
    input: { timestamp: 1705363200, reference: 1705276800 }
    output: "Tomorrow"

  - name: "last Sunday (1 day before Monday)"
    input: { timestamp: 1705190400, reference: 1705276800 }
    output: "Yesterday"

  - name: "last Saturday (2 days ago)"
    input: { timestamp: 1705104000, reference: 1705276800 }
    output: "Last Saturday"

  - name: "last Friday (3 days ago)"
    input: { timestamp: 1705017600, reference: 1705276800 }
    output: "Last Friday"

  - name: "last Thursday (4 days ago)"
    input: { timestamp: 1704931200, reference: 1705276800 }
    output: "Last Thursday"

  - name: "last Wednesday (5 days ago)"
    input: { timestamp: 1704844800, reference: 1705276800 }
    output: "Last Wednesday"

  - name: "last Tuesday (6 days ago)"
    input: { timestamp: 1704758400, reference: 1705276800 }
    output: "Last Tuesday"

  - name: "last Monday (7 days ago) - becomes date"
    input: { timestamp: 1704672000, reference: 1705276800 }
    output: "January 8"

  - name: "this Tuesday (1 day future)"
    input: { timestamp: 1705363200, reference: 1705276800 }
    output: "Tomorrow"

  - name: "this Wednesday (2 days future)"
    input: { timestamp: 1705449600, reference: 1705276800 }
    output: "This Wednesday"

  - name: "this Thursday (3 days future)"
    input: { timestamp: 1705536000, reference: 1705276800 }
    output: "This Thursday"

  - name: "this Sunday (6 days future)"
    input: { timestamp: 1705795200, reference: 1705276800 }
    output: "This Sunday"

  - name: "next Monday (7 days future) - becomes date"
    input: { timestamp: 1705881600, reference: 1705276800 }
    output: "January 22"

  - name: "same year different month"
    input: { timestamp: 1709251200, reference: 1705276800 }
    output: "March 1"

  - name: "same year end of year"
    input: { timestamp: 1735603200, reference: 1705276800 }
    output: "December 31"

  - name: "previous year"
    input: { timestamp: 1672531200, reference: 1705276800 }
    output: "January 1, 2023"

  - name: "next year"
    input: { timestamp: 1736121600, reference: 1705276800 }
    output: "January 6, 2025"


date_range:
  # Using 2024 dates

  - name: "same day"
    input: { start: 1705276800, end: 1705276800 }
    output: "January 15, 2024"

  - name: "same day different times"
    input: { start: 1705276800, end: 1705320000 }
    output: "January 15, 2024"

  - name: "consecutive days same month"
    input: { start: 1705276800, end: 1705363200 }
    output: "January 15–16, 2024"

  - name: "same month range"
    input: { start: 1705276800, end: 1705881600 }
    output: "January 15–22, 2024"

  - name: "same year different months"
    input: { start: 1705276800, end: 1707955200 }
    output: "January 15 – February 15, 2024"

  - name: "different years"
    input: { start: 1703721600, end: 1705276800 }
    output: "December 28, 2023 – January 15, 2024"

  - name: "full year span"
    input: { start: 1704067200, end: 1735603200 }
    output: "January 1 – December 31, 2024"

  - name: "swapped inputs - should auto-correct"
    input: { start: 1705881600, end: 1705276800 }
    output: "January 15–22, 2024"

  - name: "multi-year span"
    input: { start: 1672531200, end: 1735689600 }
    output: "January 1, 2023 – January 1, 2025"
```
</context_files>

<task>
## Core: Calendar Formatting Functions

Implement src/whenwords/calendar.py with UTC timezone normalizations, parsing of Unix, ISO 8601, and datetime inputs, and full logic for human_date as well as date_range as specified. Consult context tests.yaml to ensure correct behavior across expected relative day rules.

## Files to Produce

- `src/whenwords/calendar.py`
</task>