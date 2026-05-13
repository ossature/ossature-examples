The implementation of `src/spenny/core.py` is complete. Here's a summary of the key points:

1. **`add_expense`**:
   - Validates that the amount is positive and the category is non-empty.
   - Requires an explicit date string (raises `ValueError` if `None`).
   - Returns the updated `ExpenseData` and the newly created `ExpenseRecord`.

2. **`list_expenses`**:
   - Filters expenses by category, start date, and end date (inclusive).
   - Returns a list of matching `ExpenseRecord` objects.

3. **`delete_expense`**:
   - Removes an expense by its ID.
   - Raises `ValueError` if the ID is not found.

4. **`summarize`**:
   - Computes totals grouped by category, optionally filtered by date range.
   - Returns a `SummaryResult` with `totals` (a dictionary of category totals) and `has_expenses` (a boolean indicating if any expenses exist).

5. **`SummaryResult`**:
   - A `NamedTuple` with fields `totals` and `has_expenses`.

The implementation adheres to the architecture and specification, ensuring all error cases are handled and the functions remain pure.