"""
Test cases for the calendar formatting functions using the provided tests.yaml file.
"""
import pytest
from src.whenwords.calendar import human_date, date_range


def test_human_date_today():
    """Test human_date for today's date."""
    assert human_date(1705276800, reference=1705276800) == "Today"


def test_human_date_today_same_day_different_time():
    """Test human_date for the same day but different time."""
    assert human_date(1705320000, reference=1705276800) == "Today"


def test_human_date_yesterday():
    """Test human_date for yesterday."""
    assert human_date(1705190400, reference=1705276800) == "Yesterday"


def test_human_date_tomorrow():
    """Test human_date for tomorrow."""
    assert human_date(1705363200, reference=1705276800) == "Tomorrow"


def test_human_date_last_saturday():
    """Test human_date for last Saturday."""
    assert human_date(1705104000, reference=1705276800) == "Last Saturday"


def test_human_date_last_friday():
    """Test human_date for last Friday."""
    assert human_date(1705017600, reference=1705276800) == "Last Friday"


def test_human_date_last_thursday():
    """Test human_date for last Thursday."""
    assert human_date(1704931200, reference=1705276800) == "Last Thursday"


def test_human_date_last_wednesday():
    """Test human_date for last Wednesday."""
    assert human_date(1704844800, reference=1705276800) == "Last Wednesday"


def test_human_date_last_tuesday():
    """Test human_date for last Tuesday."""
    assert human_date(1704758400, reference=1705276800) == "Last Tuesday"


def test_human_date_last_monday():
    """Test human_date for last Monday (7 days ago)."""
    assert human_date(1704672000, reference=1705276800) == "January 8"


def test_human_date_this_wednesday():
    """Test human_date for this Wednesday (2 days future)."""
    assert human_date(1705449600, reference=1705276800) == "This Wednesday"


def test_human_date_this_thursday():
    """Test human_date for this Thursday (3 days future)."""
    assert human_date(1705536000, reference=1705276800) == "This Thursday"


def test_human_date_this_sunday():
    """Test human_date for this Sunday (6 days future)."""
    assert human_date(1705795200, reference=1705276800) == "This Sunday"


def test_human_date_next_monday():
    """Test human_date for next Monday (7 days future)."""
    assert human_date(1705881600, reference=1705276800) == "January 22"


def test_human_date_same_year_different_month():
    """Test human_date for the same year but different month."""
    assert human_date(1709251200, reference=1705276800) == "March 1"


def test_human_date_same_year_end_of_year():
    """Test human_date for the end of the same year."""
    assert human_date(1735603200, reference=1705276800) == "December 31"


def test_human_date_previous_year():
    """Test human_date for a date in the previous year."""
    assert human_date(1672531200, reference=1705276800) == "January 1, 2023"


def test_human_date_next_year():
    """Test human_date for a date in the next year."""
    assert human_date(1736121600, reference=1705276800) == "January 6, 2025"


def test_date_range_same_day():
    """Test date_range for the same day."""
    assert date_range(1705276800, 1705276800) == "January 15, 2024"


def test_date_range_same_day_different_times():
    """Test date_range for the same day but different times."""
    assert date_range(1705276800, 1705320000) == "January 15, 2024"


def test_date_range_consecutive_days_same_month():
    """Test date_range for consecutive days in the same month."""
    assert date_range(1705276800, 1705363200) == "January 15–16, 2024"


def test_date_range_same_month():
    """Test date_range for a range within the same month."""
    assert date_range(1705276800, 1705881600) == "January 15–22, 2024"


def test_date_range_same_year_different_months():
    """Test date_range for a range within the same year but different months."""
    assert date_range(1705276800, 1707955200) == "January 15 – February 15, 2024"


def test_date_range_different_years():
    """Test date_range for a range spanning different years."""
    assert date_range(1703721600, 1705276800) == "December 28, 2023 – January 15, 2024"


def test_date_range_full_year_span():
    """Test date_range for a full year span."""
    assert date_range(1704067200, 1735603200) == "January 1 – December 31, 2024"


def test_date_range_swapped_inputs():
    """Test date_range for swapped inputs (should auto-correct)."""
    assert date_range(1705881600, 1705276800) == "January 15–22, 2024"


def test_date_range_multi_year_span():
    """Test date_range for a multi-year span."""
    assert date_range(1672531200, 1735689600) == "January 1, 2023 – January 1, 2025"
