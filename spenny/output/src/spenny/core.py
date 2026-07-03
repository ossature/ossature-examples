from decimal import Decimal
from typing import NamedTuple
from datetime import date
from spenny.storage import ExpenseData, ExpenseRecord


class SummaryResult(NamedTuple):
    totals: dict[str, Decimal]
    has_expenses: bool


def add_expense(
    data: ExpenseData,
    amount: Decimal,
    category: str,
    description: str = "",
    date: str | None = None,
) -> tuple[ExpenseData, ExpenseRecord]:
    if amount <= 0:
        raise ValueError("Amount must be positive")
    if not category:
        raise ValueError("Category cannot be empty")
    if date is None:
        raise ValueError("Date must be provided")

    expense_id = data["next_id"]
    new_expense: ExpenseRecord = {
        "id": expense_id,
        "date": date,
        "amount": str(amount),
        "category": category,
        "description": description,
    }

    updated_expenses = data["expenses"] + [new_expense]
    updated_data: ExpenseData = {
        "next_id": expense_id + 1,
        "expenses": updated_expenses,
    }

    return updated_data, new_expense


def list_expenses(
    data: ExpenseData,
    category: str | None = None,
    start_date: str | None = None,
    end_date: str | None = None,
) -> list[ExpenseRecord]:
    expenses = data["expenses"]

    filtered_expenses = expenses
    if category:
        filtered_expenses = [e for e in filtered_expenses if e["category"] == category]
    if start_date:
        filtered_expenses = [e for e in filtered_expenses if e["date"] >= start_date]
    if end_date:
        filtered_expenses = [e for e in filtered_expenses if e["date"] <= end_date]

    return filtered_expenses


def delete_expense(
    data: ExpenseData,
    expense_id: int,
) -> ExpenseData:
    expenses = data["expenses"]
    updated_expenses = [e for e in expenses if e["id"] != expense_id]

    if len(updated_expenses) == len(expenses):
        raise ValueError("Expense ID not found")

    updated_data: ExpenseData = {
        "next_id": data["next_id"],
        "expenses": updated_expenses,
    }

    return updated_data


def summarize(
    data: ExpenseData,
    start_date: str | None = None,
    end_date: str | None = None,
) -> SummaryResult:
    expenses = data["expenses"]
    has_expenses = len(expenses) > 0

    filtered_expenses = expenses
    if start_date:
        filtered_expenses = [e for e in filtered_expenses if e["date"] >= start_date]
    if end_date:
        filtered_expenses = [e for e in filtered_expenses if e["date"] <= end_date]

    totals: dict[str, Decimal] = {}
    for expense in filtered_expenses:
        category = expense["category"]
        amount = Decimal(expense["amount"])
        totals[category] = totals.get(category, Decimal("0")) + amount

    return SummaryResult(totals, has_expenses)
