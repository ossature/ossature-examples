<error_output>
```
warning: The `tool.uv.dev-dependencies` field (used in `pyproject.toml`) is deprecated and will be removed in a future release; use `dependency-groups.dev` instead
warning: `VIRTUAL_ENV=/Users/beshr/src/code/ossature/.venv` does not match the project environment path `.venv` and will be ignored; use `--active` to target the active environment instead
/Users/beshr/src/code/ossature-examples/spenny/output/.venv/bin/python3: No module named pytest
```
</error_output>

<verify_command>
uv run python -m pytest tests/test_storage.py -v
</verify_command>

<current_file path="tests/test_storage.py">
```
"""Unit tests for the storage module."""
import json
from decimal import Decimal
from pathlib import Path

import pytest

from spenny.storage import ExpenseData, ExpenseRecord, load, save


def test_load_returns_empty_default_when_file_absent(tmp_path):
    """Test that load returns default data when the file does not exist."""
    path = tmp_path / "expenses.json"
    data = load(str(path))
    assert data == {"next_id": 1, "expenses": []}


def test_save_writes_valid_pretty_printed_json(tmp_path):
    """Test that save writes valid, pretty-printed JSON."""
    path = tmp_path / "expenses.json"
    data: ExpenseData = {
        "next_id": 2,
        "expenses": [
            {
                "id": 1,
                "date": "2023-10-01",
                "amount": "12.50",
                "category": "Food",
                "description": "Grocery shopping",
            }
        ],
    }
    save(data, str(path))
    
    # Verify the file exists
    assert path.exists()
    
    # Verify the content is valid JSON
    with open(path, "r", encoding="utf-8") as f:
        loaded_data = json.load(f)
    
    assert loaded_data == data
    
    # Verify the JSON is pretty-printed (indented)
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    assert "{\n" in content or "{\r\n" in content


def test_load_round_trips_saved_data_correctly(tmp_path):
    """Test that load correctly round-trips saved data."""
    path = tmp_path / "expenses.json"
    original_data: ExpenseData = {
        "next_id": 3,
        "expenses": [
            {
                "id": 1,
                "date": "2023-10-01",
                "amount": "12.50",
                "category": "Food",
                "description": "Grocery shopping",
            },
            {
                "id": 2,
                "date": "2023-10-02",
                "amount": "25.00",
                "category": "Transport",
                "description": "Bus fare",
            },
        ],
    }
    save(original_data, str(path))
    loaded_data = load(str(path))
    assert loaded_data == original_data


def test_load_exits_with_code_1_on_corrupted_json(tmp_path):
    """Test that load exits with code 1 on corrupted JSON."""
    path = tmp_path / "expenses.json"
    with open(path, "w", encoding="utf-8") as f:
        f.write("{ invalid json ")
    
    with pytest.raises(SystemExit) as exc_info:
        load(str(path))
    assert exc_info.value.code == 1

```
</current_file>

<task>
**Storage Tests**: Write tests/test_storage.py with unit tests for load() and save(). Covers: load returns empty default when file absent, save writes valid pretty-printed JSON, load round-trips saved data correctly, load exits with code 1 on corrupted JSON. Uses tmp_path fixture to avoid touching the real filesystem.
</task>