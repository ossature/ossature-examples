# Audit Report: whenwords-py v0.0.1

**Date:** 2026-06-06T10:47:12Z
**Specs:** CALENDAR_FORMAT, RELATIVE_TIME

## Cross-Spec Findings

No cross-spec findings identified.

## CALENDAR_FORMAT Findings

### WARNING: Constraints, L31

**Issue:** The specification states that all calendar calculations use UTC and timestamps are interpreted in UTC by default, but it does not clarify how timezone-aware input datetime objects or ISO 8601 strings with offsets (e.g., '+05:00') should be handled. If one implementation converts timezone-aware inputs to UTC while another discards the offset and processes local times directly, they will produce incompatible date boundaries near UTC midnight.

**Suggestion:** Clarify that timezone-aware inputs must be explicitly converted to UTC (e.g., using `dt.astimezone(timezone.utc)`), whereas timezone-naive inputs are assumed to represent UTC times directly.

### WARNING: Acceptance Criteria, L176

**Issue:** The acceptance criteria and architecture specify that tests are parameterized from a `tests.yaml` file, but the exact format, schema, or location of this YAML file is not defined, making it impossible to implement the parser in `test_calendar.py` compatibly.

**Suggestion:** Add a brief schema definition or an example structure of `tests.yaml` (e.g., showing keys for human_date and date_range tests with input/expected fields).

## RELATIVE_TIME Findings

### WARNING: Requirements > duration, L96

**Issue:** It is ambiguous whether the unit cascade rules (specifically '12 months cascades to 1 year') are applied globally to any initial duration breakdown, or only dynamically when a truncation occurs via `max_units`. Since a greedy breakdown of 360 days naturally produces '12 months' (as 1 year = 365 days), a standard formatting without truncation like `duration(31104000, max_units=5)` could output '12 months' instead of cascading to '1 year' if the overflow logic only runs under truncation rounding.

**Suggestion:** Clarify that cascade operations (such as converting 12 months to 1 year, 24 hours to 1 day, etc.) apply universally to the final unit representation of any formatted duration, regardless of whether `max_units` truncation was triggered.

### WARNING: Requirements > duration, L96

**Issue:** There is an ambiguity regarding how the 'remainder' is evaluated when rounding the smallest displayed unit in `duration`. If the remainder is evaluated in raw seconds relative to the smallest displayed unit's total seconds (e.g., comparing 6 months to 1 year = 365 days), 6 months (15,552,000s) is less than half a year (15,768,000s) and will round down. If evaluated based on unit boundaries (e.g., 6 months is exactly 0.5 of a 12-month year), it rounds up. This will cause different outputs depending on the developer's implementation.

**Suggestion:** Specify exactly how the remainder should be evaluated relative to the smallest displayed unit (for example, by stating whether the ratio should be computed using the raw seconds difference or using the unit-ratio fraction like months/12 or days/30).

### INFO: Requirements > parse_duration, L102

**Issue:** The spec details colon notation as `\"2:30\" as h:mm` and `\"2:30:00\" as h:mm:ss`. It is not explicitly stated whether single-digit minutes or seconds (e.g., \"2:5\" or \"2:30:5\") must raise a ValueError as malformed, or if they should be parsed (e.g., interpreting \"2:5\" as \"2:05\").

**Suggestion:** Clarify if the minute and second components in colon-notation durations must be strictly zero-padded to two digits (raising a ValueError otherwise) or if single-digit values are acceptable.

