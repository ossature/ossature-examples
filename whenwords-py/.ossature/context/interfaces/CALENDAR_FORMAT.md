# Interface: CALENDAR_FORMAT

@source: build

# API Reference

## whenwords

```python
from datetime import datetime
from typing import Union

__version__: str

def human_date(
    timestamp: int | float | datetime | str,
    reference: int | float | datetime | str
) -> str:
    """
    Return a contextual date string describing when a timestamp falls relative to a reference date.
    Prioritizes human-friendly labels ("Today", "Yesterday", "Last Friday") over raw dates.

    Raises:
        ValueError: If either the timestamp or reference is invalid or in an unsupported format.
    """
    ...

def date_range(
    start: int | float | datetime | str,
    end: int | float | datetime | str
) -> str:
    """
    Format a start and end timestamp as a human-readable date range with smart abbreviation.
    Elides repeated components (month, year) when they are the same for start and end.

    Raises:
        ValueError: If either start or end is invalid or in an unsupported format.
    """
    ...
```