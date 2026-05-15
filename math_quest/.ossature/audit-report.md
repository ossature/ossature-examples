# Audit Report: math_quest v0.1.0

**Date:** 2026-05-14T21:39:31Z
**Specs:** MATH_QUEST

## MATH_QUEST Findings

### WARNING: Requirements > Problem Generation, L57

**Issue:** The subtraction algorithm sets the minuend to `score + 10` and the subtrahend to a random value from 1 to `score` (or 1 if score is 0). At score 0, the subtrahend is always 1, making the only possible problem '10 - 1 = 9'. This is not random and produces a deterministic problem at level 0. More critically, the subtrahend upper bound grows linearly with score, while the minuend is also score+10, meaning the subtrahend can equal score, making the answer as low as 10 — but the operand ranges are tightly coupled to score rather than level L, unlike addition and multiplication. Two developers could implement this differently (e.g., one clamps subtrahend to max 1 when score=0, another returns a fixed problem).

**Suggestion:** Clarify whether the subtraction operand ranges are intentional. Consider defining subtraction operands in terms of level L (like the other operations) for consistency, or explicitly confirm the score-based formula and the degenerate score=0 case.

### WARNING: Requirements > Input Handling, L72-L74

**Issue:** The spec states that `love.keypressed()` must consume the minus key event by returning `true`, but LÖVE2D's `love.keypressed` callback return value is not used by the framework — LÖVE2D does not support event consumption via return values from `love.keypressed`. The spec's instruction to 'return true' has no effect on `love.textinput`, meaning if the LÖVE2D runtime fires `love.textinput` for the minus key, the suppression described will be incomplete despite the spec claiming suppression is 'handled entirely in love.keypressed()'.

**Suggestion:** Remove the instruction to 'return true' from love.keypressed (it has no effect in LÖVE2D). To fully suppress the minus character, also guard love.textinput against appending '-' to the input buffer, or explicitly state that love.textinput should ignore non-digit characters.

### WARNING: Requirements > Scoring and Lives, L82

**Issue:** The spec says timer expiry submits 'whatever is currently in the input buffer for evaluation: if the buffer is non-empty, it is evaluated normally (correct or wrong).' However, the Input Handling section (L74) defines the submission sequence as triggered by Enter. It is ambiguous whether a timer expiry that results in a correct answer increments the score or only deducts a life on wrong/empty. Two developers could reasonably disagree on whether a timer expiry with a correct buffer value should award a point.

**Suggestion:** Explicitly state whether a correct answer submitted via timer expiry (non-empty buffer with the right answer) awards a point, or whether timer expiry always counts as wrong regardless of buffer content.

### INFO: Requirements > Game States, L40

**Issue:** The game-over state says 'Pressing Enter returns to the title state', but the acceptance criteria (L205) says 'Pressing Enter starts a new game with score 0 and 3 lives', which implies transitioning to the playing state, not the title state. The game-over screen also says 'Press Enter to Play Again' (L197), which suggests restarting, not returning to the title.

**Suggestion:** Clarify whether pressing Enter on the game-over screen goes to the title state (as stated in Game States) or directly starts a new game in the playing state (as implied by acceptance criteria and the screen text 'Play Again').

### INFO: Requirements > Audio, L106-L108

**Issue:** The correct answer sound is specified as `correct.wav` and the wrong answer sound as `wrong.ogg`. These are two different formats. The spec does not clarify whether both files must exist or if the implementation should handle a missing file gracefully. A missing asset would cause a runtime error on `love.audio.newSource`.

**Suggestion:** Confirm both asset files are present in the context directory and document what should happen (e.g., skip playback with a warning) if an asset file is missing at load time.

