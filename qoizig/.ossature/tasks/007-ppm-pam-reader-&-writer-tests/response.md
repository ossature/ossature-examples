All 70 tests pass (61 from `image_io_test.zig` plus 9 from the inline tests in `image_io.zig`). The test file covers:

- **Round-trip write-then-read** for both PPM P6 and PAM P7 (single pixel, multi-pixel, larger images, all-zero, all-255)
- **Header parsing edge cases**: comments, multiple comments, different whitespace (spaces, tabs), PAM header fields in different order, optional TUPLTYPE
- **Error handling for invalid headers**: wrong magic bytes, empty input, truncated headers, missing required fields (WIDTH/HEIGHT/DEPTH/MAXVAL)
- **Size mismatches**: too little data, too much data, no pixel data at all (for both readers and writers)
- **Maxval handling**: unsupported maxval values (0, 128, 65535)
- **Auto-detect readImage/writeImage**: format dispatch, unsupported formats, channel count validation
- **Writer output format verification**: checking exact header format
- **PAM trailing data tolerance**