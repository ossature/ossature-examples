# Math Quest

Math Quest is a children's arithmetic game built with LÖVE2D (Lua) that presents progressively difficult math problems and accepts typed numeric answers. The game starts the player with a fixed number of lives and generates arithmetic problems that increase in difficulty as the player's score rises. Players type their answers using the keyboard, receiving immediate feedback through sound effects loaded from provided audio assets.

This project was created and built entirely with [Ossature](https://ossature.dev). See the [main README](../README.md#what-to-look-for) for a guide to exploring the `.ossature/` directory and understanding the artifacts Ossature produces at each stage.

## Project Structure

```
specs/
├── math_game.smd          # Game behavior spec
└── math_game.amd          # Architecture spec

context/
├── correct.wav            # Correct answer sound effect
└── wrong.ogg              # Wrong answer sound effect
```

Building the example (see [Rebuilding](#rebuilding) below) generates an `output/` tree along these lines:

```
output/
├── conf.lua               # LÖVE2D window configuration
├── main.lua               # Entry point, input handling, rendering
├── game.lua               # Game logic module
├── correct.wav            # Copied from context
└── wrong.ogg              # Copied from context
```

## Context Assets

Two audio assets downloaded from [OpenGameArt](https://opengameart.org/) (licensed under CC0) are provided in `context/` and made available to the LLM during code generation:

- `correct.wav` — Correct answer sound. Source: [Point Bell](https://opengameart.org/content/point-bell)
- `wrong.ogg` — Wrong answer sound. Source: [Error](https://opengameart.org/content/error)

## Model Configuration

- **All tasks:** `anthropic:claude-opus-4-6`

## Try It

Make sure you've downloaded [LÖVE2D](https://love2d.org/) first. Build the example (see [Rebuilding](#rebuilding) below), then:

```bash
cd output
love .
```

![Math Quest gameplay](../assets/math_quest.gif)

## Rebuilding

See the [main README](../README.md#rebuilding-an-example) for rebuild instructions.
