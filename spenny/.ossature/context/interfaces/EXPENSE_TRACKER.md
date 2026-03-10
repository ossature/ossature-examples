# Interface: EXPENSE_TRACKER

@source: build

# Public Interface for EXPENSE_TRACKER

## src/spenny/storage.py

```python
from decimal import Decimal
from typing import TypedDict

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
    ...

def save(data: ExpenseData, path: str = "expenses.json") -> None:
    ...
```

## src/spenny/core.py

```python
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
    ...

def list_expenses(
    data: ExpenseData,
    category: str | None = None,
    start_date: str | None = None,
    end_date: str | None = None,
) -> list[ExpenseRecord]:
    ...

def delete_expense(
    data: ExpenseData,
    expense_id: int,
) -> ExpenseData:
    ...

class SummaryResult(NamedTuple):
    totals: dict[str, Decimal]
    has_expenses: bool

def summarize(
    data: ExpenseData,
    start_date: str | None = None,
    end_date: str | None = None,
) -> SummaryResult:
    ...
```

## src/spenny/cli.py

```python
import argparse
import sys
from decimal import Decimal
from datetime import date

from spenny.core import (
    add_expense,
    list_expenses,
    delete_expense,
    summarize,
)
from spenny.storage import load, save

def format_amount(amount_str: str) -> str:
    ...

def print_expense_table(expenses: list[dict]) -> None:
    ...

def print_summary(summary_result):
    ...

def main() -> None:
    ...
```