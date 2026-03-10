from decimal import Decimal
from typing import NamedTuple
from spenny.storage import ExpenseData, ExpenseRecord


def add_expense(
    data: ExpenseData,
    amount: Decimal,
    category: str,
    description: str = "",
    date: str | None = None,
) -> tuple[ExpenseData, ExpenseRecord]:
    """Add a new expense record to the data.
    
    Args:
        data: Current expense data
        amount: Expense amount (must be positive)
        category: Expense category (must not be empty)
        description: Optional expense description
        date: ISO 8601 date string (required)
        
    Returns:
        Tuple of updated ExpenseData and the created ExpenseRecord
        
    Raises:
        ValueError: If amount is not positive or category is empty
    """
    if amount <= 0:
        raise ValueError("Amount must be positive")
    
    if not category:
        raise ValueError("Category cannot be empty")
    
    if date is None:
        raise ValueError("Date is required")
    
    # Create new expense record
    expense_id = data["next_id"]
    new_expense = ExpenseRecord(
        id=expense_id,
        date=date,
        amount=str(amount),
        category=category,
        description=description
    )
    
    # Update data
    updated_data = ExpenseData(
        next_id=expense_id + 1,
        expenses=data["expenses"] + [new_expense]
    )
    
    return updated_data, new_expense


def list_expenses(
    data: ExpenseData,
    category: str | None = None,
    start_date: str | None = None,
    end_date: str | None = None,
) -> list[ExpenseRecord]:
    """List expenses with optional filtering.
    
    Args:
        data: Current expense data
        category: Optional category filter
        start_date: Optional start date filter (inclusive)
        end_date: Optional end date filter (inclusive)
        
    Returns:
        List of matching ExpenseRecord objects
    """
    expenses = data["expenses"]
    
    # Apply filters
    filtered = expenses
    if category:
        filtered = [e for e in filtered if e["category"] == category]
    
    if start_date:
        filtered = [e for e in filtered if e["date"] >= start_date]
    
    if end_date:
        filtered = [e for e in filtered if e["date"] <= end_date]
    
    return filtered


def delete_expense(
    data: ExpenseData,
    expense_id: int,
) -> ExpenseData:
    """Delete an expense by ID.
    
    Args:
        data: Current expense data
        expense_id: ID of expense to delete
        
    Returns:
        Updated ExpenseData with expense removed
        
    Raises:
        ValueError: If expense_id not found
    """
    expenses = data["expenses"]
    
    # Find and remove expense
    updated_expenses = [e for e in expenses if e["id"] != expense_id]
    
    if len(updated_expenses) == len(expenses):
        raise ValueError(f"Expense with ID {expense_id} not found")
    
    return ExpenseData(
        next_id=data["next_id"],
        expenses=updated_expenses
    )


class SummaryResult(NamedTuple):
    totals: dict[str, Decimal]
    has_expenses: bool


def summarize(
    data: ExpenseData,
    start_date: str | None = None,
    end_date: str | None = None,
) -> SummaryResult:
    """Summarize expenses by category.
    
    Args:
        data: Current expense data
        start_date: Optional start date filter (inclusive)
        end_date: Optional end date filter (inclusive)
        
    Returns:
        SummaryResult with totals by category and has_expenses flag
    """
    expenses = data["expenses"]
    has_expenses = len(expenses) > 0
    
    # Apply date filters
    filtered = expenses
    if start_date:
        filtered = [e for e in filtered if e["date"] >= start_date]
    
    if end_date:
        filtered = [e for e in filtered if e["date"] <= end_date]
    
    # Calculate totals by category
    totals = {}
    for expense in filtered:
        category = expense["category"]
        amount = Decimal(expense["amount"])
        totals[category] = totals.get(category, Decimal("0")) + amount
    
    return SummaryResult(totals=totals, has_expenses=has_expenses)