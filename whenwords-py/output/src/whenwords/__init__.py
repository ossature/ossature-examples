"""
whenwords-py

Pure, side-effect-free utility functions for transforming timestamps and durations
into human-friendly strings and parsing casual temporal inputs.
"""

__version__ = "0.0.1"

from whenwords.calendar import human_date, date_range
from whenwords.duration import format_duration, parse_duration
from whenwords.timeago import timeago
from whenwords.relative import duration

__all__ = [
    "human_date",
    "date_range",
    "format_duration",
    "parse_duration",
    "timeago",
    "duration",
]
