# Specification (SMD)

---
L1: ---
L2: id: RELATIVE_TIME
L3: status: draft
L4: priority: high
L5: depends: []
L6: ---
L7: # Relative Time
L8: 
L9: ## Overview
L10: 
L11: Pure functions for human-friendly relative time formatting and parsing. Converts durations and timestamp differences into readable strings like "3 hours ago" or "2h 30m", and parses human-written duration strings like "2 hours 30 minutes" back into seconds.
L12: 
L13: All functions are pure — no side effects, no I/O, no system clock access. The reference timestamp is always passed explicitly.
L14: 
L15: ## Goals
L16: 
L17: - Format timestamp differences as relative time strings ("3 hours ago", "in 5 minutes")
L18: - Format raw durations in verbose ("1 hour, 30 minutes") or compact ("1h 30m") style
L19: - Parse a wide variety of human-written duration strings into seconds
L20: - English output only (v0.1)
L21: 
L22: ## Non-Goals
L23: 
L24: - Locale or i18n support
L25: - Timezone handling (relative functions operate on durations between timestamps)
L26: - Calendar-aware date formatting (see CALENDAR_FORMAT spec)
L27: - Package distribution scaffolding (no setup.py, pyproject.toml build metadata)
L28: 
L29: ## Constraints
L30: 
L31: - Python 3.12+ standard library only, no third-party dependencies
L32: - All timestamps are Unix seconds (integer or float); also accept `datetime` objects and ISO 8601 strings. Timezone-naive datetimes or naive ISO 8601 strings are to be treated as UTC when converting to Unix epoch timestamps. Timezone-naive `datetime` objects must be forced to UTC (using `replace(tzinfo=timezone.utc)` or equivalent) before converting them to Unix timestamps or performing calculations.
L33: - Strings are UTF-8
L34: - Deterministic: same inputs always produce same output
L35: - Use half-up rounding (2.5 rounds to 3, 2.4 rounds to 2)
L36: - Pluralization: 1 = singular ("1 minute"), 0 or 2+ = plural ("0 seconds", "2 minutes")
L37: 
L38: ## Requirements
L39: 
L40: ### timeago
L41: 
L42: Convert a timestamp difference into a human-readable relative time string. The reference timestamp represents "now" and must be passed explicitly.
L43: 
L44: **Accepts:** timestamp (Unix seconds, datetime, or ISO 8601 string), reference (Unix seconds, datetime, or ISO 8601 string)
L45: 
L46: **Returns:** A relative time string
L47: 
L48: **Errors:**
L49: 
L50: - Invalid timestamp format -> raise ValueError with descriptive message
L51: - Timestamp or reference is NaN or infinite -> raise ValueError with descriptive message
L52: 
L53: Threshold matching is performed using the raw, unrounded absolute difference in seconds to determine the threshold row. The raw difference is compared against the lower bound of each threshold (converting units to seconds: 1 minute = 60s, 1 hour = 3600s, 1 day = 86400s, 1 month = 30 days = 2,592,000s, 1 year = 365 days = 31,536,000s).
L54: 
L55: Once a threshold row is matched, the formatted output value `{n}` is computed by dividing the raw difference by the destination unit's duration (e.g., 60s for minutes, 3600s for hours, 86400s for days, 30 days for months, 365 days for years) and rounding using the half-up rule. This can produce output values that match or exceed the lower bound of the next category (for example, a raw difference of 44.5 minutes, or 2670 seconds, is less than 45 minutes (2700s), so it matches the "90 seconds to 44 minutes" threshold and rounds to output "45 minutes ago").
L56: 
L57: Thresholds (evaluated with >= on lower bound of raw seconds):
L58: 
L59: | Difference | Output |
L60: |-----------|--------|
L61: | 0 to 44 seconds | "just now" |
L62: | 45 to 89 seconds | "1 minute ago" |
L63: | 90 seconds to 44 minutes | "{n} minutes ago" (rounded) |
L64: | 45 to 89 minutes | "1 hour ago" |
L65: | 90 minutes to 21 hours | "{n} hours ago" |
L66: | 22 to 35 hours | "1 day ago" |
L67: | 36 hours to 25 days | "{n} days ago" |
L68: | 26 to 45 days | "1 month ago" |
L69: | 46 to 319 days | "{n} months ago" |
L70: | 320 to 547 days | "1 year ago" |
L71: | 548+ days | "{n} years ago" |
L72: 
L73: When `timestamp > reference` (future), format the output as "in {n} {units}". When `timestamp < reference` (past), format as "{n} {units} ago". The "just now" threshold also applies to near-future times (0 to 44 seconds in the future returns "just now").
L74: 
L75: Edge cases: identical timestamps return "just now"; very large values cap at years with no overflow.
L76: 
L77: ### duration
L78: 
L79: Format a number of seconds as a human-readable duration string. Not relative to any reference time.
L80: 
L81: **Accepts:** seconds (non-negative number), and optional keyword arguments: `compact` (bool, default False), `max_units` (int, default 2)
L82: 
L83: **Returns:** A formatted duration string
L84: 
L85: **Errors:**
L86: 
L87: - Negative seconds -> raise ValueError with descriptive message
L88: - NaN or infinite -> raise ValueError with descriptive message
L89: 
L90: Units in descending order: years (365 days), months (30 days), days, hours, minutes, seconds. Only non-zero units are shown. The smallest displayed unit is rounded.
L91: 
L92: The `max_units` parameter limits the count of actually formatted non-zero units. Only non-zero units are considered, and of those, only the largest `max_units` are displayed. Intermediate zero-value units are ignored and do not count toward the `max_units` limit (for example, with 31,536,001 seconds, `max_units=2` yields "1 year, 1 second" rather than truncating to "1 year").
L93: 
L94: Default (verbose) style joins units with ", " — e.g. "1 hour, 1 minute". Compact style uses short suffixes with space separator — e.g. "1h 1m" — using years ('y'), months ('mo'), days ('d'), hours ('h'), minutes ('m'), and seconds ('s'). Zero seconds returns "0 seconds" (or "0s" in compact mode).
L95: 
L96: When `max_units` truncates output, the smallest displayed unit is rounded based on the remainder. If rounding causes the smallest displayed unit to overflow, the value must cascade upward to higher-order units (e.g., 60 minutes cascades to 1 hour, 24 hours to 1 day, 30 days to 1 month, 12 months cascades to 1 year, and 365 days to 1 year) to prevent displaying invalid boundary values like "60 minutes", "24 hours", or "12 months". Additionally, exactly 12 months (or equivalent '12mo' in compact style) must always cascade to 1 year ('1y'), despite the 5-day mathematical difference (360 days versus 365 days).
L97: 
L98: ### parse_duration
L99: 
L100: Parse a human-written duration string into total seconds.
L101: 
L102: **Accepts:** A string in any of these formats: compact ("2h30m", "2h 30m", "2h, 30m"), verbose ("2 hours 30 minutes", "2 hours and 30 minutes"), decimal ("2.5 hours", "1.5h"), single unit ("90 minutes", "90m", "90min"), colon notation ("2:30" as h:mm, "2:30:00" as h:mm:ss)
L103: 
L104: **Returns:** Total seconds as a number
L105: 
L106: **Errors:**
L107: 
L108: - Empty string -> raise ValueError
L109: - No parseable units found -> raise ValueError
L110: - Negative values -> raise ValueError
L111: - Bare number with no unit -> raise ValueError
L112: - Colon-notation minutes or seconds outside the standard [0, 59] range -> raise ValueError
L113: - Unrecognized non-whitespace or non-separator tokens -> raise ValueError
L114: 
L115: Unit aliases (case-insensitive): seconds (s, sec, secs, second, seconds), minutes (m, min, mins, minute, minutes), hours (h, hr, hrs, hour, hours), days (d, day, days), weeks (w, wk, wks, week, weeks - 1 week = 7 days = 604,800 seconds), months (mo, mon, month, months - 1 month = 30 days), years (y, yr, yrs, year, years - 1 year = 365 days).
L116: 
L117: Be liberal in accepting input: tolerate extra whitespace, mixed separators (commas, "and"), and case variations. However, any unrecognized non-whitespace or non-separator tokens (e.g., "3xyz" or "invalid_token") present in the input must result in a ValueError. For colon-notation durations (e.g., "h:mm" or "h:mm:ss"), the minutes and seconds components must be validated to fall within the standard [0, 59] range; values outside this range (e.g., "2:65") must trigger a ValueError.
L118: 
L119: ## Examples
L120: 
L121: ### timeago basic
L122: 
L123: **Input:**
L124: 
L125: ```
L126: timeago(1704067110, reference=1704067200)
L127: ```
L128: 
L129: **Output:**
L130: 
L131: ```
L132: 2 minutes ago
L133: ```
L134: 
L135: ### timeago future
L136: 
L137: **Input:**
L138: 
L139: ```
L140: timeago(1704078000, reference=1704067200)
L141: ```
L142: 
L143: **Output:**
L144: 
L145: ```
L146: in 3 hours
L147: ```
L148: 
L149: ### duration verbose
L150: 
L151: **Input:**
L152: 
L153: ```
L154: duration(3661)
L155: ```
L156: 
L157: **Output:**
L158: 
L159: ```
L160: 1 hour, 1 minute
L161: ```
L162: 
L163: ### duration compact
L164: 
L165: **Input:**
L166: 
L167: ```
L168: duration(3661, compact=True)
L169: ```
L170: 
L171: **Output:**
L172: 
L173: ```
L174: 1h 1m
L175: ```
L176: 
L177: ### parse_duration mixed
L178: 
L179: **Input:**
L180: 
L181: ```
L182: parse_duration("1 day, 2 hours, and 30 minutes")
L183: ```
L184: 
L185: **Output:**
L186: 
L187: ```
L188: 95400
L189: ```
L190: 
L191: ### parse_duration colon
L192: 
L193: **Input:**
L194: 
L195: ```
L196: parse_duration("2:30")
L197: ```
L198: 
L199: **Output:**
L200: 
L201: ```
L202: 9000
L203: ```
L204: 
L205: ## Acceptance Criteria
L206: 
L207: - All timeago, duration, and parse_duration test cases from tests.yaml pass
L208: - Functions accept `datetime` objects and ISO 8601 strings in addition to Unix timestamps
L209: - Errors raise `ValueError` with descriptive messages
L210: - Pluralization is correct for all unit counts
L211: - Future timestamps produce "in X" format
L212: - Zero duration returns "0 seconds" (verbose) or "0s" (compact)
L213: - parse_duration handles all documented unit aliases case-insensitively
---

