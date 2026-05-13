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

- `pyproject.toml`
- `src/spenny/__init__.py`
- `src/spenny/storage.py`
- `src/spenny/core.py`
- `src/spenny/cli.py`
</dependency_files>

<task>
## Tests: CLI integration

Write tests/test_cli.py using subprocess or unittest.mock to exercise the CLI end-to-end: spenny add creates an expense and prints confirmation, spenny list prints table, spenny list --category filters, spenny list --start-date/--end-date filters, spenny delete removes and confirms, spenny summary shows per-category and overall totals, spenny summary --start-date/--end-date filters, invalid inputs produce error messages and exit code 1, missing expenses.json is auto-created.

## Files to Produce

- `tests/test_cli.py`
</task>