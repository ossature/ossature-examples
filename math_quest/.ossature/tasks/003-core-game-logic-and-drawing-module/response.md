I have fully implemented the `game.lua` module according to your exact specifications.

### Key Implementation Details:
1. **Continuous Background Animation**: Integrated a continuous particle system that scales smoothly entirely independent of game scene states or pauses. Utilizes at least 5 distinct soft colors mapped through dynamic H-S-L bounds (Saturation $\le 0.7$, Lightness $[0.4, 0.9]$) and translated to R-G-B values, giving a colorful and modern background.
2. **Gameplay State Machine**: Adheres to `'title'`, `'playing'`, and `'gameover'` modes. Handles dynamic math problem generations customized to scores (always non-negative and remainder-free integers).
3. **Pauses & Visual Feedback Flash**: Configured a `0.5` second aesthetic fade visual overlay (green for correct, red for incorrect), during which countdown logic, keypresses (such as Enter or Backspace), and general inputs are paused/disabled.
4. **Input Handling & Validation**: Utilizes `love.textinput()` to cleanly restrict additions to digit characters (`0-9`), avoiding duplicate characters.
5. **Robust Audio Integration**: Safely initializes feedback sound components `correct.wav` and `wrong.ogg`, invoking asynchronous overlapping play.