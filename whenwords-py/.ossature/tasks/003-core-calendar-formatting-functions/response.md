I have implemented the core calendar formatting utilities in `src/whenwords/calendar.py` and updated the imports in `src/whenwords/__init__.py`. 

### Summary of Implementation:
- **`human_date(timestamp, reference)`**: Resolves contextual labels (`Today`, `Yesterday`, `Tomorrow`, `Last Friday`, `This Sunday`, and standard English date display) on UTC calendar-day boundaries without system clock side effects.
- **`date_range(start, end)`**: Intelligently aggregates date spans based on common month/year patterns to emit compact, localized formats, using the correct en-dash (`–`) separator, and correcting out-of-order starts/ends silently.
- **Determinism**: Locale-independent maps (`MONTH_NAMES` and `WEEKDAY_NAMES`) ensure exact, English-output consistency across all potential platform localization settings.
- **Robustness**: Tested comprehensively with naive `datetime` objects, ISO-8601 compliant timezone offset strings, UTC inputs, and out-of-range types.