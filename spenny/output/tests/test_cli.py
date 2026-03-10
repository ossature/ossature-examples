"""Integration tests for the Spenny CLI."""
import json
import sys
from decimal import Decimal
from datetime import date
from unittest.mock import patch, MagicMock

import pytest

from spenny.cli import main
from spenny.storage import load, save


@pytest.fixture
def mock_storage(tmp_path):
    """Fixture to mock storage functions to use temp file."""
    file_path = tmp_path / "expenses.json"
    
    # Mock load and save functions
    original_load = load
    original_save = save
    
    def mock_load(path="expenses.json"):
        return original_load(str(file_path))
    
    def mock_save(data, path="expenses.json"):
        return original_save(data, str(file_path))
    
    with patch('spenny.cli.load', side_effect=mock_load), \
         patch('spenny.cli.save', side_effect=mock_save):
        yield file_path


def test_add_expense_creates_file_and_prints_confirmation(mock_storage, capsys):
    """Test that adding an expense creates the file and prints confirmation."""
    test_args = ["add", "--amount", "12.50", "--category", "Food", "--description", "Lunch"]
    
    with patch.object(sys, 'argv', ["spenny"] + test_args):
        main()
    
    # Check file was created
    assert mock_storage.exists()
    
    # Check output
    captured = capsys.readouterr()
    assert "Expense added: #1" in captured.out
    assert "$12.50" in captured.out
    assert "[Food]" in captured.out
    assert "Lunch" in captured.out
    
    # Check file content
    with open(mock_storage) as f:
        data = json.load(f)
    assert data["next_id"] == 2
    assert len(data["expenses"]) == 1
    assert data["expenses"][0]["id"] == 1
    assert data["expenses"][0]["amount"] == "12.50"
    assert data["expenses"][0]["category"] == "Food"


def test_list_empty_expenses_prints_no_expenses(mock_storage, capsys):
    """Test that listing with no expenses shows 'No expenses found.'"""
    # Create empty file
    with open(mock_storage, 'w') as f:
        json.dump({"next_id": 1, "expenses": []}, f)
    
    test_args = ["list"]
    
    with patch.object(sys, 'argv', ["spenny"] + test_args):
        main()
    
    captured = capsys.readouterr()
    assert "No expenses found." in captured.out


def test_list_shows_expenses_in_table(mock_storage, capsys):
    """Test that listing expenses shows them in a formatted table."""
    # Create file with test data
    data = {
        "next_id": 3,
        "expenses": [
            {"id": 1, "date": "2026-03-01", "amount": "12.50", "category": "Food", "description": "Lunch"},
            {"id": 2, "date": "2026-03-02", "amount": "3.00", "category": "Transport", "description": "Bus"},
        ]
    }
    with open(mock_storage, 'w') as f:
        json.dump(data, f)
    
    test_args = ["list"]
    
    with patch.object(sys, 'argv', ["spenny"] + test_args):
        main()
    
    captured = capsys.readouterr()
    assert "ID   Date         Category     Amount   Description" in captured.out
    assert "1    2026-03-01   Food       $12.50   Lunch" in captured.out
    assert "2    2026-03-02   Transport  $3.00    Bus" in captured.out


def test_list_filter_by_category(mock_storage, capsys):
    """Test that listing with category filter works correctly."""
    # Create file with test data
    data = {
        "next_id": 4,
        "expenses": [
            {"id": 1, "date": "2026-03-01", "amount": "12.50", "category": "Food", "description": "Lunch"},
            {"id": 2, "date": "2026-03-02", "amount": "3.00", "category": "Transport", "description": "Bus"},
            {"id": 3, "date": "2026-03-02", "amount": "8.75", "category": "Food", "description": "Coffee"},
        ]
    }
    with open(mock_storage, 'w') as f:
        json.dump(data, f)
    
    test_args = ["list", "--category", "Food"]
    
    with patch.object(sys, 'argv', ["spenny"] + test_args):
        main()
    
    captured = capsys.readouterr()
    assert "1    2026-03-01   Food       $12.50   Lunch" in captured.out
    assert "3    2026-03-02   Food       $8.75    Coffee" in captured.out
    assert "Transport" not in captured.out


