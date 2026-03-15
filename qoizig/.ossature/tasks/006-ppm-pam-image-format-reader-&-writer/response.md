The implementation is complete. Here's a summary of what `src/image_io.zig` provides:

**Types:**
- `ImageError` — error set covering invalid headers, unsupported formats, size mismatches, file not found, OOM, and I/O errors
- `ImageData` — struct holding width, height, channels (3 or 4), raw pixel data slice, and allocator with a `deinit()` method

**PPM P6 (RGB):**
- `readPpm(allocator, data)` — parses P6 header (magic, width, height, maxval=255), supports comments, validates size match, returns `ImageData` with channels=3
- `writePpm(allocator, width, height, pixels)` — produces a valid P6 binary file as a byte slice

**PAM P7 (RGBA):**
- `readPam(allocator, data)` — parses P7 header (WIDTH, HEIGHT, DEPTH=4, MAXVAL=255, TUPLTYPE=RGB_ALPHA, ENDHDR), validates constraints, returns `ImageData` with channels=4
- `writePam(allocator, width, height, pixels)` — produces a valid P7 file as a byte slice

**Convenience:**
- `readImage(allocator, data)` — auto-detects P6/P7 from magic bytes
- `writeImage(allocator, width, height, channels, pixels)` — dispatches to writePpm (channels=3) or writePam (channels=4)