const std = @import("std");

// ── Sub-module re-exports ─────────────────────────────────────────────────────

pub const encoder = @import("encoder.zig");
pub const decoder = @import("decoder.zig");
pub const image_io = @import("image_io.zig");

// ── Chunk tag constants ──────────────────────────────────────────────────────

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

// ── Pixel (RGBA) ─────────────────────────────────────────────────────────────

pub const Pixel = struct {
    r: u8 = 0,
    g: u8 = 0,
    b: u8 = 0,
    a: u8 = 255,

    /// The initial/previous pixel value at the start of encoding/decoding.
    pub const default: Pixel = .{ .r = 0, .g = 0, .b = 0, .a = 255 };

    pub fn eql(self: Pixel, other: Pixel) bool {
        return self.r == other.r and self.g == other.g and self.b == other.b and self.a == other.a;
    }

    /// QOI hash: `(r*3 + g*5 + b*7 + a*11) % 64`
    pub fn hash(self: Pixel) u6 {
        const val = @as(u32, self.r) *% 3 +%
            @as(u32, self.g) *% 5 +%
            @as(u32, self.b) *% 7 +%
            @as(u32, self.a) *% 11;
        return @truncate(val % QOI_INDEX_SIZE);
    }

    // ── Wraparound arithmetic helpers ────────────────────────────────────

    /// Wraparound difference: `a -% b` for each channel.
    pub fn diff(self: Pixel, prev: Pixel) ChannelDiff {
        return .{
            .dr = self.r -% prev.r,
            .dg = self.g -% prev.g,
            .db = self.b -% prev.b,
            .da = self.a -% prev.a,
        };
    }

    /// Apply a wraparound diff to produce a new pixel.
    pub fn addDiff(self: Pixel, d: ChannelDiff) Pixel {
        return .{
            .r = self.r +% d.dr,
            .g = self.g +% d.dg,
            .b = self.b +% d.db,
            .a = self.a +% d.da,
        };
    }
};

/// Raw per-channel difference values (unsigned, wrapping).
pub const ChannelDiff = struct {
    dr: u8,
    dg: u8,
    db: u8,
    da: u8,

    /// Returns true when the diff fits in QOI_OP_DIFF (2-bit per channel, bias 2).
    /// Each channel difference, interpreted as a signed value in -128..127, must be in -2..1.
    /// Equivalently the unsigned byte must be in {254, 255, 0, 1} i.e. (val +% 2) < 4.
    pub fn fitsSmallDiff(self: ChannelDiff) bool {
        return self.da == 0 and
            (self.dr +% 2) < 4 and
            (self.dg +% 2) < 4 and
            (self.db +% 2) < 4;
    }

    /// Returns true when the diff fits in QOI_OP_LUMA.
    /// Green channel diff (as signed) must be in -32..31, i.e. (dg +% 32) < 64.
    /// (dr - dg) and (db - dg) as signed must be in -8..7, i.e. (val +% 8) < 16.
    pub fn fitsLumaDiff(self: ChannelDiff) bool {
        if (self.da != 0) return false;
        if ((self.dg +% 32) >= 64) return false;
        const dr_dg = self.dr -% self.dg;
        const db_dg = self.db -% self.dg;
        return (dr_dg +% 8) < 16 and (db_dg +% 8) < 16;
    }
};

// ── QOI Header ───────────────────────────────────────────────────────────────

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
    pub fn pixelCount(self: QoiHeader) usize {
        return @as(usize, self.width) * @as(usize, self.height);
    }

    /// Encode the header into a 14-byte array (big-endian).
    pub fn encode(self: QoiHeader) [QOI_HEADER_SIZE]u8 {
        var buf: [QOI_HEADER_SIZE]u8 = undefined;
        @memcpy(buf[0..4], &QOI_MAGIC);
        std.mem.writeInt(u32, buf[4..8], self.width, .big);
        std.mem.writeInt(u32, buf[8..12], self.height, .big);
        buf[12] = @intFromEnum(self.channels);
        buf[13] = @intFromEnum(self.colorspace);
        return buf;
    }

    /// Decode a header from a byte slice (must be at least 14 bytes).
    /// Returns error on invalid magic or channel/colorspace values.
    pub fn decode(data: []const u8) error{ InvalidMagic, InvalidChannels, InvalidColorspace, UnexpectedEndOfData }!QoiHeader {
        if (data.len < QOI_HEADER_SIZE) return error.UnexpectedEndOfData;
        if (!std.mem.eql(u8, data[0..4], &QOI_MAGIC)) return error.InvalidMagic;

        const channels: Channels = std.meta.intToEnum(Channels, data[12]) catch return error.InvalidChannels;
        const colorspace: Colorspace = std.meta.intToEnum(Colorspace, data[13]) catch return error.InvalidColorspace;

        return .{
            .width = std.mem.readInt(u32, data[4..8], .big),
            .height = std.mem.readInt(u32, data[8..12], .big),
            .channels = channels,
            .colorspace = colorspace,
        };
    }
};

// ── Tests ────────────────────────────────────────────────────────────────────