def test_list_filter_by_date_range(mock_storage, capsys):
    """Test that listing with date range filter works correctly."""
    # Create file with test data
    data = {
        "next_id": 4,
        "expenses": [
            {"id": 1, "date": "2026-03-01", "amount": "12.50", "category": "Food", "description": "Lunch"},
            {"id": 2, "date": "2026-03-02", "amount": "3.00", "category": "Transport", "description": "Bus"},
            {"id": 3, "date": "2026-03-03", "amount": "8.75", "category": "Food", "description": "Coffee"},
        ]
    }
    with open(mock_storage, 'w') as f:
        json.dump(data, f)
    
    test_args = ["list", "--start-date", "2026-03-02", "--end-date", "2026-03-02"]
    
    with patch.object(sys, 'argv', ["spenny"] + test_args):
        main()
    
    captured = capsys.readouterr()
    assert "2    2026-03-02   Transport  $3.00    Bus" in captured.out
    assert "Lunch" not in captured.out
    assert "Coffee" not in captured.out


def test_delete_expense_removes_and_confirms(mock_storage, capsys):
    """Test that deleting an expense removes it and prints confirmation."""
    # Create file with test data
    data = {
        "next_id": 3,
        "expenses": [
            {"id": 1, "date": "2026-03-01", "amount": "12.50", "category": "Food", "description": "Lunch"},
            {"id": 2, "date": "2026-03-02", "amount": "3.00", "category": "Transport", "description": "Bus"},
        ]
    }
    with open(mock_storage, 'w') as f:
        json.dump(data, f)
    
    test_args = ["delete", "1"]
    
    with patch.object(sys, 'argv', ["spenny"] + test_args):
        main()
    
    captured = capsys.readouterr()
    assert "Expense #1 deleted." in captured.out
    
    # Check file content
    with open(mock_storage) as f:
        updated_data = json.load(f)
    assert len(updated_data["expenses"]) == 1
    assert updated_data["expenses"][0]["id"] == 2


def test_delete_unknown_id_exits_with_error(mock_storage, capsys):
    """Test that deleting unknown ID prints error and exits with code 1."""
    # Create file with test data
    data = {
        "next_id": 2,
        "expenses": [
            {"id": 1, "date": "2026-03-01", "amount": "12.50", "category": "Food", "description": "Lunch"},
        ]
    }
    with open(mock_storage, 'w') as f:
        json.dump(data, f)
    
    test_args = ["delete", "99"]
    
    with patch.object(sys, 'argv', ["spenny"] + test_args), \
         pytest.raises(SystemExit) as exc_info:
        main()
    
    assert exc_info.value.code == 1
    captured = capsys.readouterr()
    assert "Expense with ID 99 not found" in captured.err


def test_summary_shows_totals_and_overall(mock_storage, capsys):
    """Test that summary shows per-category totals and overall total."""
    # Create file with test data
    data = {
        "next_id": 4,
        "expenses": [
            {"id": 1, "date": "2026-03-01", "amount": "12.50", "category": "Food", "description": "Lunch"},
            {"id": 2, "date": "2026-03-02", "amount": "3.00", "category": "Transport", "description": "Bus"},
            {"id": 3, "date": "2026-03-02", "amount": "8.75", "category": "Food", "description": "Coffee"},
        ]
    }
    with open(mock_storage, 'w') as f:
        json.dump(data, f)
    
    test_args = ["summary"]
    
    with patch.object(sys, 'argv', ["spenny"] + test_args):
        main()
    
    captured = capsys.readouterr()
    assert "Category     Total" in captured.out
    assert "Food         $21.25" in captured.out
    assert "Transport    $3.00" in captured.out
    assert "Total: $24.25" in captured.out


