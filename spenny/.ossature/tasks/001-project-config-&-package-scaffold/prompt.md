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

### Overview

Three Python modules: a storage layer for JSON persistence, a core module for business logic, and a CLI entry point that wires argparse subcommands to core functions.
</architecture_context>

<task>
## Project Config & Package Scaffold

Create pyproject.toml with project metadata, dependencies, and the spenny entry point. Also create the src/spenny/__init__.py package marker. This establishes the installable package structure under uv.

## Files to Produce

- `pyproject.toml`
- `src/spenny/__init__.py`
</task>