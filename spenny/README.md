# Spenny

Spenny is a command-line expense tracker written in Python. It's designed to be simple, fast, and dependency-free, using only Python's standard library with data stored in a human-readable JSON file (`expenses.json`). It supports adding, listing, deleting, and summarizing expenses, with filtering by category and date range. Each expense includes an amount, category, optional description, auto-generated ID, and a timestamp. It uses `argparse` for CLI parsing with subcommands and adheres to strict error handling with clear messages and appropriate exit codes.

This project was created and built entirely with [Ossature](https://ossature.dev). See the [main README](../README.md#what-to-look-for) for a guide to exploring the `.ossature/` directory and understanding the artifacts Ossature produces at each stage.

## Project Structure

```
specs/
├── expense_tracker.smd    # What the tracker should do
└── expense_tracker.amd    # How the code is organized
```

Building the example (see [Rebuilding](#rebuilding) below) generates an `output/` tree along these lines:

```
output/
└── src/spenny/
    ├── cli.py             # Entry point, argparse subcommands
    ├── core.py            # Business logic (pure functions)
    └── storage.py         # JSON file persistence
```

## Model Configuration

The project uses a mixed-model setup configured in `ossature.toml`:

- **Audit:** `anthropic:claude-opus-4-6`
- **Planner / Fixer:** `anthropic:claude-sonnet-4-6`
- **Code generation (all other tasks):** `mistral:devstral-latest`

## Try It

Build the example first (see [Rebuilding](#rebuilding) below), then:

```bash
cd output
uv run spenny --help
```

```
usage: spenny [-h] {add,list,delete,summary} ...

Spenny: A simple command-line expense tracker

positional arguments:
  {add,list,delete,summary}
    add                 Add a new expense
    list                List expenses
    delete              Delete an expense
    summary             Show spending summary

options:
  -h, --help            show this help message and exit
```

## Rebuilding

See the [main README](../README.md#rebuilding-an-example) for rebuild instructions.
