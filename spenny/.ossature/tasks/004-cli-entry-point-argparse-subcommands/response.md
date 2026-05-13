The `src/spenny/cli.py` file has been created with the implementation of the CLI entry point. The code includes:

1. **Argument Parsing**: Uses `argparse` to define subcommands (`add`, `list`, `delete`, `summary`) and their respective arguments.
2. **Core Function Integration**: Calls the appropriate core functions (`add_expense`, `list_expenses`, `delete_expense`, `summarize`) based on the subcommand.
3. **Date Handling**: Validates date formats and uses `datetime.date.today()` as the default date for the `add` command.
4. **Output Formatting**: Formats expense tables and summary tables as specified in the examples.
5. **Error Handling**: Prints error messages to `stderr` and exits with code `1` for invalid inputs or errors.
6. **Data Persistence**: Loads and saves data using the `storage` module.

The implementation adheres to the architecture and specification, ensuring all requirements are met.