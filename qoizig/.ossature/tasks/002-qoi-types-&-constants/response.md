Build and all tests pass. The implementation covers:

- **`Pixel` struct** with default `{0, 0, 0, 255}`, equality check, hash function `(r*3 + g*5 + b*7 + a*11) % 64`, wraparound diff/addDiff helpers
- **`ChannelDiff`** with `fitsSmallDiff()` (QOI_OP_DIFF range check) and `fitsLumaDiff()` (QOI_OP_LUMA range check)
- **`QoiHeader`** with `encode()` (14-byte big-endian serialization), `decode()` (with error handling for invalid magic, channels, colorspace, and short data), and `pixelCount()`
- **All chunk tag constants**: `QOI_OP_RGB` (0xfe), `QOI_OP_RGBA` (0xff), `QOI_OP_INDEX` (0x00), `QOI_OP_DIFF` (0x40), `QOI_OP_LUMA` (0x80), `QOI_OP_RUN` (0xc0)
- **`QOI_MASK_2`** (0xc0) for 2-bit tag extraction
- **`QOI_MAGIC`** ("qoif"), **`QOI_HEADER_SIZE`** (14), **`QOI_INDEX_SIZE`** (64), **`QOI_END_MARKER`** (7× 0x00 + 0x01)
- **`Channels`** and **`Colorspace`** enums