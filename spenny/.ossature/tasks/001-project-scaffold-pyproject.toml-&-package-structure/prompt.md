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
### Goals

- Provide a fast, no-frills CLI for tracking personal expenses
- Persist data in a single human-readable JSON file
- Support filtering and summarizing expenses by category and date range
- Work with Python 3.14+ using only the standard library
- Use `uv` for project management and packaging

### Constraints

- No third-party dependencies. Standard library only
- The JSON file must be human-readable (pretty-printed with 2-space indent)
- Amounts are stored as `decimal.Decimal` and displayed with exactly 2 decimal places
- Dates are stored as ISO 8601 date strings (YYYY-MM-DD)
- The CLI uses Python's `argparse` with subcommands: `add`, `list`, `delete`, `summary`
- Exit code 0 on success, 1 on any error
</specification_context>

<architecture_context>
### Dependencies

- Python 3.14+ standard library only (json, argparse, datetime, sys): system functionality
- uv: project management, packaging, and running the CLI
</architecture_context>

<task>
## Project scaffold: pyproject.toml & package structure

Create the pyproject.toml with project metadata, entry point, and dependency config (stdlib only, uv-managed). Also create the src/spenny/__init__.py package init file so the package is importable.

## Files to Produce

- `pyproject.toml`
- `src/spenny/__init__.py`
</task>