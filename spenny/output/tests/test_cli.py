import subprocess
import json
import os
from decimal import Decimal

# Helper function to run the CLI command
def run_cli_command(args):
    result = subprocess.run(
        ["python", "-m", "spenny.cli"] + args,
        capture_output=True,
        text=True,
    )
    return result

# Helper function to reset the expenses.json file
def reset_expenses_file():
    if os.path.exists("expenses.json"):
        os.remove("expenses.json")

# Helper function to read the expenses.json file
def read_expenses_file():
    with open("expenses.json", "r") as f:
        return json.load(f)


def test_add_expense():
    reset_expenses_file()
    result = run_cli_command([
        "add",
        "--amount", "12.50",
        "--category", "Food",
        "--description", "Lunch at cafe",
    ])
    assert result.returncode == 0
    assert "Expense added: #1" in result.stdout
    assert "$12.50" in result.stdout
    assert "[Food]" in result.stdout
    assert "Lunch at cafe" in result.stdout

    # Verify the expense was written to the file
    data = read_expenses_file()
    assert len(data["expenses"]) == 1
    assert data["expenses"][0]["id"] == 1
    assert data["expenses"][0]["amount"] == "12.50"
    assert data["expenses"][0]["category"] == "Food"
    assert data["expenses"][0]["description"] == "Lunch at cafe"


def test_list_expenses():
    reset_expenses_file()
    # Add some expenses
    run_cli_command([
        "add",
        "--amount", "12.50",
        "--category", "Food",
        "--description", "Lunch at cafe",
    ])
    run_cli_command([
        "add",
        "--amount", "3.00",
        "--category", "Transport",
        "--description", "Bus fare",
    ])
    
    result = run_cli_command(["list"])
    assert result.returncode == 0
    assert "ID   Date         Category     Amount   Description" in result.stdout
    assert "1    " in result.stdout
    assert "Food" in result.stdout
    assert "$12.50" in result.stdout
    assert "Transport" in result.stdout
    assert "$3.00" in result.stdout


def test_list_expenses_with_category_filter():
    reset_expenses_file()
    # Add some expenses
    run_cli_command([
        "add",
        "--amount", "12.50",
        "--category", "Food",
        "--description", "Lunch at cafe",
    ])
    run_cli_command([
        "add",
        "--amount", "3.00",
        "--category", "Transport",
        "--description", "Bus fare",
    ])
    
    result = run_cli_command(["list", "--category", "Food"])
    assert result.returncode == 0
    assert "Food" in result.stdout
    assert "Transport" not in result.stdout


def test_list_expenses_with_date_filter():
    reset_expenses_file()
    # Add some expenses with specific dates
    run_cli_command([
        "add",
        "--amount", "12.50",
        "--category", "Food",
        "--description", "Lunch at cafe",
        "--date", "2026-03-01",
    ])
    run_cli_command([
        "add",
        "--amount", "3.00",
        "--category", "Transport",
        "--description", "Bus fare",
        "--date", "2026-03-02",
    ])
    
    result = run_cli_command([
        "list",
        "--start-date", "2026-03-01",
        "--end-date", "2026-03-01",
    ])
    assert result.returncode == 0
    assert "2026-03-01" in result.stdout
    assert "2026-03-02" not in result.stdout


def test_delete_expense():
    reset_expenses_file()
    # Add an expense
    run_cli_command([
        "add",
        "--amount", "12.50",
        "--category", "Food",
        "--description", "Lunch at cafe",
    ])
    
    result = run_cli_command(["delete", "1"])
    assert result.returncode == 0
    assert "Expense #1 deleted." in result.stdout
    
    # Verify the expense was deleted
    data = read_expenses_file()
    assert len(data["expenses"]) == 0


def test_delete_nonexistent_expense():
    reset_expenses_file()
    result = run_cli_command(["delete", "999"])
    assert result.returncode == 1
    assert "Error: Expense ID not found" in result.stderr


def test_summary():
    reset_expenses_file()
    # Add some expenses
    run_cli_command([
        "add",
        "--amount", "12.50",
        "--category", "Food",
        "--description", "Lunch at cafe",
    ])
    run_cli_command([
        "add",
        "--amount", "8.75",
        "--category", "Food",
        "--description", "Coffee and pastry",
    ])
    run_cli_command([
        "add",
        "--amount", "3.00",
        "--category", "Transport",
        "--description", "Bus fare",
    ])
    
    result = run_cli_command(["summary"])
    assert result.returncode == 0
    assert "Category     Total" in result.stdout
    assert "Food" in result.stdout
    assert "$21.25" in result.stdout
    assert "Transport" in result.stdout
    assert "$3.00" in result.stdout
    assert "Total: $24.25" in result.stdout


def test_summary_with_date_filter():
    reset_expenses_file()
    # Add some expenses with specific dates
    run_cli_command([
        "add",
        "--amount", "12.50",
        "--category", "Food",
        "--description", "Lunch at cafe",
        "--date", "2026-03-01",
    ])
    run_cli_command([
        "add",
        "--amount", "3.00",
        "--category", "Transport",
        "--description", "Bus fare",
        "--date", "2026-03-02",
    ])
    
    result = run_cli_command([
        "summary",
        "--start-date", "2026-03-01",
        "--end-date", "2026-03-01",
    ])
    assert result.returncode == 0
    assert "Food" in result.stdout
    assert "$12.50" in result.stdout
    assert "Transport" not in result.stdout


def test_summary_no_expenses():
    reset_expenses_file()
    result = run_cli_command(["summary"])
    assert result.returncode == 0
    assert "No expenses to summarize." in result.stdout


def test_summary_no_expenses_in_range():
    reset_expenses_file()
    # Add an expense outside the date range
    run_cli_command([
        "add",
        "--amount", "12.50",
        "--category", "Food",
        "--description", "Lunch at cafe",
        "--date", "2026-03-01",
    ])
    
    result = run_cli_command([
        "summary",
        "--start-date", "2026-04-01",
        "--end-date", "2026-04-02",
    ])
    assert result.returncode == 0
    assert "No expenses found in the specified date range." in result.stdout


def test_invalid_amount():
    reset_expenses_file()
    result = run_cli_command([
        "add",
        "--amount", "-12.50",
        "--category", "Food",
        "--description", "Lunch at cafe",
    ])
    assert result.returncode == 1
    assert "Error: Amount must be positive." in result.stderr


def test_empty_category():
    reset_expenses_file()
    result = run_cli_command([
        "add",
        "--amount", "12.50",
        "--category", "",
        "--description", "Lunch at cafe",
    ])
    assert result.returncode == 1
    assert "Error: Category cannot be empty." in result.stderr


def test_invalid_date_format():
    reset_expenses_file()
    result = run_cli_command([
        "add",
        "--amount", "12.50",
        "--category", "Food",
        "--description", "Lunch at cafe",
        "--date", "invalid-date",
    ])
    assert result.returncode == 1
    assert "Error: Invalid date format. Use YYYY-MM-DD." in result.stderr


def test_missing_expenses_file():
    reset_expenses_file()
    result = run_cli_command(["list"])
    assert result.returncode == 0
    assert "No expenses found." in result.stdout
