from datetime import datetime, timedelta, timezone
from typing import Union


def _parse_timestamp(timestamp: Union[int, float, str, datetime]) -> datetime:
    """Parse a timestamp into a UTC datetime object."""
    if isinstance(timestamp, datetime):
        return timestamp
    elif isinstance(timestamp, (int, float)):
        return datetime.fromtimestamp(timestamp, tz=timezone.utc)
    elif isinstance(timestamp, str):
        try:
            return datetime.fromisoformat(timestamp).astimezone(timezone.utc)
        except ValueError:
            raise ValueError(f"Invalid timestamp format: {timestamp}")
    else:
        raise ValueError(f"Invalid timestamp format: {timestamp}")


def _format_date(dt: datetime, include_year: bool = False) -> str:
    """Format a date string without leading zeros."""
    month = dt.strftime("%B")
    day = dt.strftime("%d").lstrip('0')
    if include_year:
        return f"{month} {day}, {dt.year}"
    else:
        return f"{month} {day}"


def human_date(timestamp: Union[int, float, str, datetime],
              reference: Union[int, float, str, datetime]) -> str:
    """Return a contextual date string describing when a timestamp falls relative to a reference date."""
    try:
        dt = _parse_timestamp(timestamp)
        ref_dt = _parse_timestamp(reference)
    except ValueError as e:
        raise ValueError(f"Invalid timestamp format: {e}")

    # Normalize to UTC and strip timezone info for comparison
    dt = dt.astimezone(timezone.utc).replace(tzinfo=None)
    ref_dt = ref_dt.astimezone(timezone.utc).replace(tzinfo=None)

    # Calculate the difference in days
    delta = (dt.date() - ref_dt.date()).days

    if delta == 0:
        return "Today"
    elif delta == -1:
        return "Yesterday"
    elif delta == 1:
        return "Tomorrow"
    elif delta == -2:
        return f"Last {dt.strftime('%A')}"
    elif delta == -3:
        return f"Last {dt.strftime('%A')}"
    elif delta == -4:
        return f"Last {dt.strftime('%A')}"
    elif delta == -5:
        return f"Last {dt.strftime('%A')}"
    elif delta == -6:
        return f"Last {dt.strftime('%A')}"
    elif delta == 2:
        return f"This {dt.strftime('%A')}"
    elif delta == 3:
        return f"This {dt.strftime('%A')}"
    elif delta == 4:
        return f"This {dt.strftime('%A')}"
    elif delta == 5:
        return f"This {dt.strftime('%A')}"
    elif delta == 6:
        return f"This {dt.strftime('%A')}"
    elif delta == 7:
        return _format_date(dt)
    else:
        # Default to formatted date
        if dt.year == ref_dt.year:
            return _format_date(dt)
        else:
            return _format_date(dt, include_year=True)


def date_range(start: Union[int, float, str, datetime],
               end: Union[int, float, str, datetime]) -> str:
    """Format a start and end timestamp as a human-readable date range with smart abbreviation."""
    try:
        start_dt = _parse_timestamp(start)
        end_dt = _parse_timestamp(end)
    except ValueError as e:
        raise ValueError(f"Invalid timestamp format: {e}")

    # Normalize to UTC and strip timezone info for comparison
    start_dt = start_dt.astimezone(timezone.utc).replace(tzinfo=None)
    end_dt = end_dt.astimezone(timezone.utc).replace(tzinfo=None)

    # Ensure start is before end
    if start_dt > end_dt:
        start_dt, end_dt = end_dt, start_dt

    # Format start and end dates
    start_year = start_dt.year
    end_year = end_dt.year
    start_month = start_dt.month
    end_month = end_dt.month

    if start_dt.date() == end_dt.date():
        # Same day
        return _format_date(start_dt, include_year=True)
    elif start_year == end_year:
        if start_month == end_month:
            # Same month and year
            start_str = _format_date(start_dt)
            end_str = end_dt.strftime("%d, %Y").lstrip('0')
            return f"{start_str}–{end_str}"
        else:
            # Same year, different months
            start_str = _format_date(start_dt)
            end_str = _format_date(end_dt, include_year=True)
            return f"{start_str} – {end_str}"
    else:
        # Different years
        start_str = _format_date(start_dt, include_year=True)
        end_str = _format_date(end_dt, include_year=True)
        return f"{start_str} – {end_str}"