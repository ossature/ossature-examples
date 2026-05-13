import json
import os
import sys
import tempfile
from decimal import Decimal
from pathlib import Path

import pytest

from spenny.storage import ExpenseData, ExpenseRecord, load, save


def test_load_missing_file_auto_creates_empty_store():
    """Test that load() creates an empty store when file doesn't exist"""
    with tempfile.TemporaryDirectory() as tmpdir:
        path = Path(tmpdir) / "expenses.json"
        
        # File doesn't exist
        assert not path.exists()
        
        # Load should create empty store
        data = load(str(path))
        
        # Verify structure
        assert isinstance(data, dict)
        assert "next_id" in data
        assert "expenses" in data
        assert data["next_id"] == 1
        assert data["expenses"] == []


def test_load_valid_json():
    """Test that load() correctly loads valid JSON data"""
    with tempfile.TemporaryDirectory() as tmpdir:
        path = Path(tmpdir) / "expenses.json"
        
        # Create valid JSON file
        test_data: ExpenseData = {
            "next_id": 3,
            "expenses": [
                {
                    "id": 1,
                    "date": "2024-01-01",
                    "amount": "12.50",
                    "category": "Food",
                    "description": "Grocery shopping"
                },
                {
                    "id": 2,
                    "date": "2024-01-02",
                    "amount": "25.00",
                    "category": "Transport",
                    "description": "Bus fare"
                }
            ]
        }
        
        with open(path, "w") as f:
            json.dump(test_data, f)
        
        # Load and verify
        loaded_data = load(str(path))
        assert loaded_data == test_data


def test_load_corrupted_json_exits_code_1(capsys):
    """Test that load() exits with code 1 on corrupted JSON"""
    with tempfile.TemporaryDirectory() as tmpdir:
        path = Path(tmpdir) / "expenses.json"
        
        # Create corrupted JSON file
        with open(path, "w") as f:
            f.write("{invalid json}")
        
        # This should exit with code 1
        with pytest.raises(SystemExit) as exc_info:
            load(str(path))
        
        assert exc_info.value.code == 1
        
        # Verify error message was printed
        captured = capsys.readouterr()
        assert "Error: Corrupted JSON file" in captured.err


def test_save_writes_pretty_printed_json_with_string_amounts():
    """Test that save() writes pretty-printed JSON with string amounts"""
    with tempfile.TemporaryDirectory() as tmpdir:
        path = Path(tmpdir) / "expenses.json"
        
        # Create test data
        test_data: ExpenseData = {
            "next_id": 2,
            "expenses": [
                {
                    "id": 1,
                    "date": "2024-01-01",
                    "amount": "12.50",
                    "category": "Food",
                    "description": "Grocery shopping"
                }
            ]
        }
        
        # Save data
        save(test_data, str(path))
        
        # Verify file exists and is pretty-printed
        assert path.exists()
        
        with open(path, "r") as f:
            content = f.read()
        
        # Check that it's pretty-printed (has newlines and indentation)
        assert "\n" in content
        assert "  " in content
        
        # Verify amounts are stored as strings
        loaded = json.loads(content)
        assert loaded["expenses"][0]["amount"] == "12.50"
        assert isinstance(loaded["expenses"][0]["amount"], str)


def test_round_trip_fidelity():
    """Test that save() and load() maintain data fidelity"""
    with tempfile.TemporaryDirectory() as tmpdir:
        path = Path(tmpdir) / "expenses.json"
        
        # Create original data
        original_data: ExpenseData = {
            "next_id": 4,
            "expenses": [
                {
                    "id": 1,
                    "date": "2024-01-01",
                    "amount": "12.50",
                    "category": "Food",
                    "description": "Grocery shopping"
                },
                {
                    "id": 2,
                    "date": "2024-01-02",
                    "amount": "25.00",
                    "category": "Transport",
                    "description": "Bus fare"
                },
                {
                    "id": 3,
                    "date": "2024-01-03",
                    "amount": "100.00",
                    "category": "Entertainment",
                    "description": "Movie tickets"
                }
            ]
        }
        
        # Save and reload
        save(original_data, str(path))
        loaded_data = load(str(path))
        
        # Verify data is identical
        assert loaded_data == original_data
        
        # Verify all amounts are still strings
        for expense in loaded_data["expenses"]:
            assert isinstance(expense["amount"], str)
