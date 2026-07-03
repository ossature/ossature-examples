import os
import yaml
import pytest
from datetime import datetime, timezone
from whenwords.relative import timeago, duration, parse_duration

# Locate tests.yaml
TESTS_YAML_PATH = os.path.join(os.path.dirname(__file__), "tests.yaml")


def load_tests():
    with open(TESTS_YAML_PATH, "r", encoding="utf-8") as f:
        data = yaml.safe_load(f)
    return data


test_data = load_tests()


@pytest.mark.parametrize("case", test_data.get("timeago", []), ids=lambda case: case["name"])
def test_relative_timeago_cases(case):
    inputs = case["input"]
    timestamp = inputs["timestamp"]
    reference = inputs["reference"]
    expected = case["output"]
    assert timeago(timestamp, reference) == expected


@pytest.mark.parametrize("case", test_data.get("duration", []), ids=lambda case: case["name"])
def test_relative_duration_cases(case):
    inputs = case["input"]
    seconds = inputs["seconds"]
    options = inputs.get("options", {})
    
    # If options is None or not a dict
    if not isinstance(options, dict):
        options = {}
    
    compact = options.get("compact", False)
    max_units = options.get("max_units", 2)
    
    if case.get("error", False):
        with pytest.raises(ValueError):
            duration(seconds, compact=compact, max_units=max_units)
    else:
        expected = case["output"]
        assert duration(seconds, compact=compact, max_units=max_units) == expected


@pytest.mark.parametrize("case", test_data.get("parse_duration", []), ids=lambda case: case["name"])
def test_relative_parse_duration_cases(case):
    input_str = case["input"]
    if case.get("error", False):
        with pytest.raises(ValueError):
            parse_duration(input_str)
    else:
        expected = case["output"]
        assert parse_duration(input_str) == float(expected)


def test_relative_timeago_extra_validation():
    # Naive datetimes (without timezone)
    ref_naive = datetime(2024, 1, 1, 0, 0, 0)
    ts_naive = datetime(2024, 1, 1, 0, 5, 0)
    assert timeago(ts_naive, ref_naive) == "in 5 minutes"

    # Timezone-aware datetimes
    ref_aware = datetime(2024, 1, 1, 0, 0, 0, tzinfo=timezone.utc)
    ts_aware = datetime(2024, 1, 1, 0, 5, 0, tzinfo=timezone.utc)
    assert timeago(ts_aware, ref_aware) == "in 5 minutes"

    # ISO 8601 string inputs
    assert timeago("2024-01-01T00:05:00Z", "2024-01-01T00:00:00Z") == "in 5 minutes"


def test_relative_timeago_errors():
    with pytest.raises(ValueError, match="Boolean values are not valid timestamps"):
        timeago(True, 1704067200)

    with pytest.raises(ValueError, match="Invalid ISO 8601 timestamp format"):
        timeago("invalid_date", 1704067200)

    with pytest.raises(ValueError):
        timeago(999999999999999, 1704067200)

    with pytest.raises(ValueError, match="Unsupported timestamp format"):
        timeago([], 1704067200)


def test_relative_duration_errors():
    with pytest.raises(ValueError, match="Boolean values are not valid durations"):
        duration(True)
    with pytest.raises(ValueError, match="Invalid duration value"):
        duration("not_a_number")
    with pytest.raises(ValueError, match="Duration cannot be NaN or Infinite"):
        duration(float("nan"))
    with pytest.raises(ValueError, match="Duration cannot be NaN or Infinite"):
        duration(float("inf"))


def test_relative_parse_duration_errors():
    with pytest.raises(ValueError, match="Input must be a string"):
        parse_duration(123)
    with pytest.raises(ValueError, match="Empty duration string"):
        parse_duration("   ")
    with pytest.raises(ValueError, match="Unknown unit"):
        parse_duration("10 x")
