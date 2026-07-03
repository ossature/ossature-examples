import re

UNIT_MAPPING = {
    'y': 31536000,
    'yr': 31536000,
    'yrs': 31536000,
    'year': 31536000,
    'years': 31536000,
    'mo': 2592000,
    'month': 2592000,
    'months': 2592000,
    'w': 604800,
    'week': 604800,
    'weeks': 604800,
    'd': 86400,
    'day': 86400,
    'days': 86400,
    'h': 3600,
    'hr': 3600,
    'hrs': 3600,
    'hour': 3600,
    'hours': 3600,
    'm': 60,
    'min': 60,
    'mins': 60,
    'minute': 60,
    'minutes': 60,
    's': 1,
    'sec': 1,
    'second': 1,
    'seconds': 1,
}

def parse_duration(text: str) -> int | float:
    """
    Parse a duration string into seconds.
    Supports compact, verbose, colon, and decimal forms.
    Raises ValueError for invalid, negative, or empty format inputs.
    """
    if not isinstance(text, str):
        raise ValueError("Input must be a string")

    text = text.strip()
    if not text:
        raise ValueError("Empty duration string")

    # Check colon notation first: h:mm or h:mm:ss
    colon_match = re.match(r'^(\d+):(\d{2})(?::(\d{2}))?$', text)
    if colon_match:
        hours_str, mins_str, secs_str = colon_match.groups()
        hours = int(hours_str)
        mins = int(mins_str)
        secs = int(secs_str) if secs_str else 0
        total = hours * 3600 + mins * 60 + secs
        return total

    # Check for negative values with leading minus on the whole thing
    if text.startswith('-'):
        raise ValueError("Negative values not allowed")

    # Build regex pattern for whitespace-separated or compact number + unit pairs
    # Supports positive integer or decimal numbers
    pair_pattern = re.compile(r'([+-]?\d+(?:\.\d+)?)\s*([a-zA-Z]+)')
    matches = list(pair_pattern.finditer(text))

    if not matches:
        raise ValueError(f"Could not parse duration: '{text}'")

    # Validate separators and gaps
    last_end = 0
    for m in matches:
        start, end = m.span()
        gap = text[last_end:start].strip().lower()
        # Remove valid separators: comma and "and"
        gap = gap.replace(",", "").replace("and", "").strip()
        if gap:
            raise ValueError(f"Invalid formatting/separators in duration string: '{text[last_end:start]}'")
        last_end = end

    gap_end = text[last_end:].strip().lower()
    gap_end = gap_end.replace(",", "").replace("and", "").strip()
    if gap_end:
        raise ValueError(f"Invalid formatting at the end of duration string: '{text[last_end:]}'")

    total_seconds = 0.0
    for m in matches:
        val_str, unit_str = m.groups()
        val_float = float(val_str)
        if val_float < 0:
            raise ValueError(f"Negative values not allowed: {val_str}")
        
        unit_key = unit_str.lower()
        if unit_key not in UNIT_MAPPING:
            raise ValueError(f"Unknown unit: '{unit_str}'")
        
        total_seconds += val_float * UNIT_MAPPING[unit_key]

    # Convert to int if it's a mathematically whole number, otherwise float
    if total_seconds.is_integer():
        return int(total_seconds)
    return total_seconds
