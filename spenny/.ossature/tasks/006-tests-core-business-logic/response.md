The test file `tests/test_core.py` has been created with comprehensive test cases covering all the specified requirements for the core business logic. The tests include:

1. **Adding Expenses**:
   - Valid inputs
   - Zero amount raises `ValueError`
   - Negative amount raises `ValueError`
   - Empty category raises `ValueError`
   - `None` date raises `ValueError`

2. **Listing Expenses**:
   - No filter
   - Category filter
   - Start date filter
   - End date filter
   - Combined filters

3. **Deleting Expenses**:
   - Success case
   - Missing ID raises `ValueError`

4. **Summarizing Expenses**:
   - No expenses (`has_expenses=False`)
   - With expenses and no filter
   - Date range filter that matches nothing (`has_expenses=True`, totals empty)
   - Overall total computation

The tests ensure that the core logic adheres to the specification and handles all edge cases appropriately.