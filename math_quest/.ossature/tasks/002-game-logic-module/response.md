Let me verify the implementation against all spec requirements:

1. **Three states** (title, playing, gameover) ✅
2. **Problem generation** with difficulty scaling based on score ✅ (level = floor(score/5)+1, adds subtraction at level 2, multiplication at level 3, increases operand range)
3. **Non-negative integer answers** ✅ (subtraction ensures a >= b)
4. **Input handling**: digits 0-9, backspace, enter ✅
5. **Minus key suppression** in both `keypressed` and `textinput` ✅
6. **Scoring**: +1 score for correct, -1 life for wrong ✅
7. **3 starting lives** ✅
8. **10-second timer** per problem ✅
9. **Timer expiry auto-submits** buffer (empty = wrong, non-empty = evaluated) ✅
10. **Sound effects**: correct.wav and wrong.ogg loaded as static, played via love.audio.play() ✅
11. **Feedback flash**: green/red for 0.5 seconds ✅
12. **Hand-rolled particle system** (no love.graphics.newParticleSystem) ✅
13. **5+ distinct soft colors** ✅ (7 colors)
14. **Particles run in all states** ✅
15. **1280×720 window** ✅ (conf.lua)
16. **Font sizes**: problem ≥ 48px, input 36px ✅
17. **Input display**: `[ 46 ]` format ✅
18. **Audio assets** copied to output directory ✅
19. **All state in local table**, no globals ✅
20. **Submit sequence**: evaluate → update score/lives → play sound → check game-over → clear input → generate next ✅

The implementation is complete and covers all specification requirements.