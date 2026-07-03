import os
import yaml
import pytest
from whenwords.duration import format_duration, parse_duration

# Locate tests.yaml
TESTS_YAML_PATH = os.path.join(os.path.dirname(__file__), "tests.yaml")


def load_tests():
    with open(TESTS_YAML_PATH, "r", encoding="utf-8") as f:
        data = yaml.safe_load(f)
    return data


test_data = load_tests()


@pytest.mark.parametrize("case", test_data.get("duration", []), ids=lambda case: case["name"])
def test_duration(case):
    inputs = case["input"]
    seconds = inputs["seconds"]
    options = inputs.get("options", None)
    
    if case.get("error", False):
        with pytest.raises(ValueError):
            format_duration(seconds, options)
    else:
        expected = case["output"]
        assert format_duration(seconds, options) == expected


@pytest.mark.parametrize("case", test_data.get("parse_duration", []), ids=lambda case: case["name"])
def test_parse_duration(case):
    input_str = case["input"]
    
    if case.get("error", False):
        with pytest.raises(ValueError):
            parse_duration(input_str)
    else:
        expected = case["output"]
        # Convert expected to float to match parsed float response safely
        assert parse_duration(input_str) == float(expected)


# Hand-crafted tests for extra coverage & validation rules
def test_duration_invalid_types():
    with pytest.raises(ValueError, match="Boolean values are not valid durations"):
        format_duration(True)
    with pytest.raises(ValueError, match="Invalid duration value"):
        format_duration("not_a_number")
    with pytest.raises(ValueError, match="Duration cannot be NaN or Infinite"):
        format_duration(float("nan"))
    with pytest.raises(ValueError, match="Duration cannot be NaN or Infinite"):
        format_duration(float("inf"))


def test_parse_duration_invalid_types():
    with pytest.raises(ValueError, match="Input must be a string"):
        parse_duration(123)
    with pytest.raises(ValueError, match="Empty duration string"):
        parse_duration("   ")
    with pytest.raises(ValueError, match="Unknown unit"):
        parse_duration("10 x")
