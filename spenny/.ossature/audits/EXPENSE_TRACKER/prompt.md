# Specification (SMD)

---
L1: ---
L2: id: EXPENSE_TRACKER
L3: status: draft
L4: priority: high
L5: depends: []
L6: ---
L7: # Spenny — Command-Line Expense Tracker
L8: 
L9: ## Overview
L10: 
L11: A command-line expense tracker that stores expenses in a local JSON file. Users can add expenses, list them with optional filters, and generate a spending summary grouped by category. The tool uses only the Python standard library.
L12: 
L13: ## Goals
L14: 
L15: - Provide a fast, no-frills CLI for tracking personal expenses
L16: - Persist data in a single human-readable JSON file
L17: - Support filtering and summarizing expenses by category and date range
L18: - Work with Python 3.14+ using only the standard library
L19: - Use `uv` for project management and packaging
L20: 
L21: ## Non-Goals
L22: 
L23: - GUI or web interface
L24: - Multi-user or authentication
L25: - Currency conversion
L26: - Database backends
L27: - Charts or visualizations
L28: 
L29: ## Requirements
L30: 
L31: ### Add an Expense
L32: 
L33: Record a new expense with an amount, category, and optional description. Each expense is assigned a unique auto-incrementing integer ID and timestamped with the current date (or an explicitly provided date).
L34: 
L35: **Accepts:** amount (positive number, as `decimal.Decimal` for accuracy and serialized as a string in JSON), category (non-empty string), description (optional string, defaults to empty), date (optional ISO 8601 date string, defaults to today — the CLI is responsible for supplying `datetime.date.today()` so that the core function remains pure)
L36: 
L37: **Returns:** The created expense record with its assigned ID, printed to stdout as a confirmation message
L38: 
L39: **Errors:**
L40: 
L41: - Amount is zero or negative -> print error message and exit with code 1
L42: - Category is empty -> print error message and exit with code 1
L43: 
L44: ### List Expenses
L45: 
L46: Display all recorded expenses in a formatted table. Optionally filter by category and/or date range.
L47: 
L48: **Accepts:** category (optional string filter), start_date (optional ISO date string), end_date (optional ISO date string)
L49: 
L50: **Returns:** A table printed to stdout with columns: ID, Date, Category, Amount, Description. If no expenses match, print "No expenses found."
L51: 
L52: **Errors:**
L53: 
L54: - Invalid date format → print error message and exit with code 1
L55: 
L56: ### Delete an Expense
L57: 
L58: Remove an expense by its ID.
L59: 
L60: **Accepts:** expense ID (integer, positional argument)
L61: 
L62: **Returns:** Confirmation message printed to stdout
L63: 
L64: **Behavior:** The CLI retains the ID from the parsed argument and uses it in the confirmation message. The core function `delete_expense` returns the updated `ExpenseData` only.
L65: 
L66: **Errors:**
L67: 
L68: - ID not found → print error message and exit with code 1
L69: 
L70: ### Spending Summary
L71: 
L72: Show total spending grouped by category, with an overall total at the bottom. Optionally filter by date range.
L73: 
L74: **Accepts:** start_date (optional ISO date string), end_date (optional ISO date string)
L75: 
L76: **Returns:** A summary table printed to stdout with columns: Category, Total. Followed by a line showing the overall total across all categories. The overall total must be computed by summing all category totals. If no expenses exist, print "No expenses to summarize." If expenses exist but none match the supplied date range filter, print "No expenses found in the specified date range." The core `summarize()` function returns a `SummaryResult` dataclass (or named tuple) with two fields: `totals` (`dict[str, Decimal]`) containing per-category totals, and `has_expenses` (`bool`) indicating whether the input data contained any expenses at all. This allows the CLI to distinguish "no expenses at all" (`has_expenses` is `False`) from "no expenses in range" (`has_expenses` is `True` but `totals` is empty) without directly inspecting the raw `ExpenseData`.
L77: 
L78: **Errors:**
L79: 
L80: - Invalid date format → print error message and exit with code 1
L81: 
L82: ### Data Persistence
L83: 
L84: All expenses are stored in a single JSON file (`expenses.json`) in the current working directory. The file is created automatically on first use. The file format is a JSON object with a `next_id` counter and an `expenses` array. Amounts are stored as JSON strings (e.g., `"12.50"`) to preserve `decimal.Decimal` precision and must be deserialized back to `Decimal` on load.
L85: 
L86: **Accepts:** Read/write operations from other commands
L87: 
L88: **Returns:** Loaded or saved expense data
L89: 
L90: **Errors:**
L91: 
L92: - Corrupted JSON file → print error message and exit with code 1
L93: 
L94: ## Constraints
L95: 
L96: - No third-party dependencies. Standard library only
L97: - The JSON file must be human-readable (pretty-printed with 2-space indent)
L98: - Amounts are stored as `decimal.Decimal` and displayed with exactly 2 decimal places
L99: - Dates are stored as ISO 8601 date strings (YYYY-MM-DD)
L100: - The CLI uses Python's `argparse` with subcommands: `add`, `list`, `delete`, `summary`
L101: - Exit code 0 on success, 1 on any error
L102: 
L103: ## Examples
L104: 
L105: ### Adding an Expense
L106: 
L107: **Input:**
L108: 
L109: ```
L110: spenny add --amount "12.50" --category "Food" --description "Lunch at cafe"
L111: ```
L112: 
L113: **Output:**
L114: 
L115: ```
L116: Expense added: #1 — $12.50 [Food] Lunch at cafe
L117: ```
L118: 
L119: ### Listing Expenses
L120: 
L121: **Input:**
L122: 
L123: ```
L124: spenny list
L125: ```
L126: 
L127: **Output:**
L128: 
L129: ```
L130: ID   Date         Category     Amount   Description
L131: ──   ──────────   ────────     ──────   ───────────
L132: 1    2026-03-01   Food         $12.50   Lunch at cafe
L133: 2    2026-03-02   Transport    $3.00    Bus fare
L134: 3    2026-03-02   Food         $8.75    Coffee and pastry
L135: ```
L136: 
L137: ### Listing with Filter
L138: 
L139: **Input:**
L140: 
L141: ```
L142: spenny list --category Food
L143: ```
L144: 
L145: **Output:**
L146: 
L147: ```
L148: ID   Date         Category   Amount   Description
L149: ──   ──────────   ────────   ──────   ───────────
L150: 1    2026-03-01   Food       $12.50   Lunch at cafe
L151: 3    2026-03-02   Food       $8.75    Coffee and pastry
L152: ```
L153: 
L154: ### Spending Summary
L155: 
L156: **Input:**
L157: 
L158: ```
L159: spenny summary
L160: ```
L161: 
L162: **Output:**
L163: 
L164: ```
L165: Category     Total
L166: ────────     ─────
L167: Food         $21.25
L168: Transport    $3.00
L169: 
L170: Total: $24.25
L171: ```
L172: 
L173: ### Deleting an Expense
L174: 
L175: **Input:**
L176: 
L177: ```
L178: spenny delete 2
L179: ```
L180: 
L181: **Output:**
L182: 
L183: ```
L184: Expense #2 deleted.
L185: ```
L186: 
L187: ## Acceptance Criteria
L188: 
L189: - `spenny add` creates an expense and writes it to `expenses.json`
L190: - `spenny list` displays all expenses in a formatted table
L191: - `spenny list --category X` filters by category (case-sensitive)
L192: - `spenny list --start-date 2026-03-01 --end-date 2026-03-02` filters by date range (inclusive)
L193: - `spenny delete ID` removes an expense by ID
L194: - `spenny summary` shows per-category totals and an overall total
L195: - `spenny summary --start-date X --end-date Y` filters the summary by date range
L196: - Missing `expenses.json` is created automatically on first write
L197: - Invalid inputs produce clear error messages and exit code 1
L198: - The JSON file is human-readable with pretty-printed formatting
---

