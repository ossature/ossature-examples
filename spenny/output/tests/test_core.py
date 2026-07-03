"""Tests for the core business logic of the Spenny expense tracker."""

from decimal import Decimal
import pytest
from spenny.core import add_expense, list_expenses, delete_expense, summarize
from spenny.storage import ExpenseData, ExpenseRecord


def test_add_expense_valid():
    """Test adding an expense with valid inputs."""
    data: ExpenseData = {"next_id": 1, "expenses": []}
    amount = Decimal("100.50")
    category = "Food"
    description = "Grocery shopping"
    date = "2023-10-01"

    updated_data, new_expense = add_expense(data, amount, category, description, date)

    assert updated_data["next_id"] == 2
    assert len(updated_data["expenses"]) == 1
    assert new_expense["id"] == 1
    assert new_expense["date"] == date
    assert new_expense["amount"] == str(amount)
    assert new_expense["category"] == category
    assert new_expense["description"] == description


def test_add_expense_zero_amount():
    """Test that adding an expense with zero amount raises ValueError."""
    data: ExpenseData = {"next_id": 1, "expenses": []}
    amount = Decimal("0")
    category = "Food"
    date = "2023-10-01"

    with pytest.raises(ValueError, match="Amount must be positive"):
        add_expense(data, amount, category, date=date)


def test_add_expense_negative_amount():
    """Test that adding an expense with negative amount raises ValueError."""
    data: ExpenseData = {"next_id": 1, "expenses": []}
    amount = Decimal("-50.00")
    category = "Food"
    date = "2023-10-01"

    with pytest.raises(ValueError, match="Amount must be positive"):
        add_expense(data, amount, category, date=date)


def test_add_expense_empty_category():
    """Test that adding an expense with empty category raises ValueError."""
    data: ExpenseData = {"next_id": 1, "expenses": []}
    amount = Decimal("100.50")
    category = ""
    date = "2023-10-01"

    with pytest.raises(ValueError, match="Category cannot be empty"):
        add_expense(data, amount, category, date=date)


def test_add_expense_none_date():
    """Test that adding an expense with None date raises ValueError."""
    data: ExpenseData = {"next_id": 1, "expenses": []}
    amount = Decimal("100.50")
    category = "Food"
    date = None

    with pytest.raises(ValueError, match="Date must be provided"):
        add_expense(data, amount, category, date=date)


def test_list_expenses_no_filter():
    """Test listing expenses without any filters."""
    data: ExpenseData = {
        "next_id": 3,
        "expenses": [
            {"id": 1, "date": "2023-10-01", "amount": "100.50", "category": "Food", "description": "Grocery"},
            {"id": 2, "date": "2023-10-02", "amount": "50.00", "category": "Transport", "description": "Bus fare"},
        ],
    }

    expenses = list_expenses(data)
    assert len(expenses) == 2


def test_list_expenses_category_filter():
    """Test listing expenses filtered by category."""
    data: ExpenseData = {
        "next_id": 3,
        "expenses": [
            {"id": 1, "date": "2023-10-01", "amount": "100.50", "category": "Food", "description": "Grocery"},
            {"id": 2, "date": "2023-10-02", "amount": "50.00", "category": "Transport", "description": "Bus fare"},
        ],
    }

    expenses = list_expenses(data, category="Food")
    assert len(expenses) == 1
    assert expenses[0]["category"] == "Food"


def test_list_expenses_start_date_filter():
    """Test listing expenses filtered by start date."""
    data: ExpenseData = {
        "next_id": 3,
        "expenses": [
            {"id": 1, "date": "2023-10-01", "amount": "100.50", "category": "Food", "description": "Grocery"},
            {"id": 2, "date": "2023-10-02", "amount": "50.00", "category": "Transport", "description": "Bus fare"},
        ],
    }

    expenses = list_expenses(data, start_date="2023-10-02")
    assert len(expenses) == 1
    assert expenses[0]["date"] == "2023-10-02"


