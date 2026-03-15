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
## Examples

### Encoding a PPM to QOI

**Input:**

```
qoizig encode assets/dice.ppm dice.qoi
```

**Output:**

```
Encoded 800x600 image to dice.qoi
```

### Decoding a QOI to PAM (RGBA)

**Input:**

```
qoizig decode dice.qoi dice_rgba.pam
```

**Output:**

```
Decoded 800x600 image to dice_rgba.pam
```

### Handling Errors

**Input:**

```
qoizig encode corrupt.txt out.qoi
```

**Output:**

```
Error: Invalid PPM/PAM header
```

### Handling Errors

**Input:**

```
qoizig encode corrupt.txt out.qoi
```

**Output:**

```
Error: Invalid PPM/PAM header
```

### Acceptance Criteria

- Encoder produces QOI files verifiable by the reference [qoibench](https://github.com/phoboslab/qoi) implementation.
- Decoder successfully reconstructs pixels from the reference QOI test suite.
- All Big Endian integers (width, height, specific chunks) are serialized correctly.
- The pixel index hash function produces identical looking results to the reference spec.
- End marker is correctly appended to every encoded file.
- Exit code 0 on success, 1 on CLI argument or file processing errors.

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

- `build.zig` (`application/octet-stream`, 2807 bytes, binary)
- `src/main.zig` (`application/octet-stream`, 6047 bytes, binary)
- `src/qoi.zig` (`application/octet-stream`, 10383 bytes, binary)
- `src/encoder.zig` (`application/octet-stream`, 11246 bytes, binary)
- `src/decoder.zig` (`application/octet-stream`, 13567 bytes, binary)
- `src/image_io.zig` (`application/octet-stream`, 14727 bytes, binary)
- `src/main.zig` (`application/octet-stream`, 6047 bytes, binary)
</dependency_files>

<task>
## Integration Tests

Create end-to-end integration tests that exercise the full pipeline: generate synthetic PPM and PAM images in memory, write them to temp files, invoke the encoder to produce QOI files, invoke the decoder to reconstruct PPM/PAM files, and verify the reconstructed pixel data matches the original. Also tests error paths: non-existent files, corrupt headers, truncated QOI data. Verifies exit codes and output messages match the spec examples.

## Files to Produce

- `src/integration_test.zig`
</task>