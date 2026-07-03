import math
from datetime import datetime, timezone
from decimal import Decimal, ROUND_HALF_UP as DEC_ROUND_HALF_UP

def round_half_up(value: int | float) -> int:
    """
    Rounds a number to the nearest integer, rounding half up (2.5 -> 3, 2.4 -> 2).
    For negative numbers, rounds half away from zero (e.g., -2.5 -> -3).
    """
    if isinstance(value, int):
        return value
    dec = Decimal(str(value))
    return int(dec.quantize(Decimal('1'), rounding=DEC_ROUND_HALF_UP))


def normalize_timestamp(val) -> float:
    """
    Normalizes a timestamp (Unix seconds, ISO 8601 string, or datetime object)
    into a standard UTC float epoch timestamp (seconds since epoch).
    Naive datetimes and ISO strings are treated as UTC.
    """
    if isinstance(val, bool):
        raise ValueError(f"Boolean values are not valid timestamps: {val}")

    if isinstance(val, (int, float)):
        try:
            # Validate that the timestamp is representable in UTC datetime range
            datetime.fromtimestamp(val, tz=timezone.utc)
        except (ValueError, OverflowError, OSError) as e:
            raise ValueError(f"Invalid timestamp value (out of range/overflow): {val}") from e
        return float(val)

    elif isinstance(val, datetime):
        if val.tzinfo is None:
            dt = val.replace(tzinfo=timezone.utc)
        else:
            dt = val.astimezone(timezone.utc)
        return dt.timestamp()

    elif isinstance(val, str):
        try:
            dt = datetime.fromisoformat(val)
            if dt.tzinfo is None:
                dt = dt.replace(tzinfo=timezone.utc)
            else:
                dt = dt.astimezone(timezone.utc)
            return dt.timestamp()
        except Exception as e:
            raise ValueError(f"Invalid ISO 8601 timestamp format: '{val}'") from e

    else:
        raise ValueError(f"Unsupported timestamp format: type={type(val).__name__}")