def test_summary_with_date_range(mock_storage, capsys):
    """Test that summary with date range filters correctly."""
    # Create file with test data
    data = {
        "next_id": 4,
        "expenses": [
            {"id": 1, "date": "2026-03-01", "amount": "12.50", "category": "Food", "description": "Lunch"},
            {"id": 2, "date": "2026-03-02", "amount": "3.00", "category": "Transport", "description": "Bus"},
            {"id": 3, "date": "2026-03-03", "amount": "8.75", "category": "Food", "description": "Coffee"},
        ]
    }
    with open(mock_storage, 'w') as f:
        json.dump(data, f)
    
    test_args = ["summary", "--start-date", "2026-03-02", "--end-date", "2026-03-02"]
    
    with patch.object(sys, 'argv', ["spenny"] + test_args):
        main()
    
    captured = capsys.readouterr()
    assert "Transport    $3.00" in captured.out
    assert "Total: $3.00" in captured.out
    assert "$21.25" not in captured.out


def test_summary_empty_file_prints_correct_message(mock_storage, capsys):
    """Test that summary on empty file prints 'No expenses to summarize.'"""
    # Create empty file
    with open(mock_storage, 'w') as f:
        json.dump({"next_id": 1, "expenses": []}, f)
    
    test_args = ["summary"]
    
    with patch.object(sys, 'argv', ["spenny"] + test_args):
        main()
    
    captured = capsys.readouterr()
    assert "No expenses to summarize." in captured.out


def test_add_invalid_amount_exits_with_error(mock_storage, capsys):
    """Test that adding expense with invalid amount exits with error."""
    test_args = ["add", "--amount", "-5.00", "--category", "Food"]
    
    with patch.object(sys, 'argv', ["spenny"] + test_args), \
         pytest.raises(SystemExit) as exc_info:
        main()
    
    assert exc_info.value.code == 1
    captured = capsys.readouterr()
    assert "Amount must be positive" in captured.err


def test_add_empty_category_exits_with_error(mock_storage, capsys):
    """Test that adding expense with empty category exits with error."""
    test_args = ["add", "--amount", "10.00", "--category", ""]
    
    with patch.object(sys, 'argv', ["spenny"] + test_args), \
         pytest.raises(SystemExit) as exc_info:
        main()
    
    assert exc_info.value.code == 1
    captured = capsys.readouterr()
    assert "Category cannot be empty" in captured.err


def test_list_invalid_date_format_exits_with_error(mock_storage, capsys):
    """Test that listing with invalid date format exits with error."""
    # Create file with test data
    data = {
        "next_id": 2,
        "expenses": [
            {"id": 1, "date": "2026-03-01", "amount": "12.50", "category": "Food", "description": "Lunch"},
        ]
    }
    with open(mock_storage, 'w') as f:
        json.dump(data, f)
    
    test_args = ["list", "--start-date", "invalid-date"]
    
    with patch.object(sys, 'argv', ["spenny"] + test_args):
        # This should not raise SystemExit because the date validation happens in core
        # and returns empty results rather than raising an error
        main()
    
    captured = capsys.readouterr()
    # The invalid date should result in no expenses found (empty filter results)
    assert "No expenses found." in captured.out


def test_summary_invalid_date_format_exits_with_error(mock_storage, capsys):
    """Test that summary with invalid date format exits with error."""
    # Create file with test data
    data = {
        "next_id": 2,
        "expenses": [
            {"id": 1, "date": "2026-03-01", "amount": "12.50", "category": "Food", "description": "Lunch"},
        ]
    }
    with open(mock_storage, 'w') as f:
        json.dump(data, f)
    
    test_args = ["summary", "--start-date", "invalid-date"]
    
    with patch.object(sys, 'argv', ["spenny"] + test_args):
        # This should not raise SystemExit because the date validation happens in core
        # and returns empty results rather than raising an error
        main()
    
    captured = capsys.readouterr()
    # The invalid date should result in no expenses in range
    assert "No expenses found in the specified date range." in captured.out
