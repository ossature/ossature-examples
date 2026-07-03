<error_output>
```
============================= test session starts ==============================
platform darwin -- Python 3.14.3, pytest-9.0.3, pluggy-1.6.0
rootdir: /Users/beshr/src/code/ossature-examples/whenwords-py/output
configfile: pyproject.toml
plugins: cov-7.1.0, logfire-4.32.1, anyio-4.13.0
collected 0 items / 1 error

==================================== ERRORS ====================================
___________________ ERROR collecting tests/test_calendar.py ____________________
ImportError while importing test module '/Users/beshr/src/code/ossature-examples/whenwords-py/output/tests/test_calendar.py'.
Hint: make sure your test modules/packages have valid Python names.
Traceback:
/opt/homebrew/Cellar/python@3.14/3.14.3_1/Frameworks/Python.framework/Versions/3.14/lib/python3.14/importlib/__init__.py:88: in import_module
    return _bootstrap._gcd_import(name[level:], package, level)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests/test_calendar.py:4: in <module>
    from whenwords.calendar import human_date, date_range
E   ModuleNotFoundError: No module named 'whenwords'
=========================== short test summary info ============================
ERROR tests/test_calendar.py
!!!!!!!!!!!!!!!!!!!! Interrupted: 1 error during collection !!!!!!!!!!!!!!!!!!!!
=============================== 1 error in 0.06s ===============================
```
</error_output>

<verify_command>
python -m pytest tests/test_calendar.py
</verify_command>

<current_file path="tests/test_calendar.py">
```
import os
import yaml
import pytest
from whenwords.calendar import human_date, date_range

# Locate tests.yaml
TESTS_YAML_PATH = os.path.join(os.path.dirname(__file__), "tests.yaml")


def load_tests():
    with open(TESTS_YAML_PATH, "r", encoding="utf-8") as f:
        data = yaml.safe_load(f)
    return data


# Load the data once
test_data = load_tests()


@pytest.mark.parametrize("case", test_data.get("human_date", []), ids=lambda case: case["name"])
def test_human_date(case):
    inputs = case["input"]
    timestamp = inputs["timestamp"]
    reference = inputs["reference"]
    expected = case["output"]

    assert human_date(timestamp, reference) == expected


@pytest.mark.parametrize("case", test_data.get("date_range", []), ids=lambda case: case["name"])
def test_date_range(case):
    inputs = case["input"]
    start = inputs["start"]
    end = inputs["end"]
    expected = case["output"]

    assert date_range(start, end) == expected


# Hand-crafted test cases to check edge-cases, datetimes, ISO strings, error handling
def test_human_date_invalid_formats():
    # Invalid timestamp
    with pytest.raises(ValueError, match="Invalid ISO 8601 timestamp format"):
        human_date("invalid_iso_string", 1705276800)

    # Invalid type
    with pytest.raises(ValueError, match="Unsupported timestamp format"):
        human_date([], 1705276800)

    # Boolean timestamp
    with pytest.raises(ValueError, match="Boolean values are not valid timestamps"):
        human_date(True, 1705276800)


def test_date_range_invalid_formats():
    with pytest.raises(ValueError, match="Invalid ISO 8601 timestamp format"):
        date_range(1705276800, "invalid_iso_string")


def test_human_date_with_datetime_and_iso():
    from datetime import datetime, timezone
    ref = datetime(2024, 1, 15, 0, 0, 0, tzinfo=timezone.utc)
    ts = datetime(2024, 1, 15, 12, 0, 0, tzinfo=timezone.utc)
    assert human_date(ts, ref) == "Today"

    # Naive datetime is treated as UTC
    ref_naive = datetime(2024, 1, 15, 0, 0, 0)
    ts_naive = datetime(2024, 1, 15, 12, 0, 0)
    assert human_date(ts_naive, ref_naive) == "Today"

    # ISO 8601 formatting with Z
    assert human_date("2024-01-15T12:00:00Z", "2024-01-15T00:00:00Z") == "Today"

    # ISO 8601 formatting with offsets
    assert human_date("2024-01-15T15:00:00+03:00", "2024-01-15T00:00:00Z") == "Today"

```
</current_file>

<task>
**Tests: Calendar Parameterized Tests**: Implement tests/test_calendar.py which parses tests/tests.yaml and executes parameterized pytest assertions for both human_date and date_range.
</task>