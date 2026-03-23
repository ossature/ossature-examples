# Qoizig

Qoizig is a high-performance, zero-dependency command-line tool and library implemented in Zig for the [QOI (Quite OK Image)](https://qoiformat.org/) format. It provides encoding and decoding capabilities for QOI files — a fast, lossless image format. The tool converts between QOI and standard image formats (PPM P6 for RGB, PAM P7 for RGBA), strictly adhering to the QOI specification for byte-ordering, chunk compression, and pixel history states.

This project was created and built entirely with [Ossature](https://ossature.dev). See the [main README](../README.md#what-to-look-for) for a guide to exploring the `.ossature/` directory and understanding the artifacts Ossature produces at each stage.

## Project Structure

```
specs/
└── QOI_CODEC.smd          # Single spec covering the full codec

context/
└── qoi_specification.md   # The QOI format specification, provided as context

output/src/
├── main.zig               # CLI entry point
├── qoi.zig                # QOI types and constants
├── encoder.zig            # QOI encoder
├── decoder.zig            # QOI decoder
├── image_io.zig           # PPM/PAM reader and writer
├── codec_test.zig         # Encoder/decoder unit tests
├── image_io_test.zig      # Image I/O tests
└── integration_test.zig   # End-to-end tests
```

## Context

The [QOI specification](https://qoiformat.org/qoi-specification.pdf) is provided as a markdown file in `context/qoi_specification.md` and made available to the LLM during code generation.

## Model Configuration

- **All tasks:** `anthropic:claude-opus-4-6`

The build uses a custom setup step (`zig init -m`) configured in `ossature.toml` to scaffold the Zig project before code generation begins.

## Try It

Requires [Zig](https://ziglang.org/) 0.15.2+:

```bash
cd output
zig build
./zig-out/bin/qoizig encode input.ppm output.qoi
./zig-out/bin/qoizig decode output.qoi decoded.pam
```

## Rebuilding

See the [main README](../README.md#rebuilding-an-example) for rebuild instructions.
