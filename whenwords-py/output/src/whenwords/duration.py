import math
import re
from whenwords.utils import round_half_up
from whenwords.parser import parse_duration

def format_duration(seconds, options=None) -> str:
    """
    Format a positive number of seconds as a human-readable duration style, supporting:
    - positive integers/floats
    - verbose ("1 minute, 30 seconds") and compact ("1m 30s") styles
    - max_units truncation with half-up rounding
    - unit cascade rules (e.g. 12 months -> 1 year)
    - validation against negative, NaN, Inf, and invalid type inputs
    """
    if options is None:
        options = {}
    
    compact = options.get("compact", False)
    max_units = options.get("max_units", 2)

    if isinstance(seconds, bool):
        raise ValueError("Boolean values are not valid durations")
    
    try:
        val = float(seconds)
    except (TypeError, ValueError) as e:
        raise ValueError(f"Invalid duration value: {seconds}") from e

    if math.isnan(val) or math.isinf(val):
        raise ValueError(f"Duration cannot be NaN or Infinite: {val}")
    
    if val < 0:
        raise ValueError(f"Duration cannot be negative: {val}")

    if val == 0:
        return "0s" if compact else "0 seconds"

    UNIT_SCALES = {
        'year': 31536000,
        'month': 2592000,
        'day': 86400,
        'hour': 3600,
        'minute': 60,
        'second': 1
    }
    UNIT_ORDER = ['year', 'month', 'day', 'hour', 'minute', 'second']
    UNIT_NAMES = {
        'year': ('year', 'years', 'y'),
        'month': ('month', 'months', 'mo'),
        'day': ('day', 'days', 'd'),
        'hour': ('hour', 'hours', 'h'),
        'minute': ('minute', 'minutes', 'm'),
        'second': ('second', 'seconds', 's'),
    }

    # Greedy decomposition
    rem = val
    unit_values = {}
    for u in UNIT_ORDER:
        scale = UNIT_SCALES[u]
        if u == 'second':
            unit_values[u] = rem
        else:
            unit_values[u] = int(rem // scale)
            rem %= scale

    active_units = [u for u in UNIT_ORDER if unit_values[u] > 0]
    if not active_units:
        return "0s" if compact else "0 seconds"

    # Enforce max_units truncation
    displayed_units = active_units[:max_units]
    smallest_displayed_unit = displayed_units[-1]

    # Sum up discarded units as seconds
    smallest_idx = UNIT_ORDER.index(smallest_displayed_unit)
    discarded_sec = 0.0
    for idx in range(smallest_idx + 1, len(UNIT_ORDER)):
        u = UNIT_ORDER[idx]
        discarded_sec += unit_values[u] * UNIT_SCALES[u]
        unit_values[u] = 0

    # Add as fraction to smallest displayed unit
    unit_values[smallest_displayed_unit] += discarded_sec / UNIT_SCALES[smallest_displayed_unit]

    # Round the smallest displayed unit half-up
    unit_values[smallest_displayed_unit] = round_half_up(unit_values[smallest_displayed_unit])

    # Cascade up
    factors = [
        ('second', 'minute', 60),
        ('minute', 'hour', 60),
        ('hour', 'day', 24),
        ('day', 'month', 30),
        ('month', 'year', 12)
    ]
    for low, high, factor in factors:
        if unit_values[low] >= factor:
            carry = unit_values[low] // factor
            unit_values[low] %= factor
            unit_values[high] += carry

    # Re-calculate active units after cascading
    final_active_units = [u for u in UNIT_ORDER if unit_values[u] > 0]

    # Format output parts
    parts = []
    for u in final_active_units:
        v = unit_values[u]
        singular, plural, abbrev = UNIT_NAMES[u]
        if compact:
            parts.append(f"{v}{abbrev}")
        else:
            label = singular if v == 1 else plural
            parts.append(f"{v} {label}")

    if compact:
        return " ".join(parts)
    else:
        return ", ".join(parts)
