All 80 tests pass (51 from `codec_test.zig` + 29 transitively from the imported modules). The test file covers all required areas:

- **Round-trip encode→decode**: 1×1, 2×2, gradient, solid color, varying alpha, non-square, large images
- **Big Endian header serialization**: manual byte verification for known values (1920×1080, 0x01020304×0x05060708)
- **Pixel hash correctness**: reference formula verification for multiple pixel values, range check across many values
- **All chunk types**: QOI_OP_INDEX, QOI_OP_DIFF, QOI_OP_LUMA, QOI_OP_RUN, QOI_OP_RGB, QOI_OP_RGBA — with byte-level verification of encoded output
- **Wraparound arithmetic**: 1−2=255, 255+1=0, 0−1=255, 128−130=254, cross-boundary round-trips
- **End marker**: value verification, presence at end of every encoded file
- **Error cases**: invalid magic, truncated data (multiple variants), invalid end marker, invalid channels/colorspace, invalid pixel data length, zero dimensions, mid-chunk truncation