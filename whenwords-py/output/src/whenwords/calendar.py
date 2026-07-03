import datetime
from datetime import datetime, timezone

MONTH_NAMES = {
    1: "January",
    2: "February",
    3: "March",
    4: "April",
    5: "May",
    6: "June",
    7: "July",
    8: "August",
    9: "September",
    10: "October",
    11: "November",
    12: "December"
}

WEEKDAY_NAMES = {
    0: "Monday",
    1: "Tuesday",
    2: "Wednesday",
    3: "Thursday",
    4: "Friday",
    5: "Saturday",
    6: "Sunday"
}


def _to_utc_datetime(val) -> datetime:
    """
    Statically normalizes input into a UTC timezone-aware datetime object.
    Supports Unix timestamps (int/float), timezone-aware/naive datetimes, and ISO 8601 strings.
    """
    if isinstance(val, (int, float)):
        # Handle Boolean safely if passed (bool is subclass of int)
        if isinstance(val, bool):
            raise ValueError(f"Boolean values are not valid timestamps: {val}")
        try:
            return datetime.fromtimestamp(val, tz=timezone.utc)
        except (ValueError, OverflowError, OSError) as e:
            raise ValueError(f"Invalid timestamp value (out of range/overflow): {val}") from e
    elif isinstance(val, datetime):
        if val.tzinfo is None:
            return val.replace(tzinfo=timezone.utc)
        else:
            return val.astimezone(timezone.utc)
    elif isinstance(val, str):
        try:
            # datetime.fromisoformat handles standard ISO 8601 strings, including Z suffix in Python 3.11+
            dt = datetime.fromisoformat(val)
            if dt.tzinfo is None:
                return dt.replace(tzinfo=timezone.utc)
            return dt.astimezone(timezone.utc)
        except Exception as e:
            raise ValueError(f"Invalid ISO 8601 timestamp format: '{val}'") from e
    else:
        raise ValueError(f"Unsupported timestamp format: type={type(val).__name__}")


def human_date(timestamp, reference) -> str:
    """
    Return a contextual date string describing when a timestamp falls relative to a reference date.
    Prioritizes human-friendly labels ("Today", "Yesterday", "Last Friday") over raw dates.

    Accepts: timestamp (Unix seconds, datetime, or ISO 8601 string),
             reference (Unix seconds, datetime, or ISO 8601 string)
    Returns: A contextual date string
    Errors: Invalid timestamp format -> raise ValueError with descriptive message
    """
    try:
        ts_dt = _to_utc_datetime(timestamp)
    except Exception as e:
        if isinstance(e, ValueError):
            raise e
        raise ValueError(f"Failed to parse timestamp: {e}") from e

    try:
        ref_dt = _to_utc_datetime(reference)
    except Exception as e:
        if isinstance(e, ValueError):
            raise e
        raise ValueError(f"Failed to parse reference: {e}") from e

    ts_date = ts_dt.date()
    ref_date = ref_dt.date()

    diff_days = (ts_date - ref_date).days

    if diff_days == 0:
        return "Today"
    elif diff_days == 1:
        return "Tomorrow"
    elif diff_days == -1:
        return "Yesterday"
    elif -6 <= diff_days <= -2:
        return f"Last {WEEKDAY_NAMES[ts_date.weekday()]}"
    elif 2 <= diff_days <= 6:
        return f"This {WEEKDAY_NAMES[ts_date.weekday()]}"
    else:
        month_str = MONTH_NAMES[ts_date.month]
        if ts_date.year == ref_date.year:
            return f"{month_str} {ts_date.day}"
        else:
            return f"{month_str} {ts_date.day}, {ts_date.year}"


def date_range(start, end) -> str:
    """
    Format a start and end timestamp as a human-readable date range with smart abbreviation.
    Elides repeated components (month, year) when they are the same for start and end.

    Accepts: start (Unix seconds, datetime, or ISO 8601 string),
             end (Unix seconds, datetime, or ISO 8601 string)
    Returns: A formatted date range string
    Errors: Invalid timestamp format -> raise ValueError with descriptive message
    """
    try:
        start_dt = _to_utc_datetime(start)
    except Exception as e:
        if isinstance(e, ValueError):
            raise e
        raise ValueError(f"Failed to parse start timestamp: {e}") from e

    try:
        end_dt = _to_utc_datetime(end)
    except Exception as e:
        if isinstance(e, ValueError):
            raise e
        raise ValueError(f"Failed to parse end timestamp: {e}") from e

    if start_dt > end_dt:
        start_dt, end_dt = end_dt, start_dt

    start_date = start_dt.date()
    end_date = end_dt.date()

    en_dash = "–"

    if start_date == end_date:
        # Same day
        month_str = MONTH_NAMES[start_date.month]
        return f"{month_str} {start_date.day}, {start_date.year}"

    elif start_date.year == end_date.year and start_date.month == end_date.month:
        # Same month and year -> January 15–22, 2024
        month_str = MONTH_NAMES[start_date.month]
        return f"{month_str} {start_date.day}{en_dash}{end_date.day}, {start_date.year}"

    elif start_date.year == end_date.year:
        # Same year, different months -> January 15 – February 15, 2024
        start_month = MONTH_NAMES[start_date.month]
        end_month = MONTH_NAMES[end_date.month]
        return f"{start_month} {start_date.day} {en_dash} {end_month} {end_date.day}, {start_date.year}"

    else:
        # Different years -> December 28, 2023 – January 15, 2024
        start_month = MONTH_NAMES[start_date.month]
        end_month = MONTH_NAMES[end_date.month]
        return f"{start_month} {start_date.day}, {start_date.year} {en_dash} {end_month} {end_date.day}, {end_date.year}"
