<project_config>
Project: qoizig v0.0.1
Language: zig
</project_config>

<project_brief>
Qoizig is a command-line tool and library written in Zig (0.15.2+) that encodes and decodes images in the QOI (Quite OK Image) format, a fast lossless image compression format. The project consists of a single core spec (QOI_CODEC) responsible for the complete codec implementation, including QOI header parsing and writing (14-byte headers with magic bytes, dimensions, channel count, and colorspace), pixel-level encoding and decoding across all QOI chunk types (QOI_OP_RGB, QOI_OP_RGBA, QOI_OP_INDEX, QOI_OP_DIFF, QOI_OP_LUMA, QOI_OP_RUN), and a 64-entry running pixel hash index used for compression. The implementation is zero-dependency, relying solely on Zig's standard library, and strictly follows the QOI specification for byte ordering, chunk selection logic, and stream termination (8-byte end marker). The tool exposes both a library API for programmatic encoding/decoding of raw pixel data to/from QOI byte streams and a CLI interface for file-based conversion. Key technical concerns include correct big-endian byte handling for header fields, proper state management of the pixel history array and previous pixel values across encoding/decoding passes, and selection of the optimal (smallest) chunk type during encoding to maximize compression.
</project_brief>

<spec_brief spec="QOI_CODEC">
Qoizig is a zero-dependency Zig 0.15.2+ command-line tool and library that implements a fully spec-compliant QOI (Quite OK Image) encoder and decoder, handling chunk compression, pixel history state tracking, Big Endian serialization, and unsigned 8-bit wraparound arithmetic. Its key responsibilities include reading PPM (P6) and PAM (P7) image files for encoding into the QOI byte format, decoding QOI files back to PPM/PAM, and managing the 14-byte header, data chunk stream, and 8-byte end marker structure with robust error handling. The module is self-contained with no external integrations beyond the Zig standard library, and its output is designed to be interoperable with the reference QOI implementation and test suite.
</spec_brief>

<specification_context>
### Overview

A high-performance, zero-dependency command-line tool and library implemented in Zig 0.15.2+ for the QOI (Quite OK Image) format. The tool provides encoding and decoding capabilities for QOI files, which are fast, lossless image formats. The implementation strictly adheres to the QOI specification, managing byte-ordering, chunk compression, and pixel history states without external dependencies.

### Goals

- Implement a fully compliant QOI encoder and decoder in Zig.
- Use only the Zig standard library (no third-party packages).
- Provide a CLI for converting between QOI and standard formats (PPM/PAM).
- Optimize for speed and minimal memory overhead.
- Ensure robust handling of Big Endian serialization required by the QOI spec.

### Constraints

- Target Zig version: 0.15.2 or higher.
- No external dependencies.
- The output QOI file must be exactly 14 bytes (header) + data chunks + 8 bytes (end marker).
- Pixel channel differences must use **unsigned 8-bit wraparound arithmetic** (e.g. `1 - 2 = 255`, `255 + 1 = 0`). Color channels are assumed to be un-premultiplied alpha.
- An image is complete when all `width * height` pixels have been covered; the decoder must not rely solely on the end marker to determine completion.
- Memory mapping is optional but preferred for large files to ensure speed.
</specification_context>

<task>
## Project Scaffold & Build Configuration

Configure build.zig to define the executable target ('qoizig') and a library module, plus set up the source directory structure. The zig init -m command has already created the basic project; this task customizes build.zig for our specific executable and test targets, and creates the top-level source file layout.

## Files to Produce

- `build.zig`
- `src/main.zig`
</task>