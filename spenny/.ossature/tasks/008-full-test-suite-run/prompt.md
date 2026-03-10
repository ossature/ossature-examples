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
### Overview

Three Python modules: a storage layer for JSON persistence, a core module for business logic, and a CLI entry point that wires argparse subcommands to core functions.

### Dependencies

- Python 3.14+ standard library only (json, argparse, datetime, sys): system functionality
- uv: project management, packaging, and running the CLI
</architecture_context>

<dependency_files>
The following files from previous tasks are available. Use `grep_file` and `read_lines` to inspect the types, interfaces, and signatures you need.

- `tests/test_storage.py` (85 lines)
- `tests/test_core.py` (256 lines)
- `tests/test_cli.py` (338 lines)
</dependency_files>

<task>
## Full Test Suite Run

Add a tests/__init__.py marker (if needed) and run the complete test suite to confirm all modules integrate correctly and all acceptance criteria pass. Also verify the installed CLI entry point resolves correctly.

## Files to Produce

- `tests/__init__.py`
</task>