test "pixel hash matches reference" {
    // The spec hash: (r*3 + g*5 + b*7 + a*11) % 64
    const px = Pixel{ .r = 128, .g = 64, .b = 32, .a = 255 };
    const expected: u6 = @truncate((@as(u32, 128) * 3 + @as(u32, 64) * 5 + @as(u32, 32) * 7 + @as(u32, 255) * 11) % 64);
    try std.testing.expectEqual(expected, px.hash());
}

test "pixel default" {
    const px = Pixel.default;
    try std.testing.expectEqual(@as(u8, 0), px.r);
    try std.testing.expectEqual(@as(u8, 0), px.g);
    try std.testing.expectEqual(@as(u8, 0), px.b);
    try std.testing.expectEqual(@as(u8, 255), px.a);
}

test "wraparound diff" {
    const a = Pixel{ .r = 1, .g = 2, .b = 0, .a = 255 };
    const b = Pixel{ .r = 2, .g = 0, .b = 1, .a = 255 };
    const d = a.diff(b); // 1-2=255, 2-0=2, 0-1=255, 255-255=0
    try std.testing.expectEqual(@as(u8, 255), d.dr);
    try std.testing.expectEqual(@as(u8, 2), d.dg);
    try std.testing.expectEqual(@as(u8, 255), d.db);
    try std.testing.expectEqual(@as(u8, 0), d.da);
}

test "fitsSmallDiff" {
    // diff of -2,-1,0,1 should fit
    const d1 = ChannelDiff{ .dr = 254, .dg = 255, .db = 0, .da = 0 }; // -2, -1, 0
    try std.testing.expect(d1.fitsSmallDiff());

    // diff of -3 should not fit
    const d2 = ChannelDiff{ .dr = 253, .dg = 0, .db = 0, .da = 0 };
    try std.testing.expect(!d2.fitsSmallDiff());

    // alpha changed should not fit
    const d3 = ChannelDiff{ .dr = 0, .dg = 0, .db = 0, .da = 1 };
    try std.testing.expect(!d3.fitsSmallDiff());
}

test "fitsLumaDiff" {
    // green = 5, dr = 6, db = 4 → dr-dg=1, db-dg=-1 → fits
    const d1 = ChannelDiff{ .dr = 6, .dg = 5, .db = 4, .da = 0 };
    try std.testing.expect(d1.fitsLumaDiff());

    // green = 33 → 33+32=65 ≥ 64, does not fit
    const d2 = ChannelDiff{ .dr = 33, .dg = 33, .db = 33, .da = 0 };
    try std.testing.expect(!d2.fitsLumaDiff());
}

test "header round-trip" {
    const hdr = QoiHeader{
        .width = 1920,
        .height = 1080,
        .channels = .rgba,
        .colorspace = .srgb,
    };
    const bytes = hdr.encode();
    const decoded = try QoiHeader.decode(&bytes);
    try std.testing.expectEqual(hdr.width, decoded.width);
    try std.testing.expectEqual(hdr.height, decoded.height);
    try std.testing.expectEqual(hdr.channels, decoded.channels);
    try std.testing.expectEqual(hdr.colorspace, decoded.colorspace);
}

test "header decode invalid magic" {
    var bytes = (QoiHeader{
        .width = 1,
        .height = 1,
        .channels = .rgb,
        .colorspace = .srgb,
    }).encode();
    bytes[0] = 'x';
    try std.testing.expectError(error.InvalidMagic, QoiHeader.decode(&bytes));
}

test "header decode too short" {
    const bytes = [_]u8{ 'q', 'o', 'i', 'f', 0, 0 };
    try std.testing.expectError(error.UnexpectedEndOfData, QoiHeader.decode(&bytes));
}

test "end marker value" {
    try std.testing.expectEqual([8]u8{ 0, 0, 0, 0, 0, 0, 0, 1 }, QOI_END_MARKER);
}

test "tag constants" {
    try std.testing.expectEqual(@as(u8, 0xfe), QOI_OP_RGB);
    try std.testing.expectEqual(@as(u8, 0xff), QOI_OP_RGBA);
    try std.testing.expectEqual(@as(u8, 0x00), QOI_OP_INDEX);
    try std.testing.expectEqual(@as(u8, 0x40), QOI_OP_DIFF);
    try std.testing.expectEqual(@as(u8, 0x80), QOI_OP_LUMA);
    try std.testing.expectEqual(@as(u8, 0xc0), QOI_OP_RUN);
}

test "pixel equality" {
    const a = Pixel{ .r = 10, .g = 20, .b = 30, .a = 40 };
    const b = Pixel{ .r = 10, .g = 20, .b = 30, .a = 40 };
    const c = Pixel{ .r = 10, .g = 20, .b = 30, .a = 41 };
    try std.testing.expect(a.eql(b));
    try std.testing.expect(!a.eql(c));
}

test "addDiff round-trip" {
    const prev = Pixel{ .r = 100, .g = 200, .b = 50, .a = 255 };
    const curr = Pixel{ .r = 99, .g = 201, .b = 48, .a = 255 };
    const d = curr.diff(prev);
    const restored = prev.addDiff(d);
    try std.testing.expect(restored.eql(curr));
}