# Architecture Documents (AMD)

---
L1: ---
L2: spec: EXPENSE_TRACKER
L3: status: draft
L4: ---
L5: # Architecture: Expense Tracker
L6: 
L7: ## Overview
L8: 
L9: Three Python modules: a storage layer for JSON persistence, a core module for business logic, and a CLI entry point that wires argparse subcommands to core functions.
L10: 
L11: ## Components
L12: 
L13: ### Storage
L14: 
L15: @path: src/spenny/storage.py
L16: 
L17: Handles reading and writing the `expenses.json` file. Provides a simple load/save interface over a typed dict structure.
L18: 
L19: **Interface:**
L20: 
L21: ```python
L22: from decimal import Decimal
L23: from typing import TypedDict
L24: 
L25: class ExpenseRecord(TypedDict):
L26:     id: int
L27:     date: str          # ISO 8601 date (YYYY-MM-DD)
L28:     amount: str         # decimal.Decimal serialized as string for JSON precision
L29:     category: str
L30:     description: str
L31: 
L32: class ExpenseData(TypedDict):
L33:     next_id: int
L34:     expenses: list[ExpenseRecord]
L35: 
L36: def load(path: str = "expenses.json") -> ExpenseData: ...
L37: def save(data: ExpenseData, path: str = "expenses.json") -> None: ...
L38: ```
L39: 
L40: **Depends on:** None
L41: 
L42: ### Core
L43: 
L44: @path: src/spenny/core.py
L45: 
L46: Business logic for adding, listing, deleting, and summarizing expenses. Operates on the `ExpenseData` structure from storage. All functions are pure — they take data in and return results without side effects.
L47: 
L48: **Interface:**
L49: 
L50: ```python
L51: from decimal import Decimal
L52: from typing import NamedTuple
L53: from spenny.storage import ExpenseData, ExpenseRecord
L54: 
L55: def add_expense(
L56:     data: ExpenseData,
L57:     amount: Decimal,
L58:     category: str,
L59:     description: str = "",
L60:     date: str | None = None,
L61: ) -> tuple[ExpenseData, ExpenseRecord]: ...
L62: 
L63: def list_expenses(
L64:     data: ExpenseData,
L65:     category: str | None = None,
L66:     start_date: str | None = None,
L67:     end_date: str | None = None,
L68: ) -> list[ExpenseRecord]: ...
L69: 
L70: def delete_expense(
L71:     data: ExpenseData,
L72:     expense_id: int,
L73: ) -> ExpenseData: ...
L74: 
L75: class SummaryResult(NamedTuple):
L76:     totals: dict[str, Decimal]
L77:     has_expenses: bool
L78: 
L79: def summarize(
L80:     data: ExpenseData,
L81:     start_date: str | None = None,
L82:     end_date: str | None = None,
L83: ) -> SummaryResult: ...
L84: ```
L85: 
L86: **Depends on:** Storage
L87: 
L88: ### CLI
L89: 
L90: @path: src/spenny/cli.py
L91: 
L92: Entry point. Parses arguments with `argparse`, calls core functions, formats output, handles errors. This is the only module that prints to stdout or calls `sys.exit`.
L93: 
L94: **Interface:**
L95: 
L96: ```python
L97: def main() -> None: ...
L98: ```
L99: 
L100: **Depends on:** Core, Storage
L101: 
L102: ## Data Models
L103: 
L104: ### expenses.json
L105: 
L106: ```json
L107: {
L108:   "next_id": 4,
L109:   "expenses": [
L110:     {
L111:       "id": 1,
L112:       "date": "2026-03-01",
L113:       "amount": "12.50",
L114:       "category": "Food",
L115:       "description": "Lunch at cafe"
L116:     }
L117:   ]
L118: }
L119: ```
L120: 
L121: ## Flow
L122: 
L123: ```
L124: CLI (argparse)
L125:   ├── add    -> core.add_expense()    -> storage.save()
L126:   ├── list   -> core.list_expenses()  -> print expense table
L127:   ├── delete -> core.delete_expense() -> storage.save()
L128:   └── summary -> core.summarize()     -> print summary
L129: ```
L130: 
L131: ## Dependencies
L132: 
L133: - Python 3.14+ standard library only (json, argparse, datetime, sys): system functionality
L134: - uv: project management, packaging, and running the CLI