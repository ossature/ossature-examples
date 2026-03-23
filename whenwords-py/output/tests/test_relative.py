"""Tests for the relative time module using test cases from tests.yaml"""
import pytest
from datetime import datetime
from src.whenwords.relative import timeago, duration, parse_duration


# Timeago test cases
TIMEAGO_TEST_CASES = [
    # just now cases
    {"name": "just now - identical timestamps", "input": {"timestamp": 1704067200, "reference": 1704067200}, "output": "just now"},
    {"name": "just now - 30 seconds ago", "input": {"timestamp": 1704067170, "reference": 1704067200}, "output": "just now"},
    {"name": "just now - 44 seconds ago", "input": {"timestamp": 1704067156, "reference": 1704067200}, "output": "just now"},
    
    # minutes
    {"name": "1 minute ago - 45 seconds", "input": {"timestamp": 1704067155, "reference": 1704067200}, "output": "1 minute ago"},
    {"name": "1 minute ago - 89 seconds", "input": {"timestamp": 1704067111, "reference": 1704067200}, "output": "1 minute ago"},
    {"name": "2 minutes ago - 90 seconds", "input": {"timestamp": 1704067110, "reference": 1704067200}, "output": "2 minutes ago"},
    {"name": "30 minutes ago", "input": {"timestamp": 1704065400, "reference": 1704067200}, "output": "30 minutes ago"},
    {"name": "44 minutes ago", "input": {"timestamp": 1704064560, "reference": 1704067200}, "output": "44 minutes ago"},
    
    # hours
    {"name": "1 hour ago - 45 minutes", "input": {"timestamp": 1704064500, "reference": 1704067200}, "output": "1 hour ago"},
    {"name": "1 hour ago - 89 minutes", "input": {"timestamp": 1704061860, "reference": 1704067200}, "output": "1 hour ago"},
    {"name": "2 hours ago - 90 minutes", "input": {"timestamp": 1704061800, "reference": 1704067200}, "output": "2 hours ago"},
    {"name": "5 hours ago", "input": {"timestamp": 1704049200, "reference": 1704067200}, "output": "5 hours ago"},
    {"name": "21 hours ago", "input": {"timestamp": 1703991600, "reference": 1704067200}, "output": "21 hours ago"},
    
    # days
    {"name": "1 day ago - 22 hours", "input": {"timestamp": 1703988000, "reference": 1704067200}, "output": "1 day ago"},
    {"name": "1 day ago - 35 hours", "input": {"timestamp": 1703941200, "reference": 1704067200}, "output": "1 day ago"},
    {"name": "2 days ago - 36 hours", "input": {"timestamp": 1703937600, "reference": 1704067200}, "output": "2 days ago"},
    {"name": "7 days ago", "input": {"timestamp": 1703462400, "reference": 1704067200}, "output": "7 days ago"},
    {"name": "25 days ago", "input": {"timestamp": 1701907200, "reference": 1704067200}, "output": "25 days ago"},
    
    # months
    {"name": "1 month ago - 26 days", "input": {"timestamp": 1701820800, "reference": 1704067200}, "output": "1 month ago"},
    {"name": "1 month ago - 45 days", "input": {"timestamp": 1700179200, "reference": 1704067200}, "output": "1 month ago"},
    {"name": "2 months ago - 46 days", "input": {"timestamp": 1700092800, "reference": 1704067200}, "output": "2 months ago"},
    {"name": "6 months ago", "input": {"timestamp": 1688169600, "reference": 1704067200}, "output": "6 months ago"},
    {"name": "11 months ago - 319 days", "input": {"timestamp": 1676505600, "reference": 1704067200}, "output": "11 months ago"},
    
    # years
    {"name": "1 year ago - 320 days", "input": {"timestamp": 1676419200, "reference": 1704067200}, "output": "1 year ago"},
    {"name": "1 year ago - 547 days", "input": {"timestamp": 1656806400, "reference": 1704067200}, "output": "1 year ago"},
    {"name": "2 years ago - 548 days", "input": {"timestamp": 1656720000, "reference": 1704067200}, "output": "2 years ago"},
    {"name": "5 years ago", "input": {"timestamp": 1546300800, "reference": 1704067200}, "output": "5 years ago"},
    
    # future
    {"name": "future - in just now (30 seconds)", "input": {"timestamp": 1704067230, "reference": 1704067200}, "output": "just now"},
    {"name": "future - in 1 minute", "input": {"timestamp": 1704067260, "reference": 1704067200}, "output": "in 1 minute"},
    {"name": "future - in 5 minutes", "input": {"timestamp": 1704067500, "reference": 1704067200}, "output": "in 5 minutes"},
    {"name": "future - in 1 hour", "input": {"timestamp": 1704070200, "reference": 1704067200}, "output": "in 1 hour"},
    {"name": "future - in 3 hours", "input": {"timestamp": 1704078000, "reference": 1704067200}, "output": "in 3 hours"},
    {"name": "future - in 1 day", "input": {"timestamp": 1704150000, "reference": 1704067200}, "output": "in 1 day"},
    {"name": "future - in 2 days", "input": {"timestamp": 1704240000, "reference": 1704067200}, "output": "in 2 days"},
    {"name": "future - in 1 month", "input": {"timestamp": 1706745600, "reference": 1704067200}, "output": "in 1 month"},
    {"name": "future - in 1 year", "input": {"timestamp": 1735689600, "reference": 1704067200}, "output": "in 1 year"},
]


