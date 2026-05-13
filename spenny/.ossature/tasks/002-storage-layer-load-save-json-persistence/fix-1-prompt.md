<error_output>
```
$ python -m py_compile src/spenny/storage.py
$ python -c "from spenny.storage import load, save, ExpenseData, ExpenseRecord"
Traceback (most recent call last):
  File "<string>", line 1, in <module>
    from spenny.storage import load, save, ExpenseData, ExpenseRecord
ModuleNotFoundError: No module named 'spenny'
```
</error_output>

<verify_command>
python -m py_compile src/spenny/storage.py && python -c "from spenny.storage import load, save, ExpenseData, ExpenseRecord"
</verify_command>

<current_file path="src/spenny/storage.py">
```
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

```
</current_file>

<task>
**Storage layer: load/save JSON persistence**: Implement src/spenny/storage.py with the ExpenseRecord and ExpenseData TypedDicts, plus load() and save() functions. load() creates an empty store if the file is missing, exits with code 1 on corrupted JSON. save() pretty-prints with 2-space indent. Amounts are stored/loaded as strings.
</task>