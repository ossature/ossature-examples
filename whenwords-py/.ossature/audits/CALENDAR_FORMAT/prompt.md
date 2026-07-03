# Specification (SMD)

---
L1: ---
L2: id: CALENDAR_FORMAT
L3: status: draft
L4: priority: high
L5: depends: []
L6: ---
L7: # Calendar Format
L8: 
L9: ## Overview
L10: 
L11: Pure functions for contextual calendar date formatting. Converts timestamps into human-friendly date strings like "Today", "Yesterday", "Last Friday", or "March 5, 2024", and formats date ranges with smart abbreviation like "March 5–7, 2024".
L12: 
L13: All functions are pure — no side effects, no I/O, no system clock access. The reference timestamp is always passed explicitly. All timestamps are interpreted in UTC by default.
L14: 
L15: ## Goals
L16: 
L17: - Format timestamps as contextual date strings relative to a reference date
L18: - Format date ranges with intelligent abbreviation (eliding repeated month/year)
L19: - English output only (v0.1)
L20: 
L21: ## Non-Goals
L22: 
L23: - Timezone conversion (interpret all timestamps in UTC; timezone parameter may be added in future versions)
L24: - Locale or i18n support
L25: - Relative time strings like "3 hours ago" (see RELATIVE_TIME spec)
L26: - Package distribution scaffolding
L27: 
L28: ## Constraints
L29: 
L30: - Python 3.12+ standard library only, no third-party dependencies
L31: - All timestamps are Unix seconds (integer or float); also accept `datetime` objects and ISO 8601 strings
L32: - Strings are UTF-8
L33: - Deterministic: same inputs always produce same output
L34: - All calendar calculations use UTC
L35: - Use en-dash (–) for date range separators, not hyphen (-)
L36: 
L37: ## Requirements
L38: 
L39: ### human_date
L40: 
L41: Return a contextual date string describing when a timestamp falls relative to a reference date. Prioritizes human-friendly labels ("Today", "Yesterday", "Last Friday") over raw dates.
L42: 
L43: **Accepts:** timestamp (Unix seconds, datetime, or ISO 8601 string), reference (Unix seconds, datetime, or ISO 8601 string)
L44: 
L45: **Returns:** A contextual date string
L46: 
L47: **Errors:**
L48: 
L49: - Invalid timestamp format -> raise ValueError with descriptive message
L50: 
L51: Day boundaries are computed in UTC. The rules in priority order:
L52: 
L53: | Condition | Output |
L54: |-----------|--------|
L55: | Same calendar day | "Today" |
L56: | Previous calendar day | "Yesterday" |
L57: | Next calendar day | "Tomorrow" |
L58: | 2–6 days in the past | "Last {weekday}" (e.g. "Last Friday") |
L59: | 2–6 days in the future | "This {weekday}" (e.g. "This Wednesday") |
L60: | Same calendar year | "{Month} {day}" (e.g. "March 1") |
L61: | Different calendar year | "{Month} {day}, {year}" (e.g. "January 1, 2023") |
L62: 
L63: Weekday names are full English names: Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday. Month names are full English names: January through December. Day numbers have no leading zeros.
L64: 
L65: ### date_range
L66: 
L67: Format a start and end timestamp as a human-readable date range with smart abbreviation. Elides repeated components (month, year) when they are the same for start and end.
L68: 
L69: **Accepts:** start (Unix seconds, datetime, or ISO 8601 string), end (Unix seconds, datetime, or ISO 8601 string)
L70: 
L71: **Returns:** A formatted date range string
L72: 
L73: **Errors:**
L74: 
L75: - Invalid timestamp format -> raise ValueError with descriptive message
L76: 
L77: Formatting rules:
L78: 
L79: | Condition | Output |
L80: |-----------|--------|
L81: | Same calendar day | "{Month} {day}, {year}" (e.g. "January 15, 2024") |
L82: | Same month and year | "{Month} {day}–{day}, {year}" (e.g. "January 15–22, 2024") |
L83: | Same year, different months | "{Month} {day} – {Month} {day}, {year}" (e.g. "January 15 – February 15, 2024") |
L84: | Different years | "{Month} {day}, {year} – {Month} {day}, {year}" (e.g. "December 28, 2023 – January 15, 2024") |
L85: 
L86: Edge cases: if start equals end, treat as single day. If start is after end, swap them silently. Use en-dash (–) as the range separator. Same-month ranges use no spaces around the en-dash; cross-month and cross-year ranges use spaces around the en-dash.
L87: 
L88: ## Examples
L89: 
L90: ### human_date today
L91: 
L92: **Input:**
L93: 
L94: ```
L95: human_date(1705276800, reference=1705276800)
L96: ```
L97: 
L98: **Output:**
L99: 
L100: ```
L101: Today
L102: ```
L103: 
L104: ### human_date last weekday
L105: 
L106: **Input:**
L107: 
L108: ```
L109: human_date(1705104000, reference=1705276800)
L110: ```
L111: 
L112: **Output:**
L113: 
L114: ```
L115: Last Saturday
L116: ```
L117: 
L118: ### human_date different year
L119: 
L120: **Input:**
L121: 
L122: ```
L123: human_date(1672531200, reference=1705276800)
L124: ```
L125: 
L126: **Output:**
L127: 
L128: ```
L129: January 1, 2023
L130: ```
L131: 
L132: ### date_range same month
L133: 
L134: **Input:**
L135: 
L136: ```
L137: date_range(1705276800, 1705881600)
L138: ```
L139: 
L140: **Output:**
L141: 
L142: ```
L143: January 15–22, 2024
L144: ```
L145: 
L146: ### date_range different years
L147: 
L148: **Input:**
L149: 
L150: ```
L151: date_range(1703721600, 1705276800)
L152: ```
L153: 
L154: **Output:**
L155: 
L156: ```
L157: December 28, 2023 – January 15, 2024
L158: ```
L159: 
L160: ### date_range swapped
L161: 
L162: **Input:**
L163: 
L164: ```
L165: date_range(1705881600, 1705276800)
L166: ```
L167: 
L168: **Output:**
L169: 
L170: ```
L171: January 15–22, 2024
L172: ```
L173: 
L174: ## Acceptance Criteria
L175: 
L176: - All human_date and date_range test cases from tests.yaml pass
L177: - Functions accept `datetime` objects and ISO 8601 strings in addition to Unix timestamps
L178: - Errors raise `ValueError` with descriptive messages
L179: - En-dash (–) is used for range separators, not hyphen
L180: - Swapped start/end inputs are auto-corrected silently
L181: - Day/month names are full English words with no abbreviations
---