# Architecture Documents (AMD)

---
L1: ---
L2: spec: RELATIVE_TIME
L3: status: draft
L4: ---
L5: # Architecture: Relative Time
L6: 
L7: ## Overview
L8: 
L9: Two Python modules: a core library with all pure functions and a test file driven by tests.yaml.
L10: 
L11: ## Components
L12: 
L13: ### Relative Time Module
L14: 
L15: @path: src/whenwords/relative.py
L16: 
L17: All relative-time functions: timeago, duration, parse_duration. Pure functions with no side effects.
L18: 
L19: **Interface:**
L20: 
L21: ```python
L22: from datetime import datetime
L23: 
L24: def timeago(timestamp: int | float | str | datetime,
L25:             reference: int | float | str | datetime) -> str: ...
L26: 
L27: def duration(seconds: int | float, *, compact: bool = False, max_units: int = 2) -> str: ...
L28: 
L29: def parse_duration(text: str) -> int | float: ...
L30: ```
L31: 
L32: **Depends on:** None
L33: 
L34: ### Relative Time Tests
L35: 
L36: @path: tests/test_relative.py
L37: 
L38: Test file that loads test cases from tests.yaml and runs them against the relative time functions. Covers timeago, duration, and parse_duration sections.
L39: 
L40: **Interface:**
L41: 
L42: ```python
L43: import pytest
L44: 
L45: # Test functions are generated from tests.yaml
L46: # Each test case becomes a parameterized test
L47: ```
L48: 
L49: **Depends on:** Relative Time Module
L50: 
L51: ## Flow
L52: 
L53: ```
L54: test_relative.py
L55:   ├── loads tests.yaml
L56:   ├── timeago tests   -> relative.timeago()
L57:   ├── duration tests  -> relative.duration()
L58:   └── parse_duration tests -> relative.parse_duration()
L59: ```
L60: 
L61: ## Dependencies
L62: 
L63: - stdlib: Python 3.12+ standard library only, no third-party runtime dependencies
L64: - pytest: test runner for parameterized test cases