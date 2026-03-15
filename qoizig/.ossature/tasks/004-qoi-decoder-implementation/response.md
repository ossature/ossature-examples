The implementation is complete. Here's a summary of what `src/decoder.zig` implements:

1. **Header validation**: Delegates to `QoiHeader.decode()` which checks magic bytes ("qoif"), channels (3/4), colorspace (0/1), and minimum size. Maps errors to `DecodeError` variants.

2. **Chunk processing**: Handles all 6 QOI chunk types:
   - `QOI_OP_RGB` (0xFE) — 4-byte chunk, reads R/G/B, alpha unchanged
   - `QOI_OP_RGBA` (0xFF) — 5-byte chunk, reads R/G/B/A
   - `QOI_OP_INDEX` (0b00xxxxxx) — 1-byte chunk, looks up pixel from 64-entry hash index
   - `QOI_OP_DIFF` (0b01xxxxxx) — 1-byte chunk, applies small wraparound diffs with bias 2
   - `QOI_OP_LUMA` (0b10xxxxxx) — 2-byte chunk, applies luma-based diff with biases 32/8
   - `QOI_OP_RUN` (0b11xxxxxx) — 1-byte chunk, repeats previous pixel 1-62 times (bias -1)

3. **8-bit tag precedence**: Checks for `QOI_OP_RGB`/`QOI_OP_RGBA` (8-bit tags) before 2-bit tags, per spec.

4. **State management**: Maintains the 64-entry running pixel hash index (zero-initialized) and previous pixel (starting at `{0,0,0,255}`).

5. **Pixel-count completion**: Loop terminates when `width * height` pixels are decoded, not based on end marker.

6. **End marker verification**: After all pixels decoded, verifies the 8-byte end marker `[0,0,0,0,0,0,0,1]`.

7. **Wraparound arithmetic**: Uses Zig's `+%` and `-%` operators for unsigned 8-bit wraparound.