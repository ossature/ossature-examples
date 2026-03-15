All three files are in place and working:

1. **`build.zig`** — Defines:
   - A `qoizig` module from `src/qoi.zig` (the library)
   - A `qoizig` executable from `src/main.zig` that imports the library module
   - A `run` step for CLI convenience
   - A `test` step that runs unit tests for both the library (`src/qoi.zig`) and the CLI (`src/main.zig`)

2. **`src/main.zig`** — CLI entry point that parses `encode`/`decode` commands with input/output paths, prints usage on error, and stubs out the encode/decode functions (to be filled in by the codec implementation task). Imports the `qoizig` library module.

3. **`src/qoi.zig`** — Placeholder library module with the core QOI types (`Header`, `Channels`, `Colorspace`) and a basic test, ready to be expanded with the full codec implementation.