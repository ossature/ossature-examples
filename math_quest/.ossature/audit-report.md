# Audit Report: math_quest v0.1.0

**Date:** 2026-03-10T19:32:52Z
**Specs:** MATH_QUEST

## MATH_QUEST Findings

### WARNING: Requirements > Input Handling, line ~47 vs Architecture Documents > Components > Game Logic

**Issue:** The spec says love.keypressed() must 'return true' to consume the minus key event, but in LÖVE2D, the love.keypressed callback's return value is not used by the framework to suppress subsequent love.textinput events. Returning true from love.keypressed does not prevent love.textinput from firing for the same keypress. The spec also says 'love.textinput() is not involved in minus-key suppression', but love.textinput will still receive '-' unless explicitly filtered there.

**Suggestion:** Either add a guard in Game.textinput(t) to reject non-digit characters (which would naturally block '-'), or set a flag in keypressed that textinput checks. Clarify that suppression requires cooperation from both callbacks, or simply specify that textinput only accepts characters '0'-'9' and ignores everything else.

### WARNING: Requirements > Problem Generation

**Issue:** The spec says problems get progressively harder as the score increases and the problem generator accepts the current score to determine level, but the actual difficulty scaling algorithm is not defined. Two developers could produce very different difficulty curves (e.g., one might introduce multiplication at score 5, another at score 20; one might cap difficulty, another might not). This affects user-visible behavior for the target age range (6-12).

**Suggestion:** Define approximate level thresholds and which operations/operand ranges apply at each level. For example: score 0-4 = addition with operands 1-10, score 5-9 = addition/subtraction with operands 1-20, score 10+ = multiplication with operands 1-12.

### INFO: Architecture Documents > Components > Game Logic > Interface vs Architecture Documents > Notes

**Issue:** The architecture notes specify audio assets as 'correct.wav' and 'wrong.ogg' (different file formats), but does not explain why two different formats are used. This is not a problem per se, but if the context directory only contains one format variant, it would fail at runtime.

**Suggestion:** Confirm the exact filenames and formats of the bundled audio assets, or standardize on one format for both files.

### WARNING: Requirements > Scoring and Lives > timer expiry behavior, line ~65

**Issue:** The spec says timer expiry submits the buffer for evaluation, and if non-empty it is 'evaluated normally'. However, the spec also says wrong answers cause a 'red flash' and play sfx_wrong. It is not stated whether timer expiry itself provides any distinct visual/audio feedback versus a normal wrong answer. More importantly, the submission sequence in Input Handling says sounds play on Enter press — it's ambiguous whether auto-submission on timer expiry should also play sound effects.

**Suggestion:** Clarify that timer-expiry auto-submission follows the same submission sequence as Enter (including sound effects and flash), or specify different behavior.

