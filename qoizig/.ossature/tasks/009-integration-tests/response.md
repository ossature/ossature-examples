All 237 tests pass across all 5 test suites (75 from the integration test). Here's a summary of what `src/integration_test.zig` covers:

**Full pipeline tests (library API):**
- PPM → encode → QOI → decode → PPM round-trip (RGB)
- PAM → encode → QOI → decode → PAM round-trip (RGBA)

**File I/O round-trip tests:**
- Write PPM to temp file → encode to QOI → decode back to PPM → compare pixel data
- Write PAM to temp file → encode to QOI → decode back to PAM → compare pixel data

**Error path tests:**
- Corrupt PPM header, corrupt PAM header, non-image file
- Truncated QOI data, corrupted QOI magic bytes, corrupted end marker
- Wrong pixel data length for encoder
- PPM with size mismatch, empty data, partial header
- Invalid channels/colorspace in QOI header, zero dimensions

**CLI invocation tests** (child process via `std.process.Child.run`):
- `encode` PPM → QOI succeeds (exit code 0, correct output message)
- `decode` QOI → PAM succeeds (exit code 0, correct output message)
- Full round-trip: PPM → QOI → PPM via CLI
- Error: non-existent input file (exit code 1)
- Error: corrupt header input (exit code 1, "Error: Invalid PPM/PAM header")
- Error: truncated QOI file (exit code 1)
- Error: invalid command (exit code 1)
- Error: missing arguments (exit code 1)
- Error: non-QOI file for decode (exit code 1, "Error: Not a QOI file")

**Large/stress tests:**
- 256×256 gradient image, 128×128 RGBA with varying alpha
- Solid color image (high compression verification)

**Edge cases:**
- 1×N and N×1 images
- Single pixel with each chunk type
- Big-endian header verification
- QOI output structure (header + data + end marker)