# Duration test cases
DURATION_TEST_CASES = [
    {"name": "zero seconds", "input": {"seconds": 0}, "output": "0 seconds"},
    {"name": "1 second", "input": {"seconds": 1}, "output": "1 second"},
    {"name": "45 seconds", "input": {"seconds": 45}, "output": "45 seconds"},
    {"name": "1 minute", "input": {"seconds": 60}, "output": "1 minute"},
    {"name": "1 minute 30 seconds", "input": {"seconds": 90}, "output": "1 minute, 30 seconds"},
    {"name": "2 minutes", "input": {"seconds": 120}, "output": "2 minutes"},
    {"name": "1 hour", "input": {"seconds": 3600}, "output": "1 hour"},
    {"name": "1 hour 1 minute", "input": {"seconds": 3661}, "output": "1 hour, 1 minute"},
    {"name": "1 hour 30 minutes", "input": {"seconds": 5400}, "output": "1 hour, 30 minutes"},
    {"name": "2 hours 30 minutes", "input": {"seconds": 9000}, "output": "2 hours, 30 minutes"},
    {"name": "1 day", "input": {"seconds": 86400}, "output": "1 day"},
    {"name": "1 day 2 hours", "input": {"seconds": 93600}, "output": "1 day, 2 hours"},
    {"name": "7 days", "input": {"seconds": 604800}, "output": "7 days"},
    {"name": "1 month (30 days)", "input": {"seconds": 2592000}, "output": "1 month"},
    {"name": "1 year (365 days)", "input": {"seconds": 31536000}, "output": "1 year"},
    {"name": "1 year 2 months", "input": {"seconds": 36720000}, "output": "1 year, 2 months"},
    
    # Compact format
    {"name": "compact - 1h 1m", "input": {"seconds": 3661, "options": {"compact": True}}, "output": "1h 1m"},
    {"name": "compact - 2h 30m", "input": {"seconds": 9000, "options": {"compact": True}}, "output": "2h 30m"},
    {"name": "compact - 1d 2h", "input": {"seconds": 93600, "options": {"compact": True}}, "output": "1d 2h"},
    {"name": "compact - 45s", "input": {"seconds": 45, "options": {"compact": True}}, "output": "45s"},
    {"name": "compact - 0s", "input": {"seconds": 0, "options": {"compact": True}}, "output": "0s"},
    
    # max_units
    {"name": "max_units 1 - hours only", "input": {"seconds": 3661, "options": {"max_units": 1}}, "output": "1 hour"},
    {"name": "max_units 1 - days only", "input": {"seconds": 93600, "options": {"max_units": 1}}, "output": "1 day"},
    {"name": "max_units 3", "input": {"seconds": 93661, "options": {"max_units": 3}}, "output": "1 day, 2 hours, 1 minute"},
    {"name": "compact max_units 1", "input": {"seconds": 9000, "options": {"compact": True, "max_units": 1}}, "output": "3h"},
    
    # Error case
    {"name": "error - negative seconds", "input": {"seconds": -100}, "error": True},
]


