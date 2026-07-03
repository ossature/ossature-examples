import argparse
import sys
from datetime import date
from decimal import Decimal

from spenny.core import add_expense, list_expenses, delete_expense, summarize
from spenny.storage import load, save


def format_amount(amount: Decimal) -> str:
    return f"${amount:.2f}"


def format_expense_table(expenses: list) -> str:
    if not expenses:
        return "No expenses found."

    header = "ID   Date         Category     Amount   Description"
    separator = "──   ──────────   ────────     ──────   ───────────"
    rows = []
    for expense in expenses:
        expense_id = expense["id"]
        expense_date = expense["date"]
        category = expense["category"]
        amount = format_amount(Decimal(expense["amount"]))
        description = expense["description"]
        rows.append(f"{expense_id:<4} {expense_date}   {category:<12} {amount:<8} {description}")

    return "\n".join([header, separator] + rows)


def format_summary_table(summary_result):
    totals = summary_result.totals
    has_expenses = summary_result.has_expenses

    if not has_expenses:
        return "No expenses to summarize."

    if not totals:
        return "No expenses found in the specified date range."

    header = "Category     Total"
    separator = "────────     ─────"
    rows = []
    for category, total in totals.items():
        rows.append(f"{category:<12} {format_amount(total)}")

    overall_total = sum(totals.values())
    table = "\n".join([header, separator] + rows)
    return f"{table}\n\nTotal: {format_amount(overall_total)}"


def validate_date(date_str: str) -> None:
    try:
        date.fromisoformat(date_str)
    except ValueError:
        print("Error: Invalid date format. Use YYYY-MM-DD.", file=sys.stderr)
        sys.exit(1)


def main() -> None:
    parser = argparse.ArgumentParser(description="Spenny - Expense Tracker")
    subparsers = parser.add_subparsers(dest="command", required=True)

    # Add command
    add_parser = subparsers.add_parser("add", help="Add a new expense")
    add_parser.add_argument("--amount", type=str, required=True, help="Expense amount")
    add_parser.add_argument("--category", type=str, required=True, help="Expense category")
    add_parser.add_argument("--description", type=str, default="", help="Expense description")
    add_parser.add_argument("--date", type=str, help="Expense date (YYYY-MM-DD)")

    # List command
    list_parser = subparsers.add_parser("list", help="List expenses")
    list_parser.add_argument("--category", type=str, help="Filter by category")
    list_parser.add_argument("--start-date", type=str, help="Start date (YYYY-MM-DD)")
    list_parser.add_argument("--end-date", type=str, help="End date (YYYY-MM-DD)")

    # Delete command
    delete_parser = subparsers.add_parser("delete", help="Delete an expense")
    delete_parser.add_argument("id", type=int, help="Expense ID to delete")

    # Summary command
    summary_parser = subparsers.add_parser("summary", help="Show spending summary")
    summary_parser.add_argument("--start-date", type=str, help="Start date (YYYY-MM-DD)")
    summary_parser.add_argument("--end-date", type=str, help="End date (YYYY-MM-DD)")

    args = parser.parse_args()

    # Load data
    data = load()

    # Handle commands
    if args.command == "add":
        try:
            amount = Decimal(args.amount)
            if amount <= 0:
                print("Error: Amount must be positive.", file=sys.stderr)
                sys.exit(1)
            if not args.category:
                print("Error: Category cannot be empty.", file=sys.stderr)
                sys.exit(1)

            expense_date = args.date if args.date else date.today().isoformat()
            validate_date(expense_date)

            updated_data, new_expense = add_expense(
                data=data,
                amount=amount,
                category=args.category,
                description=args.description,
                date=expense_date,
            )
            save(updated_data)

            print(
                f"Expense added: #{new_expense['id']} — {format_amount(Decimal(new_expense['amount']))} [{new_expense['category']}] {new_expense['description']}"
            )
        except ValueError as e:
            print(f"Error: {e}", file=sys.stderr)
            sys.exit(1)

    elif args.command == "list":
        if args.start_date:
            validate_date(args.start_date)
        if args.end_date:
            validate_date(args.end_date)

        expenses = list_expenses(
            data=data,
            category=args.category,
            start_date=args.start_date,
            end_date=args.end_date,
        )
        print(format_expense_table(expenses))

    elif args.command == "delete":
        try:
            updated_data = delete_expense(data=data, expense_id=args.id)
            save(updated_data)
            print(f"Expense #{args.id} deleted.")
        except ValueError as e:
            print(f"Error: {e}", file=sys.stderr)
            sys.exit(1)

    elif args.command == "summary":
        if args.start_date:
            validate_date(args.start_date)
        if args.end_date:
            validate_date(args.end_date)

        summary_result = summarize(
            data=data,
            start_date=args.start_date,
            end_date=args.end_date,
        )
        print(format_summary_table(summary_result))


if __name__ == "__main__":
    main()