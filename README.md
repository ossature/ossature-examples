# Ossature Examples

This repo contains example projects created and built entirely with Ossature.

All specification documents for the examples provided in this repo are licensed under [CC0](https://creativecommons.org/public-domain/cc0/). All generated code for these examples is licensed under MIT. 

- Check the `specs` directory in each example to learn about the specification and/or architecture documents used.
- Check the `.ossature` directory for:
  - `audit-report.md` for an example of an audit report generated for the project using `ossature audit`
  - `plan.toml` for an example plan generated after an audit (generated during after running an audit)
  - `context/interfaces/*.md` for an example of extracted interfaces from the spec files used when planning and building the project
  - `context/project-brief.md` and `context/spec-briefs/*.md` for examples on the generated briefs that will be assembled into a built prompt for each task from the plan
  - Check the `.ossature/tasks` dir for:
    - `tasks/**/prompt.md` the prompt used during the build phase of a specific task
    - `tasks/**/response.md` the response from the LLM received during the build phase of a specific task
    - `tasks/**/output.toml` a summary of the result of the generation and verification of a specific task
    - `tasks/**/fix-*-prompt.toml` the prompt used for fix-iteration-x, if the verification step failed after built and the build phase of a task required a fixer loop.
    - `tasks/**/fix-*-prompt.toml` the LLM response received for fix-iteration-x, if the verification step failed after built and the build phase of a task required a fixer loop.

Currently available examples:
- [Spenny](#Spenny): CLI project, written in Python

## Spenny

Spenny is an example project specified to be generated in Python. It's a command-line expense tracker designed to be simple, fast, and dependency-free. It allows users to add, list, delete, and summarize expenses using only Python's standard library, with data stored in a human-readable JSON file (`expenses.json`). Each expense includes an amount, category, optional description, auto-generated ID, and a timestamp. The tool supports filtering by category and date range, and provides formatted output for lists and spending summaries. It uses `argparse` for CLI parsing with subcommands and adheres to strict error handling with clear messages and appropriate exit codes. This example focuses solely on personal expense tracking without GUI, multi-user support, or external services.

The project is configured to use `anthropic:claude-opus-4-6` for audit and `anthropic:claude-sonnet-4-6` for planning and fixer loops, code generation uses and all other tasks are configured to use `mistral:devstral-latest`.

The project is fully validated, audited (check `.ossature` dir) and built (check `output` dir).

To test run the built code:

```bash
$ cd spenny/output
$ uv run spenny --help
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

To rebuild the project manually:

- Make sure you set the environment variables for the models configured. If you keep Mistral's and Anthropics, you can se:

```bash
export ANTHROPIC_API_KEY=your_anthropic_key
export MISTRAL_API_KEY=your_mistral_key
```

If you'd like to rebuild only using the plan generated for this example, you can:

```bash
$ rm -rf output
$ ossature build
```

Or if you'd like to re-audit and replan yourself:

```bash
$ rm -rf output
$ ossature clean
$ ossature audit
# after it's finished auditing and generating the plan
$ ossature build
```