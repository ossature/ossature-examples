# Interface: RELATIVE_TIME

@source: build

# Public Interface for RELATIVE_TIME

## src/whenwords/relative.py

```python
from datetime import datetime
from typing import TypedDict

class DurationOptions(TypedDict, total=False):
    compact: bool
    max_units: int

def timeago(
    timestamp: int | float | str | datetime,
    reference: int | float | str | datetime | None = None,
) -> str:
    ...

def duration(seconds: int | float, options: DurationOptions | None = None) -> str:
    ...

def parse_duration(text: str) -> int | float:
    ...
```

## Error Types

The module raises the following errors:

- `TypeError`: When an unsupported timestamp type is provided to `timeago`
- `ValueError`: When a negative duration is provided to `duration`
- `ValueError`: When an invalid duration string is provided to `parse_duration`