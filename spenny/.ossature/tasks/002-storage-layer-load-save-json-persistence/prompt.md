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
### Data Persistence

All expenses are stored in a single JSON file (`expenses.json`) in the current working directory. The file is created automatically on first use. The file format is a JSON object with a `next_id` counter and an `expenses` array. Amounts are stored as JSON strings (e.g., `"12.50"`) to preserve `decimal.Decimal` precision and must be deserialized back to `Decimal` on load.

**Accepts:** Read/write operations from other commands

**Returns:** Loaded or saved expense data

**Errors:**

- Corrupted JSON file -> print error message and exit with code 1

### Constraints

- No third-party dependencies. Standard library only
- The JSON file must be human-readable (pretty-printed with 2-space indent)
- Amounts are stored as `decimal.Decimal` and displayed with exactly 2 decimal places
- Dates are stored as ISO 8601 date strings (YYYY-MM-DD)
- The CLI uses Python's `argparse` with subcommands: `add`, `list`, `delete`, `summary`
- Exit code 0 on success, 1 on any error
</specification_context>

<architecture_context>
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
</architecture_context>

<dependency_files>
The following files from previous tasks are available. Use `grep_file` and `read_lines` to inspect the types, interfaces, and signatures you need.

- `pyproject.toml`
- `src/spenny/__init__.py`
</dependency_files>

<task>
## Storage layer: load/save JSON persistence

Implement src/spenny/storage.py with the ExpenseRecord and ExpenseData TypedDicts, plus load() and save() functions. load() creates an empty store if the file is missing, exits with code 1 on corrupted JSON. save() pretty-prints with 2-space indent. Amounts are stored/loaded as strings.

## Files to Produce

- `src/spenny/storage.py`
</task>