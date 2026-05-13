# Project: Spenny v0.1.0 (python)

## Specification (SMD)

---
id: EXPENSE_TRACKER
status: draft
priority: high
depends: []
---

# Spenny — Command-Line Expense Tracker

## Overview

A command-line expense tracker that stores expenses in a local JSON file. Users can add expenses, list them with optional filters, and generate a spending summary grouped by category. The tool uses only the Python standard library.

## Goals

- Provide a fast, no-frills CLI for tracking personal expenses
- Persist data in a single human-readable JSON file
- Support filtering and summarizing expenses by category and date range
- Work with Python 3.14+ using only the standard library
- Use `uv` for project management and packaging

## Non-Goals

- GUI or web interface
- Multi-user or authentication
- Currency conversion
- Database backends
- Charts or visualizations

## Requirements

### Add an Expense

Record a new expense with an amount, category, and optional description. Each expense is assigned a unique auto-incrementing integer ID and timestamped with the current date (or an explicitly provided date).

**Accepts:** amount (positive number, as `decimal.Decimal` for accuracy and serialized as a string in JSON), category (non-empty string), description (optional string, defaults to empty), date (optional ISO 8601 date string, defaults to today — the CLI is responsible for supplying `datetime.date.today()` so that the core function remains pure)

**Returns:** The created expense record with its assigned ID, printed to stdout as a confirmation message

**Errors:**

- Amount is zero or negative -> print error message and exit with code 1
- Category is empty -> print error message and exit with code 1

### List Expenses

Display all recorded expenses in a formatted table. Optionally filter by category and/or date range.

**Accepts:** category (optional string filter), start_date (optional ISO date string), end_date (optional ISO date string)

**Returns:** A table printed to stdout with columns: ID, Date, Category, Amount, Description. If no expenses match, print "No expenses found."

**Errors:**

- Invalid date format -> print error message and exit with code 1

### Delete an Expense

Remove an expense by its ID.

**Accepts:** expense ID (integer, positional argument)

**Returns:** Confirmation message printed to stdout

**Errors:**

- ID not found -> print error message and exit with code 1

### Spending Summary

Show total spending grouped by category, with an overall total at the bottom. Optionally filter by date range.

**Accepts:** start_date (optional ISO date string), end_date (optional ISO date string)

**Returns:** A summary table printed to stdout with columns: Category, Total. Followed by a line showing the overall total across all categories. The overall total must be computed by summing all category totals. If no expenses exist, print "No expenses to summarize." If expenses exist but none match the supplied date range filter, print "No expenses found in the specified date range." The core `summarize()` function returns a `SummaryResult` dataclass (or named tuple) with two fields: `totals` (`dict[str, Decimal]`) containing per-category totals, and `has_expenses` (`bool`) indicating whether the input data contained any expenses at all. This allows the CLI to distinguish "no expenses at all" (`has_expenses` is `False`) from "no expenses in range" (`has_expenses` is `True` but `totals` is empty) without directly inspecting the raw `ExpenseData`.

**Errors:**

- Invalid date format -> print error message and exit with code 1

### Data Persistence

All expenses are stored in a single JSON file (`expenses.json`) in the current working directory. The file is created automatically on first use. The file format is a JSON object with a `next_id` counter and an `expenses` array. Amounts are stored as JSON strings (e.g., `"12.50"`) to preserve `decimal.Decimal` precision and must be deserialized back to `Decimal` on load.

**Accepts:** Read/write operations from other commands

**Returns:** Loaded or saved expense data

**Errors:**

- Corrupted JSON file -> print error message and exit with code 1

## Constraints

- No third-party dependencies. Standard library only
- The JSON file must be human-readable (pretty-printed with 2-space indent)
- Amounts are stored as `decimal.Decimal` and displayed with exactly 2 decimal places
- Dates are stored as ISO 8601 date strings (YYYY-MM-DD)
- The CLI uses Python's `argparse` with subcommands: `add`, `list`, `delete`, `summary`
- Exit code 0 on success, 1 on any error

## Examples

### Adding an Expense

**Input:**

```
spenny add --amount "12.50" --category "Food" --description "Lunch at cafe"
```

**Output:**

```
Expense added: #1 — $12.50 [Food] Lunch at cafe
```

### Listing Expenses

**Input:**

```
spenny list
```

**Output:**

```
ID   Date         Category     Amount   Description
──   ──────────   ────────     ──────   ───────────
1    2026-03-01   Food         $12.50   Lunch at cafe
2    2026-03-02   Transport    $3.00    Bus fare
3    2026-03-02   Food         $8.75    Coffee and pastry
```

