All tests pass. The implementation covers:

1. **14-byte header** with Big Endian width/height, channel count, and colorspace
2. **All 6 chunk types**: QOI_OP_RUN, QOI_OP_INDEX, QOI_OP_DIFF, QOI_OP_LUMA, QOI_OP_RGB, QOI_OP_RGBA
3. **64-entry running pixel index** with the spec hash function `(r*3 + g*5 + b*7 + a*11) % 64`
4. **Optimal chunk selection** — tries smallest encoding first (run → index → diff → luma → rgb → rgba)
5. **Unsigned 8-bit wraparound arithmetic** via Zig's `+%` and `-%` operators
6. **8-byte end marker** appended after all pixel data
7. **Run length capping at 62** (since 63/64 are reserved for RGB/RGBA tags)
8. **Error handling** for invalid pixel data length
9. **RGB and RGBA** channel support (RGB inherits alpha from previous pixel)
10. **No consecutive QOI_OP_INDEX to same index** — naturally prevented since identical pixels trigger QOI_OP_RUN instead