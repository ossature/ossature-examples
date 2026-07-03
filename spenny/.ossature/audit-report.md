# Audit Report: Spenny v0.1.0

**Date:** 2026-05-13T21:29:20Z
**Specs:** EXPENSE_TRACKER

## EXPENSE_TRACKER Findings

### WARNING: Requirements > Add an Expense, L35

**Issue:** The spec says the core function 'remains pure' and date defaults to today, with the CLI responsible for supplying `datetime.date.today()`. However, the AMD interface (L60) shows `date: str | None = None` on `add_expense`, implying `None` is a valid input to the core function. If `None` is passed, the core function must either default the date itself (breaking purity) or raise an error. The spec should clarify whether the CLI must always pass an explicit date string or whether the core function handles the `None` case.

**Suggestion:** Clarify in the AMD that the CLI must always resolve `None` to `str(datetime.date.today())` before calling `add_expense`, and that `add_expense` should raise/error if `date` is `None`. Alternatively, update the AMD signature to make `date` a required `str` parameter.

