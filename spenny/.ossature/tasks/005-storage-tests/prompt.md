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
### Data Persistence

All expenses are stored in a single JSON file (`expenses.json`) in the current working directory. The file is created automatically on first use. The file format is a JSON object with a `next_id` counter and an `expenses` array. Amounts are stored as JSON strings (e.g., `"12.50"`) to preserve `decimal.Decimal` precision and must be deserialized back to `Decimal` on load.

**Accepts:** Read/write operations from other commands

**Returns:** Loaded or saved expense data

**Errors:**

- Corrupted JSON file -> print error message and exit with code 1
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

- `src/spenny/storage.py` (34 lines)
</dependency_files>

<task>
## Storage Tests

Write tests/test_storage.py with unit tests for load() and save(). Covers: load returns empty default when file absent, save writes valid pretty-printed JSON, load round-trips saved data correctly, load exits with code 1 on corrupted JSON. Uses tmp_path fixture to avoid touching the real filesystem.

## Files to Produce

- `tests/test_storage.py`
</task>