def test_list_expenses_end_date_filter():
    """Test listing expenses filtered by end date."""
    data: ExpenseData = {
        "next_id": 3,
        "expenses": [
            {"id": 1, "date": "2023-10-01", "amount": "100.50", "category": "Food", "description": "Grocery"},
            {"id": 2, "date": "2023-10-02", "amount": "50.00", "category": "Transport", "description": "Bus fare"},
        ],
    }

    expenses = list_expenses(data, end_date="2023-10-01")
    assert len(expenses) == 1
    assert expenses[0]["date"] == "2023-10-01"


def test_list_expenses_combined_filters():
    """Test listing expenses with combined filters."""
    data: ExpenseData = {
        "next_id": 4,
        "expenses": [
            {"id": 1, "date": "2023-10-01", "amount": "100.50", "category": "Food", "description": "Grocery"},
            {"id": 2, "date": "2023-10-02", "amount": "50.00", "category": "Transport", "description": "Bus fare"},
            {"id": 3, "date": "2023-10-02", "amount": "30.00", "category": "Food", "description": "Lunch"},
        ],
    }

    expenses = list_expenses(data, category="Food", start_date="2023-10-02")
    assert len(expenses) == 1
    assert expenses[0]["id"] == 3


def test_delete_expense_success():
    """Test deleting an expense by ID."""
    data: ExpenseData = {
        "next_id": 3,
        "expenses": [
            {"id": 1, "date": "2023-10-01", "amount": "100.50", "category": "Food", "description": "Grocery"},
            {"id": 2, "date": "2023-10-02", "amount": "50.00", "category": "Transport", "description": "Bus fare"},
        ],
    }

    updated_data = delete_expense(data, 1)
    assert len(updated_data["expenses"]) == 1
    assert updated_data["expenses"][0]["id"] == 2


def test_delete_expense_missing_id():
    """Test that deleting a non-existent expense ID raises ValueError."""
    data: ExpenseData = {
        "next_id": 3,
        "expenses": [
            {"id": 1, "date": "2023-10-01", "amount": "100.50", "category": "Food", "description": "Grocery"},
        ],
    }

    with pytest.raises(ValueError, match="Expense ID not found"):
        delete_expense(data, 99)


def test_summarize_no_expenses():
    """Test summarizing with no expenses (has_expenses=False)."""
    data: ExpenseData = {"next_id": 1, "expenses": []}

    result = summarize(data)
    assert result.has_expenses is False
    assert result.totals == {}


def test_summarize_with_expenses_no_filter():
    """Test summarizing with expenses and no filter."""
    data: ExpenseData = {
        "next_id": 3,
        "expenses": [
            {"id": 1, "date": "2023-10-01", "amount": "100.50", "category": "Food", "description": "Grocery"},
            {"id": 2, "date": "2023-10-02", "amount": "50.00", "category": "Transport", "description": "Bus fare"},
        ],
    }

    result = summarize(data)
    assert result.has_expenses is True
    assert result.totals == {"Food": Decimal("100.50"), "Transport": Decimal("50.00")}


def test_summarize_date_range_no_match():
    """Test summarizing with date range filter that matches nothing (has_expenses=True, totals empty)."""
    data: ExpenseData = {
        "next_id": 3,
        "expenses": [
            {"id": 1, "date": "2023-10-01", "amount": "100.50", "category": "Food", "description": "Grocery"},
            {"id": 2, "date": "2023-10-02", "amount": "50.00", "category": "Transport", "description": "Bus fare"},
        ],
    }

    result = summarize(data, start_date="2023-11-01", end_date="2023-11-30")
    assert result.has_expenses is True
    assert result.totals == {}


def test_summarize_overall_total_computation():
    """Test that the overall total is computed correctly by summing all category totals."""
    data: ExpenseData = {
        "next_id": 4,
        "expenses": [
            {"id": 1, "date": "2023-10-01", "amount": "100.50", "category": "Food", "description": "Grocery"},
            {"id": 2, "date": "2023-10-02", "amount": "50.00", "category": "Transport", "description": "Bus fare"},
            {"id": 3, "date": "2023-10-03", "amount": "30.00", "category": "Food", "description": "Lunch"},
        ],
    }

    result = summarize(data)
    assert result.has_expenses is True
    assert result.totals == {"Food": Decimal("130.50"), "Transport": Decimal("50.00")}
    overall_total = sum(result.totals.values())
    assert overall_total == Decimal("180.50")
