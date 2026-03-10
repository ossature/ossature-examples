The CLI entry point has been implemented in `src/spenny/cli.py`. It includes:

1. **Argument Parsing**: Uses `argparse` to handle subcommands (`add`, `list`, `delete`, `summary`) and their respective arguments.
2. **Error Handling**: Catches `ValueError` and other exceptions, prints error messages, and exits with code 1.
3. **Output Formatting**: Formats amounts as `$X.XX` and prints tables for expenses and summaries as specified.
4. **Integration with Core and Storage**: Calls the appropriate core functions and saves/loads data using the storage module.
5. **Date Handling**: Uses `datetime.date.today().isoformat()` for the current date when `--date` is not provided in the `add` command.

The implementation adheres to the architecture and specification, ensuring that the CLI is the only module that prints to stdout or calls `sys.exit`.