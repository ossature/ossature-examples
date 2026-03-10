"""Unit tests for the core expense tracker functions."""

from decimal import Decimal
import pytest
from spenny.core import add_expense, list_expenses, delete_expense, summarize, SummaryResult
from spenny.storage import ExpenseData, ExpenseRecord


class TestAddExpense:
    """Tests for the add_expense function."""

    def test_add_expense_increments_id_and_appends(self):
        """Test that add_expense increments next_id and appends the new record."""
        data: ExpenseData = {"next_id": 1, "expenses": []}
        
        new_data, record = add_expense(
            data=data,
            amount=Decimal("10.50"),
            category="Food",
            description="Lunch",
            date="2024-01-01"
        )
        
        assert new_data["next_id"] == 2
        assert len(new_data["expenses"]) == 1
        assert record["id"] == 1
        assert record["date"] == "2024-01-01"
        assert record["amount"] == "10.50"
        assert record["category"] == "Food"
        assert record["description"] == "Lunch"

    def test_add_expense_without_description(self):
        """Test that add_expense works with empty description."""
        data: ExpenseData = {"next_id": 1, "expenses": []}
        
        new_data, record = add_expense(
            data=data,
            amount=Decimal("20.00"),
            category="Transport",
            date="2024-01-02"
        )
        
        assert record["description"] == ""

    def test_add_expense_negative_amount_raises_error(self):
        """Test that add_expense raises ValueError for negative amount."""
        data: ExpenseData = {"next_id": 1, "expenses": []}
        
        with pytest.raises(ValueError, match="Amount must be positive"):
            add_expense(
                data=data,
                amount=Decimal("-10.00"),
                category="Food",
                date="2024-01-01"
            )

    def test_add_expense_zero_amount_raises_error(self):
        """Test that add_expense raises ValueError for zero amount."""
        data: ExpenseData = {"next_id": 1, "expenses": []}
        
        with pytest.raises(ValueError, match="Amount must be positive"):
            add_expense(
                data=data,
                amount=Decimal("0"),
                category="Food",
                date="2024-01-01"
            )

    def test_add_expense_empty_category_raises_error(self):
        """Test that add_expense raises ValueError for empty category."""
        data: ExpenseData = {"next_id": 1, "expenses": []}
        
        with pytest.raises(ValueError, match="Category cannot be empty"):
            add_expense(
                data=data,
                amount=Decimal("10.00"),
                category="",
                date="2024-01-01"
            )

    def test_add_expense_missing_date_raises_error(self):
        """Test that add_expense raises ValueError when date is None."""
        data: ExpenseData = {"next_id": 1, "expenses": []}
        
        with pytest.raises(ValueError, match="Date is required"):
            add_expense(
                data=data,
                amount=Decimal("10.00"),
                category="Food",
                date=None
            )


class TestListExpenses:
    """Tests for the list_expenses function."""

    def test_list_all_expenses(self):
        """Test listing all expenses without filters."""
        data: ExpenseData = {
            "next_id": 3,
            "expenses": [
                {"id": 1, "date": "2024-01-01", "amount": "10.00", "category": "Food", "description": "Lunch"},
                {"id": 2, "date": "2024-01-02", "amount": "20.00", "category": "Transport", "description": "Bus"},
            ]
        }
        
        result = list_expenses(data)
        assert len(result) == 2
        assert result[0]["id"] == 1
        assert result[1]["id"] == 2

    def test_list_expenses_by_category(self):
        """Test filtering expenses by category."""
        data: ExpenseData = {
            "next_id": 4,
            "expenses": [
                {"id": 1, "date": "2024-01-01", "amount": "10.00", "category": "Food", "description": "Lunch"},
                {"id": 2, "date": "2024-01-02", "amount": "20.00", "category": "Transport", "description": "Bus"},
                {"id": 3, "date": "2024-01-03", "amount": "15.00", "category": "Food", "description": "Dinner"},
            ]
        }
        
        result = list_expenses(data, category="Food")
        assert len(result) == 2
        assert all(e["category"] == "Food" for e in result)

    def test_list_expenses_by_date_range(self):
        """Test filtering expenses by date range."""
        data: ExpenseData = {
            "next_id": 4,
            "expenses": [
                {"id": 1, "date": "2024-01-01", "amount": "10.00", "category": "Food", "description": "Lunch"},
                {"id": 2, "date": "2024-01-02", "amount": "20.00", "category": "Transport", "description": "Bus"},
                {"id": 3, "date": "2024-01-03", "amount": "15.00", "category": "Food", "description": "Dinner"},
            ]
        }
        
        result = list_expenses(data, start_date="2024-01-02", end_date="2024-01-02")
        assert len(result) == 1
        assert result[0]["id"] == 2

    def test_list_expenses_no_matches(self):
        """Test that empty list is returned when no expenses match filters."""
        data: ExpenseData = {
            "next_id": 2,
            "expenses": [
                {"id": 1, "date": "2024-01-01", "amount": "10.00", "category": "Food", "description": "Lunch"},
            ]
        }
        
        result = list_expenses(data, category="Transport")
        assert len(result) == 0


