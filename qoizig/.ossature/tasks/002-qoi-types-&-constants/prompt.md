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
### QOI Format Fundamentals

The implementation must handle the QOI file format, which consists of a 14-byte header, data chunks, and an 8-byte end marker.

**Accepts:** - Raw pixel data (as an array of RGBA or RGB values) for encoding.

**Returns:** - A QOI byte stream when encoding.

### Constraints

- Target Zig version: 0.15.2 or higher.
- No external dependencies.
- The output QOI file must be exactly 14 bytes (header) + data chunks + 8 bytes (end marker).
- Pixel channel differences must use **unsigned 8-bit wraparound arithmetic** (e.g. `1 - 2 = 255`, `255 + 1 = 0`). Color channels are assumed to be un-premultiplied alpha.
- An image is complete when all `width * height` pixels have been covered; the decoder must not rely solely on the end marker to determine completion.
- Memory mapping is optional but preferred for large files to ensure speed.

### Acceptance Criteria

- Encoder produces QOI files verifiable by the reference [qoibench](https://github.com/phoboslab/qoi) implementation.
- Decoder successfully reconstructs pixels from the reference QOI test suite.
- All Big Endian integers (width, height, specific chunks) are serialized correctly.
- The pixel index hash function produces identical looking results to the reference spec.
- End marker is correctly appended to every encoded file.
- Exit code 0 on success, 1 on CLI argument or file processing errors.
</specification_context>

<dependency_files>
The following files from previous tasks are available. Use `grep_file` and `read_lines` to inspect the types, interfaces, and signatures you need.

- `build.zig` (`application/octet-stream`, 1996 bytes, binary)
- `src/main.zig` (`application/octet-stream`, 1560 bytes, binary)
</dependency_files>

<context_files>
The following files from the project's context directory are assigned to this task. Use `copy_context_file(context_path, dest_path)` to copy assets into the appropriate location within the output directory (choose a destination path that fits the project structure, e.g. `assets/audio/music.mp3` or `sounds/correct.wav`). Use `read_context_file(context_path)` to read text files on demand.

### qoi_specification.md

**MIME type:** `text/markdown` (5555 bytes)

```
# The Quite OK Image Format (QOI) Specification

**Version 1.0, 2022.01.05**  
**qoiformat.org**  
**Dominic Szablewski**

---

## Overview

A QOI file consists of a **14-byte header**, followed by any number of data "chunks" and an **8-byte end marker**.

---

## File Header

```c
qoi_header {
    char     magic[4];   // magic bytes "qoif"
    uint32_t width;      // image width in pixels (BE)
    uint32_t height;     // image height in pixels (BE)
    uint8_t  channels;   // 3 = RGB, 4 = RGBA
    uint8_t  colorspace; // 0 = sRGB with linear alpha
                         // 1 = all channels linear
};
```

The colorspace and channel fields are purely informative. They do not change the way data chunks are encoded.

---

## Encoding Principles

Images are encoded **row by row, left to right, top to bottom**. The decoder and encoder start with `{r: 0, g: 0, b: 0, a: 255}` as the previous pixel value. An image is complete when all pixels specified by `width * height` have been covered.

Pixels are encoded as:
- A run of the previous pixel
- An index into an array of previously seen pixels
- A difference to the previous pixel value in r,g,b
- Full r,g,b or r,g,b,a values

The color channels are assumed to **not be premultiplied** with the alpha channel ("un-premultiplied alpha").

### Index Array

A running `array[64]` (zero-initialized) of previously seen pixel values is maintained by the encoder and decoder. Each pixel that is seen by the encoder and decoder is put into this array at the position formed by a hash function of the color value. In the encoder, if the pixel value at the index matches the current pixel, this index position is written to the stream as **QOI_OP_INDEX**.

The hash function for the index is:

```
index_position = (r * 3 + g * 5 + b * 7 + a * 11) % 64
```

---

## Chunk Format

Each chunk starts with a **2- or 8-bit tag**, followed by a number of data bits. The bit length of chunks is divisible by 8 — i.e. all chunks are byte aligned. All values encoded in these data bits have the most significant bit on the left.

The **8-bit tags have precedence** over the 2-bit tags. A decoder must check for the presence of an 8-bit tag first.

The byte stream's end is marked with **7 `0x00` bytes followed by a single `0x01` byte**.

---

## Data Chunk Types

### QOI_OP_RGB

| Byte[0] | Byte[1] | Byte[2] | Byte[3] |
|---------|---------|---------|---------|
| 7 6 5 4 3 2 1 0 | 7 .. 0 | 7 .. 0 | 7 .. 0 |
| 1 1 1 1 1 1 1 0 | red | green | blue |

- **8-bit tag:** `b11111110`
- **8-bit red** channel value
- **8-bit green** channel value
- **8-bit blue** channel value

The alpha value remains unchanged from the previous pixel.

---

### QOI_OP_RGBA

| Byte[0] | Byte[1] | Byte[2] | Byte[3] | Byte[4] |
|---------|---------|---------|---------|---------|
| 7 6 5 4 3 2 1 0 | 7 .. 0 | 7 .. 0 | 7 .. 0 | 7 .. 0 |
| 1 1 1 1 1 1 1 1 | red | green | blue | alpha |

- **8-bit tag:** `b11111111`
- **8-bit red** channel value
- **8-bit green** channel value
- **8-bit blue** channel value
- **8-bit alpha** channel value

---

### QOI_OP_INDEX

| Byte[0] |
|---------|
| 7 6 5 4 3 2 1 0 |
| 0 0 | index |

- **2-bit tag:** `b00`
- **6-bit index** into the color index array: 0..63

A valid encoder must not issue 2 or more consecutive QOI_OP_INDEX chunks to the same index. QOI_OP_RUN should be used instead.

---

### QOI_OP_DIFF

| Byte[0] |
|---------|
| 7 6 5 4 3 2 1 0 |
| 0 1 | dr | dg | db |

- **2-bit tag:** `b01`
- **2-bit red** channel difference from the previous pixel: -2..1
- **2-bit green** channel difference from the previous pixel: -2..1
- **2-bit blue** channel difference from the previous pixel: -2..1

The difference to the current channel values are using a **wraparound operation**, so `1 - 2` will result in `255`, while `255 + 1` will result in `0`.

Values are stored as unsigned integers with a **bias of 2**. E.g. -2 is stored as 0 (`b00`), 1 is stored as 3 (`b11`).

The alpha value remains unchanged from the previous pixel.

---

### QOI_OP_LUMA

| Byte[0] | Byte[1] |
|---------|---------|
| 7 6 5 4 3 2 1 0 | 7 6 5 4 3 2 1 0 |
| 1 0 | diff green | dr - dg | db - dg |

- **2-bit tag:** `b10`
- **6-bit green** channel difference from the previous pixel: -32..31
- **4-bit red** channel difference minus green channel difference: -8..7
- **4-bit blue** channel difference minus green channel difference: -8..7

The green channel is used to indicate the general direction of change and is encoded in 6 bits. The red and blue channels (dr and db) base their diffs off of the green channel difference:

```
dr_dg = (cur_px.r - prev_px.r) - (cur_px.g - prev_px.g)
db_dg = (cur_px.b - prev_px.b) - (cur_px.g - prev_px.g)
```

The difference to the current channel values are using a **wraparound operation**, so `10 - 13` will result in `253`, while `250 + 7` will result in `1`.

Values are stored as unsigned integers with a **bias of 32** for the green channel and a **bias of 8** for the red and blue channel.

The alpha value remains unchanged from the previous pixel.

---

### QOI_OP_RUN

| Byte[0] |
|---------|
| 7 6 5 4 3 2 1 0 |
| 1 1 | run |

- **2-bit tag:** `b11`
- **6-bit run-length** repeating the previous pixel: 1..62

The run-length is stored with a **bias of -1**. Note that the run-lengths 63 and 64 (`b111110` and `b111111`) are illegal as they are occupied by the QOI_OP_RGB and QOI_OP_RGBA tags.

---

## End Marker

The byte stream's end is marked with:

```
0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x01
```

(7 zero bytes followed by a single `0x01` byte)

```
</context_files>

<task>
## QOI Types & Constants

Define all QOI-related data types: the QoiHeader struct (magic, width, height, channels, colorspace), chunk tag constants (QOI_OP_RGB, QOI_OP_RGBA, QOI_OP_INDEX, QOI_OP_DIFF, QOI_OP_LUMA, QOI_OP_RUN), the 8-byte end marker, the pixel hash function, and the Pixel (RGBA) struct with wraparound arithmetic helpers. This is the foundational data model used by both encoder and decoder.

## Files to Produce

- `src/qoi.zig`
</task>