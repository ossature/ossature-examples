from datetime import datetime
from whenwords.utils import normalize_timestamp, round_half_up

def timeago(timestamp: int | float | str | datetime,
            reference: int | float | str | datetime) -> str:
    """
    Normalizes both the target timestamp and the reference timestamp,
    calculates the difference, and formats it as relative time (e.g. '3 hours ago' or 'in 5 minutes')
    based on unit thresholds. Invalid formats raise a ValueError.
    """
    ts = normalize_timestamp(timestamp)
    ref = normalize_timestamp(reference)

    is_future = ts > ref
    diff_sec = abs(ts - ref)

    if diff_sec < 45:
        return "just now"

    # Define units with their divisors and labels
    if diff_sec < 45 * 60:  # < 45 minutes
        val = round_half_up(diff_sec / 60)
        unit = "minute" if val == 1 else "minutes"
    elif diff_sec < 22 * 3600:  # < 22 hours
        val = round_half_up(diff_sec / 3600)
        unit = "hour" if val == 1 else "hours"
    elif diff_sec < 26 * 86400:  # < 26 days
        val = round_half_up(diff_sec / 86400)
        unit = "day" if val == 1 else "days"
    elif diff_sec < 320 * 86400:  # < 320 days
        val = round_half_up(diff_sec / (30.3 * 86400))
        unit = "month" if val == 1 else "months"
    else:
        val = round_half_up(diff_sec / (365 * 86400))
        unit = "year" if val == 1 else "years"

    if is_future:
        return f"in {val} {unit}"
    else:
        return f"{val} {unit} ago"