# Parse duration test cases
PARSE_DURATION_TEST_CASES = [
    {"name": "compact hours minutes", "input": "2h30m", "output": 9000},
    {"name": "compact with space", "input": "2h 30m", "output": 9000},
    {"name": "compact with comma", "input": "2h, 30m", "output": 9000},
    {"name": "verbose", "input": "2 hours 30 minutes", "output": 9000},
    {"name": "verbose with and", "input": "2 hours and 30 minutes", "output": 9000},
    {"name": "verbose with comma and", "input": "2 hours, and 30 minutes", "output": 9000},
    {"name": "decimal hours", "input": "2.5 hours", "output": 9000},
    {"name": "decimal compact", "input": "1.5h", "output": 5400},
    {"name": "single unit minutes verbose", "input": "90 minutes", "output": 5400},
    {"name": "single unit minutes compact", "input": "90m", "output": 5400},
    {"name": "single unit min", "input": "90min", "output": 5400},
    {"name": "colon notation h:mm", "input": "2:30", "output": 9000},
    {"name": "colon notation h:mm:ss", "input": "1:30:00", "output": 5400},
    {"name": "colon notation with seconds", "input": "0:05:30", "output": 330},
    {"name": "days verbose", "input": "2 days", "output": 172800},
    {"name": "days compact", "input": "2d", "output": 172800},
    {"name": "weeks verbose", "input": "1 week", "output": 604800},
    {"name": "weeks compact", "input": "1w", "output": 604800},
    {"name": "mixed verbose", "input": "1 day, 2 hours, and 30 minutes", "output": 95400},
    {"name": "mixed compact", "input": "1d 2h 30m", "output": 95400},
    {"name": "seconds only verbose", "input": "45 seconds", "output": 45},
    {"name": "seconds compact s", "input": "45s", "output": 45},
    {"name": "seconds compact sec", "input": "45sec", "output": 45},
    {"name": "hours hr", "input": "2hr", "output": 7200},
    {"name": "hours hrs", "input": "2hrs", "output": 7200},
    {"name": "minutes mins", "input": "30mins", "output": 1800},
    {"name": "case insensitive", "input": "2H 30M", "output": 9000},
    {"name": "whitespace tolerance", "input": "  2 hours   30 minutes  ", "output": 9000},
    
    # Error cases
    {"name": "error - empty string", "input": "", "error": True},
    {"name": "error - no units", "input": "hello world", "error": True},
    {"name": "error - negative", "input": "-5 hours", "error": True},
    {"name": "error - just number", "input": "42", "error": True},
]


@pytest.mark.parametrize("test_case", TIMEAGO_TEST_CASES)
def test_timeago(test_case):
    """Test timeago function with various timestamp differences"""
    input_data = test_case["input"]
    expected = test_case["output"]
    
    # Test with Unix timestamps
    result = timeago(input_data["timestamp"], input_data["reference"])
    assert result == expected
    
    # Test with datetime objects
    timestamp_dt = datetime.fromtimestamp(input_data["timestamp"])
    reference_dt = datetime.fromtimestamp(input_data["reference"])
    result_dt = timeago(timestamp_dt, reference_dt)
    assert result_dt == expected
    
    # Test with ISO 8601 strings
    timestamp_iso = datetime.fromtimestamp(input_data["timestamp"]).isoformat()
    reference_iso = datetime.fromtimestamp(input_data["reference"]).isoformat()
    result_iso = timeago(timestamp_iso, reference_iso)
    assert result_iso == expected


@pytest.mark.parametrize("test_case", DURATION_TEST_CASES)
def test_duration(test_case):
    """Test duration function with various second values and options"""
    input_data = test_case["input"]
    
    if test_case.get("error"):
        # Test error case
        with pytest.raises(ValueError):
            duration(input_data["seconds"])
    else:
        # Test normal case
        expected = test_case["output"]
        options = input_data.get("options")
        result = duration(input_data["seconds"], options)
        assert result == expected


@pytest.mark.parametrize("test_case", PARSE_DURATION_TEST_CASES)
def test_parse_duration(test_case):
    """Test parse_duration function with various duration strings"""
    input_str = test_case["input"]
    
    if test_case.get("error"):
        # Test error case
        with pytest.raises(ValueError):
            parse_duration(input_str)
    else:
        # Test normal case
        expected = test_case["output"]
        result = parse_duration(input_str)
        assert result == expected