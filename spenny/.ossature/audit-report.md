# Audit Report: Spenny v0.1.0

**Date:** 2026-03-10T18:08:45Z
**Specs:** EXPENSE_TRACKER

## EXPENSE_TRACKER Findings

### WARNING: Requirements > Add an Expense

**Issue:** The spec says the core add_expense function 'remains pure' and that the CLI supplies the date. However, the AMD's core.add_expense signature has `date: str | None = None`, implying None is a valid input to the core function. The spec doesn't clarify what the core function should do if it receives None — should it raise an error, or should it also default to today? If the core function is truly pure it cannot call datetime.date.today(), but if the CLI forgets to supply the date, the core function receives None with no defined behavior.

**Suggestion:** Specify that the core function requires a non-None date string (i.e., the CLI must always resolve None to today's date before calling add_expense), or explicitly state what add_expense does when date is None.