# Architecture Documents (AMD)

---
L1: ---
L2: spec: CALENDAR_FORMAT
L3: status: draft
L4: ---
L5: # Architecture: Calendar Format
L6: 
L7: ## Overview
L8: 
L9: Two Python modules: a core library with calendar formatting functions and a test file driven by tests.yaml.
L10: 
L11: ## Components
L12: 
L13: ### Calendar Format Module
L14: 
L15: @path: src/whenwords/calendar.py
L16: 
L17: Calendar date formatting functions: human_date and date_range. Pure functions with no side effects. All calendar calculations use UTC.
L18: 
L19: **Interface:**
L20: 
L21: ```python
L22: from datetime import datetime
L23: 
L24: def human_date(timestamp: int | float | str | datetime,
L25:                reference: int | float | str | datetime) -> str: ...
L26: 
L27: def date_range(start: int | float | str | datetime,
L28:                end: int | float | str | datetime) -> str: ...
L29: ```
L30: 
L31: **Depends on:** None
L32: 
L33: ### Calendar Format Tests
L34: 
L35: @path: tests/test_calendar.py
L36: 
L37: Test file that loads test cases from tests.yaml and runs them against the calendar format functions. Covers human_date and date_range sections.
L38: 
L39: **Interface:**
L40: 
L41: ```python
L42: import pytest
L43: 
L44: # Test functions are generated from tests.yaml
L45: # Each test case becomes a parameterized test
L46: ```
L47: 
L48: **Depends on:** Calendar Format Module
L49: 
L50: ## Flow
L51: 
L52: ```
L53: test_calendar.py
L54:   ├── loads tests.yaml
L55:   ├── human_date tests   -> calendar.human_date()
L56:   └── date_range tests   -> calendar.date_range()
L57: ```
L58: 
L59: ## Dependencies
L60: 
L61: - stdlib: Python 3.12+ standard library only, no third-party runtime dependencies
L62: - pytest: test runner for parameterized test cases