class TestDeleteExpense:
    """Tests for the delete_expense function."""

    def test_delete_expense_by_id(self):
        """Test deleting an expense by ID."""
        data: ExpenseData = {
            "next_id": 3,
            "expenses": [
                {"id": 1, "date": "2024-01-01", "amount": "10.00", "category": "Food", "description": "Lunch"},
                {"id": 2, "date": "2024-01-02", "amount": "20.00", "category": "Transport", "description": "Bus"},
            ]
        }
        
        new_data = delete_expense(data, expense_id=1)
        assert len(new_data["expenses"]) == 1
        assert new_data["expenses"][0]["id"] == 2
        assert new_data["next_id"] == 3  # next_id should not change

    def test_delete_nonexistent_expense_raises_error(self):
        """Test that deleting a non-existent expense raises ValueError."""
        data: ExpenseData = {
            "next_id": 2,
            "expenses": [
                {"id": 1, "date": "2024-01-01", "amount": "10.00", "category": "Food", "description": "Lunch"},
            ]
        }
        
        with pytest.raises(ValueError, match="Expense with ID 999 not found"):
            delete_expense(data, expense_id=999)


class TestSummarize:
    """Tests for the summarize function."""

    def test_summarize_with_expenses(self):
        """Test summarizing expenses by category."""
        data: ExpenseData = {
            "next_id": 4,
            "expenses": [
                {"id": 1, "date": "2024-01-01", "amount": "10.00", "category": "Food", "description": "Lunch"},
                {"id": 2, "date": "2024-01-02", "amount": "20.00", "category": "Transport", "description": "Bus"},
                {"id": 3, "date": "2024-01-03", "amount": "15.00", "category": "Food", "description": "Dinner"},
            ]
        }
        
        result = summarize(data)
        assert result.has_expenses is True
        assert result.totals["Food"] == Decimal("25.00")
        assert result.totals["Transport"] == Decimal("20.00")

    def test_summarize_no_expenses(self):
        """Test summarizing when there are no expenses."""
        data: ExpenseData = {"next_id": 1, "expenses": []}
        
        result = summarize(data)
        assert result.has_expenses is False
        assert result.totals == {}

    def test_summarize_with_date_range(self):
        """Test summarizing with date range filter."""
        data: ExpenseData = {
            "next_id": 4,
            "expenses": [
                {"id": 1, "date": "2024-01-01", "amount": "10.00", "category": "Food", "description": "Lunch"},
                {"id": 2, "date": "2024-01-02", "amount": "20.00", "category": "Transport", "description": "Bus"},
                {"id": 3, "date": "2024-01-03", "amount": "15.00", "category": "Food", "description": "Dinner"},
            ]
        }
        
        result = summarize(data, start_date="2024-01-02", end_date="2024-01-02")
        assert result.has_expenses is True  # Original data has expenses
        assert result.totals == {"Transport": Decimal("20.00")}

    def test_summarize_date_range_no_matches(self):
        """Test summarizing with date range that matches no expenses."""
        data: ExpenseData = {
            "next_id": 2,
            "expenses": [
                {"id": 1, "date": "2024-01-01", "amount": "10.00", "category": "Food", "description": "Lunch"},
            ]
        }
        
        result = summarize(data, start_date="2024-02-01", end_date="2024-02-28")
        assert result.has_expenses is True  # Original data has expenses
        assert result.totals == {}  # But none in this date range

    def test_summarize_multiple_categories_same_expense(self):
        """Test that expenses are correctly grouped by category."""
        data: ExpenseData = {
            "next_id": 5,
            "expenses": [
                {"id": 1, "date": "2024-01-01", "amount": "10.00", "category": "Food", "description": "Lunch"},
                {"id": 2, "date": "2024-01-02", "amount": "20.00", "category": "Transport", "description": "Bus"},
                {"id": 3, "date": "2024-01-03", "amount": "15.00", "category": "Food", "description": "Dinner"},
                {"id": 4, "date": "2024-01-04", "amount": "5.00", "category": "Food", "description": "Snack"},
            ]
        }
        
        result = summarize(data)
        assert result.totals["Food"] == Decimal("30.00")
        assert result.totals["Transport"] == Decimal("20.00")
        assert len(result.totals) == 2
