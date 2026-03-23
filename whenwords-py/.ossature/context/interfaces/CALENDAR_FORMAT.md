# Interface: CALENDAR_FORMAT

@source: build

# Interface Document for CALENDAR_FORMAT

## src/whenwords/calendar.py

```python
from datetime import datetime, timezone
from typing import Union

def human_date(timestamp: Union[int, float, str, datetime],
              reference: Union[int, float, str, datetime]) -> str:
    """Return a contextual date string describing when a timestamp falls relative to a reference date."""
    ...

def date_range(start: Union[int, float, str, datetime],
               end: Union[int, float, str, datetime]) -> str:
    """Format a start and end timestamp as a human-readable date range with smart abbreviation."""
    ...
```