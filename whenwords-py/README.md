# whenwords-py

whenwords-py is a Python implementation of [whenwords](https://github.com/dbreunig/whenwords), Drew Breunig's "open source library without code" — a language-agnostic spec and test suite for human-friendly time formatting and parsing. The original project ships only a specification (`SPEC.md`) and test cases (`tests.yaml`), with no implementation code. This example takes that spec and converts it into Ossature SMD/AMD specifications, then uses Ossature to generate a fully working Python library.

The library provides five pure functions: `timeago` converts timestamps to relative strings like "3 hours ago" or "in 2 days"; `duration` formats seconds into readable durations like "1 hour, 30 minutes" or "1h 30m"; `parse_duration` parses human-written strings like "2 hours and 30 minutes" back into seconds; `human_date` returns contextual labels like "Today", "Yesterday", or "Last Friday"; and `date_range` formats date ranges with smart abbreviation like "March 5–7, 2024". All functions are pure — no side effects, no system clock access, no I/O.

This project was created and built entirely with [Ossature](https://ossature.dev). See the [main README](../README.md#what-to-look-for) for a guide to exploring the `.ossature/` directory and understanding the artifacts Ossature produces at each stage.

## Project Structure

```
specs/
├── relative_time.smd      # timeago, duration, parse_duration
├── relative_time.amd      # Module layout for relative time functions
├── calendar_format.smd    # human_date, date_range
└── calendar_format.amd    # Module layout for calendar functions

context/
└── tests.yaml             # Language-agnostic test cases from whenwords
```

Building the example (see [Rebuilding](#rebuilding) below) generates an `output/src/whenwords/` tree along these lines:

```
output/src/whenwords/
├── __init__.py
├── relative.py            # timeago, duration, parse_duration
└── calendar.py            # human_date, date_range
```

## Origin

The original whenwords spec is available at [github.com/dbreunig/whenwords](https://github.com/dbreunig/whenwords). The test cases (`tests.yaml`) are copied from that repo into `context/` so Ossature can reference them during code generation. The five functions were split into two Ossature specs — `RELATIVE_TIME` (timeago, duration, parse_duration) and `CALENDAR_FORMAT` (human_date, date_range) — each with a corresponding AMD defining the module layout.

## Model Configuration

- **All tasks:** `mistral:devstral-latest`

## Try It

Build the example first (see [Rebuilding](#rebuilding) below), then:

```bash
cd output
uv sync
uv run python
```

```python
>>> import whenwords
>>> from whenwords.relative import duration
>>> print(duration(3661))
```

## Rebuilding

See the [main README](../README.md#rebuilding-an-example) for rebuild instructions.
