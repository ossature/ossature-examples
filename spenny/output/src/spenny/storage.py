from decimal import Decimal
from typing import TypedDict
import json
import sys


class ExpenseRecord(TypedDict):
    id: int
    date: str          # ISO 8601 date (YYYY-MM-DD)
    amount: str         # decimal.Decimal serialized as string for JSON precision
    category: str
    description: str


class ExpenseData(TypedDict):
    next_id: int
    expenses: list[ExpenseRecord]


def load(path: str = "expenses.json") -> ExpenseData:
    try:
        with open(path, "r") as f:
            data = json.load(f)
            return data
    except FileNotFoundError:
        return {"next_id": 1, "expenses": []}
    except json.JSONDecodeError:
        print("Error: Corrupted JSON file", file=sys.stderr)
        sys.exit(1)


def save(data: ExpenseData, path: str = "expenses.json") -> None:
    with open(path, "w") as f:
        json.dump(data, f, indent=2)
