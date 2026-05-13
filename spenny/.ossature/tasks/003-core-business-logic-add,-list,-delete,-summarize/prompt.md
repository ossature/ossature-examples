<project_config>
Project: Spenny v0.1.0
Language: python
</project_config>

<project_brief>
Spenny is a command-line expense tracker that allows users to manage expenses via a local JSON file. The system consists of a single module, `EXPENSE_TRACKER`, which handles adding expenses, listing them with optional filters (e.g., by date or category), and generating a spending summary grouped by category. The module relies solely on Python’s standard library, using `json` for data storage and `argparse` for command-line argument parsing. User inputs are processed directly, with expenses appended to the JSON file, while queries filter and aggregate data in-memory before displaying results. The design ensures simplicity and portability without external dependencies.
</project_brief>

<spec_brief spec="EXPENSE_TRACKER">
The Spenny module is a lightweight, command-line expense tracker that manages expense records in a local JSON file. It provides core functionality for adding, listing (with optional filtering), and summarizing expenses by category, all while relying solely on Python's standard library. This module operates independently, requiring no external dependencies, and serves as a self-contained solution for basic expense tracking.
</spec_brief>

<specification_context>
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

### Constraints

- No third-party dependencies. Standard library only
- The JSON file must be human-readable (pretty-printed with 2-space indent)
- Amounts are stored as `decimal.Decimal` and displayed with exactly 2 decimal places
- Dates are stored as ISO 8601 date strings (YYYY-MM-DD)
- The CLI uses Python's `argparse` with subcommands: `add`, `list`, `delete`, `summary`
- Exit code 0 on success, 1 on any error
</specification_context>

<architecture_context>
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
</architecture_context>

<dependency_files>
The following files from previous tasks are available. Use `grep_file` and `read_lines` to inspect the types, interfaces, and signatures you need.

- `pyproject.toml`
- `src/spenny/__init__.py`
- `src/spenny/storage.py`
</dependency_files>

<task>
## Core business logic: add, list, delete, summarize

Implement src/spenny/core.py with pure functions: add_expense(), list_expenses(), delete_expense(), and summarize(). Defines SummaryResult NamedTuple. Per the audit finding, the CLI must always supply an explicit date string; if date is None the core raises ValueError to stay pure. Amounts use decimal.Decimal throughout. Filtering is inclusive on date ranges.

## Files to Produce

- `src/spenny/core.py`
</task>