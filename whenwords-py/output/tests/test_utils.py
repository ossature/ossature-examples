import pytest
from datetime import datetime, timezone
from whenwords.utils import round_half_up, normalize_timestamp

def test_round_half_up_positive():
    assert round_half_up(2.5) == 3
    assert round_half_up(2.4) == 2
    assert round_half_up(2.6) == 3
    assert round_half_up(0) == 0
    assert round_half_up(1.5) == 2
    assert round_half_up(1.49) == 1
    assert round_half_up(0.5) == 1
    assert round_half_up(0.4) == 0

def test_round_half_up_negative():
    assert round_half_up(-2.5) == -3
    assert round_half_up(-2.4) == -2
    assert round_half_up(-2.6) == -3
    assert round_half_up(-0.5) == -1
    assert round_half_up(-0.4) == 0

def test_round_half_up_integer():
    assert round_half_up(5) == 5
    assert round_half_up(-10) == -10
    assert round_half_up(0) == 0

def test_normalize_timestamp_seconds():
    # Int and Float tests
    assert normalize_timestamp(1705276800) == 1705276800.0
    assert normalize_timestamp(1705276800.5) == 1705276800.5

    # Out of range / overflow
    with pytest.raises(ValueError):
        normalize_timestamp(999999999999999)

    # Boolean values are not allowed
    with pytest.raises(ValueError, match="Boolean values are not valid timestamps"):
        normalize_timestamp(True)
    with pytest.raises(ValueError, match="Boolean values are not valid timestamps"):
        normalize_timestamp(False)

def test_normalize_timestamp_datetime():
    # Tz-naive datetime (treated as UTC)
    dt_naive = datetime(2024, 1, 15, 0, 0, 0)
    assert normalize_timestamp(dt_naive) == 1705276800.0

    # Tz-aware datetime
    dt_aware = datetime(2024, 1, 15, 3, 0, 0, tzinfo=timezone.utc)
    assert normalize_timestamp(dt_aware) == 1705276800.0 + 10800.0

def test_normalize_timestamp_iso():
    # Tz-naive ISO string (treated as UTC)
    assert normalize_timestamp("2024-01-15T00:00:00") == 1705276800.0

    # Tz-aware ISO string with Z
    assert normalize_timestamp("2024-01-15T00:00:00Z") == 1705276800.0

    # Tz-aware ISO string with offset
    assert normalize_timestamp("2024-01-15T03:00:00+03:00") == 1705276800.0

    # Invalid ISO string
    with pytest.raises(ValueError, match="Invalid ISO 8601 timestamp format"):
        normalize_timestamp("invalid_date_here")

def test_normalize_timestamp_unsupported():
    with pytest.raises(ValueError, match="Unsupported timestamp format"):
        normalize_timestamp([])
