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
### Encode Command (`qoizig encode`)

Reads a source image file (PPM P6 for RGB, PAM P7 for RGBA) and encodes it into a QOI file.

**Accepts:** - `input` (positional, required): Path to the source PPM/PAM file.

**Returns:** - A QOI file written to disk.

**Errors:**

- Input file not found -> print error and exit code 1.
- Invalid PPM/PAM header -> print error and exit code 1.
- Mismatch between declared size and actual data -> print error and exit code 1.

### Decode Command (`qoizig decode`)

Reads a QOI file and decodes it to a standard image format (PPM P6 for RGB, PAM P7 for RGBA).

**Accepts:** - `input` (positional, required): Path to the QOI file.

**Returns:** - A PPM or PAM file written to disk.

**Errors:**

- Invalid Magic Bytes -> print error "Not a QOI file" and exit code 1.
- Truncated file / Unexpected EOF -> print error and exit code 1.
- Invalid stream of chunks -> print error and exit code 1.

### Constraints

- Target Zig version: 0.15.2 or higher.
- No external dependencies.
- The output QOI file must be exactly 14 bytes (header) + data chunks + 8 bytes (end marker).
- Pixel channel differences must use **unsigned 8-bit wraparound arithmetic** (e.g. `1 - 2 = 255`, `255 + 1 = 0`). Color channels are assumed to be un-premultiplied alpha.
- An image is complete when all `width * height` pixels have been covered; the decoder must not rely solely on the end marker to determine completion.
- Memory mapping is optional but preferred for large files to ensure speed.
</specification_context>

<dependency_files>
The following files from previous tasks are available. Use `grep_file` and `read_lines` to inspect the types, interfaces, and signatures you need.

- `build.zig` (`application/octet-stream`, 2398 bytes, binary)
- `src/main.zig` (`application/octet-stream`, 1560 bytes, binary)
</dependency_files>

<task>
## PPM/PAM Image Format Reader & Writer

Implement readers and writers for PPM P6 (binary RGB) and PAM P7 (RGBA) image formats. The PPM reader parses the P6 header (magic, width, height, maxval) and extracts raw RGB pixel data. The PAM reader parses the P7 header (WIDTH, HEIGHT, DEPTH, MAXVAL, TUPLTYPE) and extracts raw RGBA pixel data. Writers produce valid PPM P6 or PAM P7 files from raw pixel data. Include validation for malformed headers and size mismatches. The format choice for decode output is determined by the QOI header's channel count (3=PPM, 4=PAM).

## Files to Produce

- `src/image_io.zig`
</task>