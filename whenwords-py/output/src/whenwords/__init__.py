"""
whenwords-py: Pure Python functions for human-friendly date and time formatting.

This package provides two main modules:
- Calendar Format: Converts timestamps into contextual date strings and abbreviates date ranges.
- Relative Time: Formats durations into readable strings and parses human-written durations.

All functions are pure, requiring explicit reference timestamps and avoiding side effects or I/O.
"""

# Import modules for easier access
from . import calendar  # type: ignore
from . import relative  # type: ignore
