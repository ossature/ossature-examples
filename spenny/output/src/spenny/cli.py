import argparse
import sys
from decimal import Decimal
from datetime import date

from spenny.core import (
    add_expense,
    list_expenses,
    delete_expense,
    summarize,
)
from spenny.storage import load, save


def format_amount(amount_str: str) -> str:
    """Format an amount string as $X.XX."""
    amount = Decimal(amount_str)
    return f"${amount:.2f}"


def print_expense_table(expenses: list[dict]) -> None:
    """Print expenses in a formatted table."""
    if not expenses:
        print("No expenses found.")
        return

    # Print header
    print("ID   Date         Category     Amount   Description")
    print("──   ──────────   ────────     ──────   ───────────")

    # Print rows
    for expense in expenses:
        expense_id = expense["id"]
        expense_date = expense["date"]
        category = expense["category"]
        amount = format_amount(expense["amount"])
        description = expense["description"]

        print(f"{expense_id:<4} {expense_date}   {category:<10} {amount:<8} {description}")


def print_summary(summary_result):
    """Print the spending summary."""
    totals = summary_result.totals
    has_expenses = summary_result.has_expenses

    if not has_expenses:
        print("No expenses to summarize.")
        return

    if not totals:
        print("No expenses found in the specified date range.")
        return

    # Print header
    print("Category     Total")
    print("────────     ─────")

    # Print rows
    for category, total in totals.items():
        print(f"{category:<12} {format_amount(str(total))}")

    # Print overall total
    overall_total = sum(totals.values())
    print(f"\nTotal: {format_amount(str(overall_total))}")


def main() -> None:
    """Entry point for the Spenny CLI."""
    parser = argparse.ArgumentParser(
        description="Spenny: A simple command-line expense tracker"
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    # Add command
    add_parser = subparsers.add_parser("add", help="Add a new expense")
    add_parser.add_argument(
        "--amount", type=Decimal, required=True, help="Expense amount"
    )
    add_parser.add_argument(
        "--category", type=str, required=True, help="Expense category"
    )
    add_parser.add_argument(
        "--description", type=str, default="", help="Expense description"
    )
    add_parser.add_argument(
        "--date", type=str, default=None, help="Expense date (ISO format: YYYY-MM-DD)"
    )

    # List command
    list_parser = subparsers.add_parser("list", help="List expenses")
    list_parser.add_argument(
        "--category", type=str, default=None, help="Filter by category"
    )
    list_parser.add_argument(
        "--start-date", type=str, default=None, help="Start date (ISO format: YYYY-MM-DD)"
    )
    list_parser.add_argument(
        "--end-date", type=str, default=None, help="End date (ISO format: YYYY-MM-DD)"
    )

    # Delete command
    delete_parser = subparsers.add_parser("delete", help="Delete an expense")
    delete_parser.add_argument("id", type=int, help="Expense ID to delete")

    # Summary command
    summary_parser = subparsers.add_parser("summary", help="Show spending summary")
    summary_parser.add_argument(
        "--start-date", type=str, default=None, help="Start date (ISO format: YYYY-MM-DD)"
    )
    summary_parser.add_argument(
        "--end-date", type=str, default=None, help="End date (ISO format: YYYY-MM-DD)"
    )

    args = parser.parse_args()

    try:
        data = load()

        if args.command == "add":
            # Use today's date if not provided
            expense_date = args.date if args.date is not None else date.today().isoformat()
            updated_data, new_expense = add_expense(
                data=data,
                amount=args.amount,
                category=args.category,
                description=args.description,
                date=expense_date,
            )
            save(updated_data)
            print(
                f"Expense added: #{new_expense['id']} — {format_amount(new_expense['amount'])} "
                f"[{new_expense['category']}] {new_expense['description']}"
            )

        elif args.command == "list":
            expenses = list_expenses(
                data=data,
                category=args.category,
                start_date=args.start_date,
                end_date=args.end_date,
            )
            print_expense_table(expenses)

        elif args.command == "delete":
            updated_data = delete_expense(data=data, expense_id=args.id)
            save(updated_data)
            print(f"Expense #{args.id} deleted.")

        elif args.command == "summary":
            summary_result = summarize(
                data=data,
                start_date=args.start_date,
                end_date=args.end_date,
            )
            print_summary(summary_result)

    except ValueError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()