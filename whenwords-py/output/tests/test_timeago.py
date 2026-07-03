import os
import yaml
import pytest
from datetime import datetime
from whenwords.timeago import timeago

# Locate tests.yaml
TESTS_YAML_PATH = os.path.join(os.path.dirname(__file__), "tests.yaml")


def load_tests():
    with open(TESTS_YAML_PATH, "r", encoding="utf-8") as f:
        data = yaml.safe_load(f)
    return data


test_data = load_tests()


@pytest.mark.parametrize("case", test_data.get("timeago", []), ids=lambda case: case["name"])
def test_timeago_from_yaml(case):
    inputs = case["input"]
    timestamp = inputs["timestamp"]
    reference = inputs["reference"]
    expected = case["output"]

    assert timeago(timestamp, reference) == expected


def test_timeago_invalid_formats():
    # Boolean timestamp
    with pytest.raises(ValueError, match="Boolean values are not valid timestamps"):
        timeago(True, 1704067200)

    # Invalid timestamp string
    with pytest.raises(ValueError, match="Invalid ISO 8601 timestamp format"):
        timeago("invalid_date", 1704067200)

    # Out of range timestamp (float overflow/underflow)
    with pytest.raises(ValueError):
        timeago(999999999999999, 1704067200)

    # Invalid types
    with pytest.raises(ValueError, match="Unsupported timestamp format"):
        timeago([], 1704067200)


def test_timeago_with_datetime_and_iso():
    from datetime import timezone
    ref = datetime(2024, 1, 1, 0, 0, 0, tzinfo=timezone.utc)
    ts = datetime(2024, 1, 1, 0, 5, 0, tzinfo=timezone.utc) # 5 minutes future
    assert timeago(ts, ref) == "in 5 minutes"

    # Naive datetime
    ref_naive = datetime(2024, 1, 1, 0, 0, 0)
    ts_naive = datetime(2024, 1, 1, 0, 5, 0)
    assert timeago(ts_naive, ref_naive) == "in 5 minutes"

    # Iso string
    assert timeago("2024-01-01T00:05:00Z", "2024-01-01T00:00:00Z") == "in 5 minutes"
