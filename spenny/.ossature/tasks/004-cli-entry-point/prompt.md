<project_config>
Project: Spenny v0.1.0
Language: python
</project_config>

<project_brief>
Spenny is a command-line expense tracker that allows users to manage personal expenses through a simple interface. The system stores expense data in a local JSON file, enabling users to add new expenses, list existing entries with optional filters (e.g., by date or category), and generate a summary of spending grouped by category. The core module, `expense_tracker`, handles data storage, retrieval, and basic operations using Python’s standard library, including `json` for file operations and `argparse` for command-line argument parsing. The tool connects these components by reading user input, processing commands, and updating the JSON file accordingly. No external dependencies are required, ensuring lightweight and portable functionality.
</project_brief>

<spec_brief spec="EXPENSE_TRACKER">
This module implements a command-line expense tracker that stores expenses in a local JSON file. It handles adding, listing, deleting, and summarizing expenses, with optional filtering by category and date range. The module integrates with the Python standard library for JSON serialization, date handling, and CLI argument parsing, ensuring no external dependencies.
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

### Acceptance Criteria

- `spenny add` creates an expense and writes it to `expenses.json`
- `spenny list` displays all expenses in a formatted table
- `spenny list --category X` filters by category (case-sensitive)
- `spenny list --start-date 2026-03-01 --end-date 2026-03-02` filters by date range (inclusive)
- `spenny delete ID` removes an expense by ID
- `spenny summary` shows per-category totals and an overall total
- `spenny summary --start-date X --end-date Y` filters the summary by date range
- Missing `expenses.json` is created automatically on first write
- Invalid inputs produce clear error messages and exit code 1
- The JSON file is human-readable with pretty-printed formatting
</specification_context>

<architecture_context>
### CLI

@path: src/spenny/cli.py

Entry point. Parses arguments with `argparse`, calls core functions, formats output, handles errors. This is the only module that prints to stdout or calls `sys.exit`.

**Interface:**

```python
def main() -> None: ...
```

**Depends on:** Core, Storage

### Flow

```
```
CLI (argparse)
  ├── add    -> core.add_expense()    -> storage.save()
  ├── list   -> core.list_expenses()  -> print expense table
  ├── delete -> core.delete_expense() -> storage.save()
  └── summary -> core.summarize()     -> print summary
```
```
</architecture_context>

<dependency_files>
The following files from previous tasks are available. Use `grep_file` and `read_lines` to inspect the types, interfaces, and signatures you need.

- `pyproject.toml` (24 lines)
- `src/spenny/__init__.py` (2 lines)
- `src/spenny/storage.py` (34 lines)
- `src/spenny/core.py` (157 lines)
</dependency_files>

<task>
## CLI Entry Point

Implement src/spenny/cli.py with a main() function that wires argparse subcommands (add, list, delete, summary) to core functions. This is the only module that prints to stdout or calls sys.exit. The CLI supplies datetime.date.today().isoformat() as the date argument to add_expense() when --date is not provided. Catches ValueError from core functions and prints the error then exits with code 1. Formats the expense table and summary table with the column layout shown in the spec examples, displaying amounts as $X.XX.

## Files to Produce

- `src/spenny/cli.py`
</task>