### Listing with Filter

**Input:**

```
spenny list --category Food
```

**Output:**

```
ID   Date         Category   Amount   Description
──   ──────────   ────────   ──────   ───────────
1    2026-03-01   Food       $12.50   Lunch at cafe
3    2026-03-02   Food       $8.75    Coffee and pastry
```

### Spending Summary

**Input:**

```
spenny summary
```

**Output:**

```
Category     Total
────────     ─────
Food         $21.25
Transport    $3.00

Total: $24.25
```

### Deleting an Expense

**Input:**

```
spenny delete 2
```

**Output:**

```
Expense #2 deleted.
```

## Acceptance Criteria

- [ ] `spenny add` creates an expense and writes it to `expenses.json`
- [ ] `spenny list` displays all expenses in a formatted table
- [ ] `spenny list --category X` filters by category (case-sensitive)
- [ ] `spenny list --start-date 2026-03-01 --end-date 2026-03-02` filters by date range (inclusive)
- [ ] `spenny delete ID` removes an expense by ID
- [ ] `spenny summary` shows per-category totals and an overall total
- [ ] `spenny summary --start-date X --end-date Y` filters the summary by date range
- [ ] Missing `expenses.json` is created automatically on first write
- [ ] Invalid inputs produce clear error messages and exit code 1
- [ ] The JSON file is human-readable with pretty-printed formatting

## Notes



## Architecture Documents (AMD)

---
spec: EXPENSE_TRACKER
status: draft
---

# Architecture: Architecture: Expense Tracker

## Overview

Three Python modules: a storage layer for JSON persistence, a core module for business logic, and a CLI entry point that wires argparse subcommands to core functions.

## Components

### Storage

@path: src/spenny/storage.py

Handles reading and writing the `expenses.json` file. Provides a simple load/save interface over a typed dict structure.

**Interface:**

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

def load(path: str = "expenses.json") -> ExpenseData: ...
def save(data: ExpenseData, path: str = "expenses.json") -> None: ...
```

### Core

@path: src/spenny/core.py

Business logic for adding, listing, deleting, and summarizing expenses. Operates on the `ExpenseData` structure from storage. All functions are pure — they take data in and return results without side effects.

**Interface:**

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
) -> tuple[ExpenseData, ExpenseRecord]: ...

def list_expenses(
    data: ExpenseData,
    category: str | None = None,
    start_date: str | None = None,
    end_date: str | None = None,
) -> list[ExpenseRecord]: ...

def delete_expense(
    data: ExpenseData,
    expense_id: int,
) -> ExpenseData: ...

class SummaryResult(NamedTuple):
    totals: dict[str, Decimal]
    has_expenses: bool

def summarize(
    data: ExpenseData,
    start_date: str | None = None,
    end_date: str | None = None,
) -> SummaryResult: ...
```

**Depends on:** Storage

### CLI

@path: src/spenny/cli.py

Entry point. Parses arguments with `argparse`, calls core functions, formats output, handles errors. This is the only module that prints to stdout or calls `sys.exit`.

**Interface:**

```python
def main() -> None: ...
```

**Depends on:** Core, Storage

## Data Models

### expenses.json

```json
{
  "next_id": 4,
  "expenses": [
    {
      "id": 1,
      "date": "2026-03-01",
      "amount": "12.50",
      "category": "Food",
      "description": "Lunch at cafe"
    }
  ]
}
```

## Flow

```
```
CLI (argparse)
  ├── add    -> core.add_expense()    -> storage.save()
  ├── list   -> core.list_expenses()  -> print expense table
  ├── delete -> core.delete_expense() -> storage.save()
  └── summary -> core.summarize()     -> print summary
```
```

## Dependencies

- Python 3.14+ standard library only (json, argparse, datetime, sys): system functionality
- uv: project management, packaging, and running the CLI

## Notes



## Audit Findings (avoid these issues in planning)

- [WARNING] Requirements > Add an Expense, L35: The spec says the core function 'remains pure' and date defaults to today, with the CLI responsible for supplying `datetime.date.today()`. However, the AMD interface (L60) shows `date: str | None = None` on `add_expense`, implying `None` is a valid input to the core function. If `None` is passed, the core function must either default the date itself (breaking purity) or raise an error. The spec should clarify whether the CLI must always pass an explicit date string or whether the core function handles the `None` case.