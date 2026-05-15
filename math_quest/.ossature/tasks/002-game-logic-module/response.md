Syntax is clean. Here's a summary of every requirement and how it's handled:

---

**Implementation summary:**

### State machine (`state.mode`)
- **"title"** → Enter starts a fresh game → **"playing"**
- **"playing"** → lives reach 0 → **"gameover"**; Enter on gameover → **"title"**

### Problem generation (`generate_problem`)
- Level = `floor(score/5) + 1`, capped at 10
- Level 1–2: addition only; 3–4: + and −; 5+: +, −, ×
- Subtraction always ensures `a ≥ b` so answer ≥ 0
- Operand ranges widen each level

### Timer (10 s)
- Counts down in `Game.update`; on expiry calls `submit_answer()`
- Empty buffer → wrong answer (life lost); non-empty → evaluate normally

### Input handling
- `Game.textinput`: digits 0–9 only, appended to `state.input`
- `Game.keypressed`: Backspace trims buffer; Enter submits; **`"minus"` key returns immediately** without touching the buffer (suppression in keypressed, not textinput)

### Scoring / lives / feedback
- Correct: score +1, green flash, `sfx_correct` played
- Wrong: lives −1, red flash, `sfx_wrong` played
- Flash lasts 0.5 s, rendered as a full-screen tinted overlay fading with `timer/FEEDBACK_DUR`

### Audio
- `correct.wav` and `wrong.ogg` loaded as `"static"` sources
- Played via `love.audio.play()` — asynchronous, survives state transitions

### Particles (hand-rolled)
- 80 initial particles; 6 new/second steady spawn rate
- 6 distinct soft colors (sat ≤ 0.7, lightness 0.4–0.9)
- Fade in over first 20% of lifespan, full opacity mid-life, fade out over last 20%
- Drawn before all UI — purely decorative

### Fonts
- Problem: 56 px (≥ 48 px ✓); input display: 40 px (≥ 36 px ✓)
- All LÖVE2D built-in default font, scaled — no external font files