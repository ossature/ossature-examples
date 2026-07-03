# Interface: RELATIVE_TIME

@source: build

# Public Interface for RELATIVE_TIME

## whenwords

The primary entry point. The following functions are exported at the package root level.

```python
__version__: str = "0.0.1"

from whenwords.duration import format_duration as format_duration
from whenwords.parser import parse_duration as parse_duration
from whenwords.timeago import timeago as timeago
from whenwords.relative import duration as duration

# Note: The following items are exported by the package but their source files 
# were not provided in the directory.
# from whenwords.calendar import human_date as human_date, date_range as date_range

__all__ = [
    "human_date",
    "date_range",
    "format_duration",
    "parse_duration",
    "timeago",
    "duration",
]
```

---

## whenwords.relative

```python
from datetime import datetime

__all__ = ["timeago", "duration", "parse_duration"]

def timeago(
    timestamp: int | float | str | datetime,
    reference: int | float | str | datetime
) -> str:
    """
    Format the difference between a timestamp and reference timestamp as relative time.
    """
    ...

def duration(
    seconds: int | float,
    *,
    compact: bool = False,
    max_units: int = 2
) -> str:
    """
    Format a positive number of seconds as a human-readable duration style.
    """
    ...

def parse_duration(text: str) -> int | float:
    """
    Parse a duration string into seconds.
    """
    ...
```

---

## whenwords.timeago

```python
from datetime import datetime

def timeago(
    timestamp: int | float | str | datetime,
    reference: int | float | str | datetime
) -> str:
    """
    Normalizes both the target timestamp and the reference timestamp,
    calculates the difference, and formats it as relative time (e.g. '3 hours ago' or 'in 5 minutes')
    based on unit thresholds.
    
    Raises:
        ValueError: If input formats are invalid, boolean, out of range, or unsupported.
    """
    ...
```

---

## whenwords.duration

```python
def format_duration(
    seconds: int | float | str,
    options: dict | None = None
) -> str:
    """
    Format a positive number of seconds as a human-readable duration style.
    
    Supported option keys in `options` dict:
        - "compact" (bool): If True, formats as compact style (e.g., "1m 30s" instead of "1 minute, 30 seconds").
        - "max_units" (int): The maximum number of unit divisions to display (default is 2).
        
    Raises:
        ValueError: If seconds is negative, NaN, infinite, or an invalid format.
    """
    ...
```

---

## whenwords.parser

```python
def parse_duration(text: str) -> int | float:
    """
    Parse a duration string into seconds. Supports compact, verbose, colon, and decimal forms.
    
    Raises:
        ValueError: For invalid formatting, negative values, unknown units, or empty inputs.
    """
    ...
```