# Yep

Yep is a Rust clone of the classic Unix `yes` command. It writes a string — a user-supplied argument, or `y` by default — to stdout followed by a newline, repeating forever until the process is killed or the output pipe breaks. Output is pre-buffered and reused across iterations to maximize throughput when piped into other commands, with no third-party dependencies beyond the standard library.

This project was created and built entirely with [Ossature](https://ossature.dev). See the [main README](../README.md#what-to-look-for) for a guide to exploring the `.ossature/` directory and understanding the artifacts Ossature produces at each stage.

## Project Structure

```
specs/
├── YEP.smd                # What yep should do
├── YEP.amd                # How the code is organized
└── YEP.vmd                # Pinned example scenarios (invalid-UTF-8 rejection)
```

This is the only example with a VMD file — a verification spec that pins exact expected output for scenarios that terminate on their own (like rejecting invalid UTF-8 arguments), separate from the streaming behaviors covered by ordinary build-task verification.

Building the example (see [Rebuilding](#rebuilding) below) generates an `output/src/` tree along these lines:

```
output/src/
├── main.rs                # Entry point, argument parsing/validation
└── output.rs              # Buffered output loop
```

## Model Configuration

- **All tasks:** `openrouter:google/gemini-3.5-flash`

## Try It

Requires [Rust](https://www.rust-lang.org/). Build the example first (see [Rebuilding](#rebuilding) below), then:

```bash
cd output
cargo run -- | head -n 3
cargo run -- "yep" | head -n 2
```

## Rebuilding

See the [main README](../README.md#rebuilding-an-example) for rebuild instructions.
