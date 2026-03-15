# Interface: QOI_CODEC

@source: build

# QOI_CODEC Public Interface

## src/qoi.zig

```zig
// Sub-module re-exports
pub const encoder = @import("encoder.zig");
pub const decoder = @import("decoder.zig");
pub const image_io = @import("image_io.zig");

// Chunk tag constants

/// 8-bit tag: 0b11111110 — full RGB pixel follows.
pub const QOI_OP_RGB: u8 = 0xfe;

/// 8-bit tag: 0b11111111 — full RGBA pixel follows.
pub const QOI_OP_RGBA: u8 = 0xff;

/// 2-bit tag: 0b00 — index into the 64-entry pixel array.
pub const QOI_OP_INDEX: u8 = 0x00;

/// 2-bit tag: 0b01 — small diff in r, g, b (each ±1 around bias 2).
pub const QOI_OP_DIFF: u8 = 0x40;

/// 2-bit tag: 0b10 — luma-based diff (6-bit green + 4-bit dr-dg, db-dg).
pub const QOI_OP_LUMA: u8 = 0x80;

/// 2-bit tag: 0b11 — run-length encoding (1..62, stored with bias -1).
pub const QOI_OP_RUN: u8 = 0xc0;

/// Mask for extracting the 2-bit tag from a byte.
pub const QOI_MASK_2: u8 = 0xc0;

/// Size of the running pixel index array.
pub const QOI_INDEX_SIZE: usize = 64;

/// Magic bytes "qoif".
pub const QOI_MAGIC = [4]u8{ 'q', 'o', 'i', 'f' };

/// Header size in bytes.
pub const QOI_HEADER_SIZE: usize = 14;

/// 8-byte end marker: 7× 0x00 followed by 0x01.
pub const QOI_END_MARKER = [8]u8{ 0, 0, 0, 0, 0, 0, 0, 1 };

pub const Pixel = struct {
    r: u8 = 0,
    g: u8 = 0,
    b: u8 = 0,
    a: u8 = 255,

    /// The initial/previous pixel value at the start of encoding/decoding.
    pub const default: Pixel = .{ .r = 0, .g = 0, .b = 0, .a = 255 };

    pub fn eql(self: Pixel, other: Pixel) bool { ... }

    /// QOI hash: `(r*3 + g*5 + b*7 + a*11) % 64`
    pub fn hash(self: Pixel) u6 { ... }

    /// Wraparound difference: `a -% b` for each channel.
    pub fn diff(self: Pixel, prev: Pixel) ChannelDiff { ... }

    /// Apply a wraparound diff to produce a new pixel.
    pub fn addDiff(self: Pixel, d: ChannelDiff) Pixel { ... }
};

/// Raw per-channel difference values (unsigned, wrapping).
pub const ChannelDiff = struct {
    dr: u8,
    dg: u8,
    db: u8,
    da: u8,

    /// Returns true when the diff fits in QOI_OP_DIFF (2-bit per channel, bias 2).
    pub fn fitsSmallDiff(self: ChannelDiff) bool { ... }

    /// Returns true when the diff fits in QOI_OP_LUMA.
    pub fn fitsLumaDiff(self: ChannelDiff) bool { ... }
};

pub const Colorspace = enum(u8) {
    srgb = 0,
    linear = 1,
};

pub const Channels = enum(u8) {
    rgb = 3,
    rgba = 4,
};

pub const QoiHeader = struct {
    width: u32,
    height: u32,
    channels: Channels,
    colorspace: Colorspace,

    /// Total number of pixels in the image.
    pub fn pixelCount(self: QoiHeader) usize { ... }

    /// Encode the header into a 14-byte array (big-endian).
    pub fn encode(self: QoiHeader) [QOI_HEADER_SIZE]u8 { ... }

    /// Decode a header from a byte slice (must be at least 14 bytes).
    pub fn decode(data: []const u8) error{ InvalidMagic, InvalidChannels, InvalidColorspace, UnexpectedEndOfData }!QoiHeader { ... }
};
```

## src/encoder.zig

```zig
const qoi = @import("qoi.zig");

/// Encode raw pixel data into a complete QOI byte stream.
///
/// `pixels` must contain exactly `width * height * channels` bytes of
/// interleaved RGB or RGBA data (depending on `channels`).
///
/// Returns an owned slice allocated with `allocator`. Caller must free it.
pub fn encode(
    allocator: std.mem.Allocator,
    pixels: []const u8,
    width: u32,
    height: u32,
    channels: qoi.Channels,
    colorspace: qoi.Colorspace,
) error{ InvalidPixelDataLength, OutOfMemory }![]u8 { ... }
```

## src/decoder.zig

```zig
const qoi = @import("qoi.zig");

pub const DecodeError = error{
    InvalidMagic,
    InvalidChannels,
    InvalidColorspace,
    UnexpectedEndOfData,
    InvalidDimensions,
    InvalidEndMarker,
    ExcessData,
};

pub const DecodeResult = struct {
    header: qoi.QoiHeader,
    pixels: []qoi.Pixel,

    pub fn deinit(self: *DecodeResult, allocator: std.mem.Allocator) void { ... }
};

/// Decode a QOI byte stream into pixel data.
///
/// The `data` slice must contain the full QOI file: 14-byte header, data chunks,
/// and 8-byte end marker.
///
/// Returns the decoded header and pixel array (caller owns the allocation).
pub fn decode(allocator: std.mem.Allocator, data: []const u8) DecodeError!DecodeResult { ... }
```

## src/image_io.zig

```zig
/// Errors that can occur during PPM/PAM parsing or writing.
pub const ImageError = error{
    InvalidHeader,
    UnsupportedFormat,
    SizeMismatch,
    FileNotFound,
    OutOfMemory,
    IoError,
};

/// Raw image data with metadata.
pub const ImageData = struct {
    width: u32,
    height: u32,
    channels: u8,
    pixels: []u8,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *ImageData) void { ... }
};

/// Read a PPM P6 (binary RGB) file from raw bytes.
pub fn readPpm(allocator: std.mem.Allocator, data: []const u8) ImageError!ImageData { ... }

/// Read a PAM P7 (RGBA) file from raw bytes.
pub fn readPam(allocator: std.mem.Allocator, data: []const u8) ImageError!ImageData { ... }

/// Write raw RGB pixel data as a PPM P6 file.
pub fn writePpm(allocator: std.mem.Allocator, width: u32, height: u32, pixels: []const u8) ImageError![]u8 { ... }

/// Write raw RGBA pixel data as a PAM P7 file.
pub fn writePam(allocator: std.mem.Allocator, width: u32, height: u32, pixels: []const u8) ImageError![]u8 { ... }

/// Detect format from magic bytes and read accordingly.
pub fn readImage(allocator: std.mem.Allocator, data: []const u8) ImageError!ImageData { ... }

/// Write image data to the appropriate format based on channel count.
/// channels=3 -> PPM P6, channels=4 -> PAM P7.
pub fn writeImage(allocator: std.mem.Allocator, width: u32, height: u32, channels: u8, pixels: []const u8) ImageError![]u8 { ... }
```

## src/main.zig

```zig
pub fn main() void { ... }
```