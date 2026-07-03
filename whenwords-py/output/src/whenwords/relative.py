from datetime import datetime
from whenwords.timeago import timeago as _timeago
from whenwords.duration import format_duration as _format_duration, parse_duration as _parse_duration

__all__ = ["timeago", "duration", "parse_duration"]

def timeago(timestamp: int | float | str | datetime,
            reference: int | float | str | datetime) -> str:
    """
    Format the difference between a timestamp and reference timestamp as relative time.
    """
    return _timeago(timestamp, reference)


def duration(seconds: int | float, *, compact: bool = False, max_units: int = 2) -> str:
    """
    Format a positive number of seconds as a human-readable duration style.
    """
    return _format_duration(seconds, {"compact": compact, "max_units": max_units})


def parse_duration(text: str) -> int | float:
    """
    Parse a duration string into seconds.
    """
    return _parse_duration(text)
