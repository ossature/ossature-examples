const std = @import("std");

comptime {
    _ = @import("stubs.zig");
}

/// QOI file header (14 bytes)
pub const QoiHeader = struct {
    pub const magic_bytes: [4]u8 = "qoif".*;
    pub const size_bytes: usize = 14;

    /// Image width in pixels
    width: u32,
    /// Image height in pixels
    height: u32,
    /// Number of channels: 3 = RGB, 4 = RGBA
    channels: u8,
    /// Colorspace: 0 = sRGB with linear alpha, 1 = all channels linear
    colorspace: u8,

    /// Validate the header fields according to the QOI specification.
    pub fn validate(self: QoiHeader) Error!void {
        if (self.width == 0 or self.height == 0) {
            return Error.InvalidDimensions;
        }
        if (self.channels != 3 and self.channels != 4) {
            return Error.InvalidChannels;
        }
        if (self.colorspace != 0 and self.colorspace != 1) {
            return Error.InvalidColorspace;
        }
    }

    /// Serializes the header into a 14-byte array in big-endian format.
    pub fn serialize(self: QoiHeader) [size_bytes]u8 {
        var bytes: [size_bytes]u8 = undefined;
        @memcpy(bytes[0..4], &magic_bytes);
        std.mem.writeInt(u32, bytes[4..8], self.width, .big);
        std.mem.writeInt(u32, bytes[8..12], self.height, .big);
        bytes[12] = self.channels;
        bytes[13] = self.colorspace;
        return bytes;
    }

    /// Deserializes a header from a 14-byte array.
    pub fn deserialize(bytes: [size_bytes]u8) Error!QoiHeader {
        if (!std.mem.eql(u8, bytes[0..4], &magic_bytes)) {
            return Error.InvalidMagic;
        }
        const width = std.mem.readInt(u32, bytes[4..8], .big);
        const height = std.mem.readInt(u32, bytes[8..12], .big);
        const channels = bytes[12];
        const colorspace = bytes[13];

        const header = QoiHeader{
            .width = width,
            .height = height,
            .channels = channels,
            .colorspace = colorspace,
        };
        try header.validate();
        return header;
    }

    /// Reads and deserializes a header from a stream reader.
    pub fn read(reader: anytype) !QoiHeader {
        var bytes: [size_bytes]u8 = undefined;
        reader.readNoEof(&bytes) catch |err| {
            if (err == error.EndOfStream) return Error.UnexpectedEndOfStream;
            return err;
        };
        return try deserialize(bytes);
    }

    /// Serializes and writes a header to a stream writer.
    pub fn write(self: QoiHeader, writer: anytype) !void {
        const bytes = self.serialize();
        try writer.writeAll(&bytes);
    }
};

/// A single 32-bit pixel in RGBA format
pub const Pixel = struct {
    r: u8 = 0,
    g: u8 = 0,
    b: u8 = 0,
    a: u8 = 255,

    /// Computes the QOI hash position (0..63) for this pixel.
    pub fn hash(self: Pixel) u6 {
        const r_val: u32 = self.r;
        const g_val: u32 = self.g;
        const b_val: u32 = self.b;
        const a_val: u32 = self.a;
        return @intCast((r_val * 3 + g_val * 5 + b_val * 7 + a_val * 11) % 64);
    }

    /// Comparison of equality helper.
    pub inline fn eql(self: Pixel, other: Pixel) bool {
        return self.r == other.r and self.g == other.g and self.b == other.b and self.a == other.a;
    }

    /// Calculates wrap-around mathematical differences for color channels from another pixel.
    /// This uses standard unsigned 8-bit wraparound arithmetic and returns i8 differences.
    pub fn diff(self: Pixel, other: Pixel) struct { dr: i8, dg: i8, db: i8, da: i8 } {
        return .{
            .dr = @bitCast(self.r -% other.r),
            .dg = @bitCast(self.g -% other.g),
            .db = @bitCast(self.b -% other.b),
            .da = @bitCast(self.a -% other.a),
        };
    }

    /// Adds the given channel differences to this pixel using wrapping addition.
    pub fn add(self: Pixel, dr: i8, dg: i8, db: i8) Pixel {
        return .{
            .r = self.r +% @as(u8, @bitCast(dr)),
            .g = self.g +% @as(u8, @bitCast(dg)),
            .b = self.b +% @as(u8, @bitCast(db)),
            .a = self.a,
        };
    }
};

/// Shared error set for encoding and decoding QOI data
pub const Error = error{
    InvalidMagic,
    InvalidChannels,
    InvalidColorspace,
    InvalidDimensions,
    UnexpectedEndOfStream,
    InvalidEndMarker,
    OutputBufferTooSmall,
    InputBufferTooSmall,
};

/// Standard 8-byte QOI end marker.
pub const end_marker: [8]u8 = .{ 0, 0, 0, 0, 0, 0, 0, 1 };

/// Two-component tags (top 2 bits set, remaining 6 bits for value)
pub const QOI_OP_INDEX: u8 = 0x00; // 00xxxxxx
pub const QOI_OP_DIFF:  u8 = 0x40; // 01xxxxxx
pub const QOI_OP_LUMA:  u8 = 0x80; // 10xxxxxx
pub const QOI_OP_RUN:   u8 = 0xc0; // 11xxxxxx

/// Single-byte tags (all 8 bits set)
pub const QOI_OP_RGB:   u8 = 0xfe; // 11111110
pub const QOI_OP_RGBA:  u8 = 0xff; // 11111111

/// Mask used to isolate the 2-bit tag
pub const TAG_MASK:     u8 = 0xc0;

test "Pixel initial state, hash, and equality" {
    const default_pixel = Pixel{};
    try std.testing.expectEqual(@as(u8, 0), default_pixel.r);
    try std.testing.expectEqual(@as(u8, 0), default_pixel.g);
    try std.testing.expectEqual(@as(u8, 0), default_pixel.b);
    try std.testing.expectEqual(@as(u8, 255), default_pixel.a);

    // Initial state hash checks
    // index_position = (r * 3 + g * 5 + b * 7 + a * 11) % 64
    // (0 + 0 + 0 + 255 * 11) % 64 = 2805 % 64 = 53
    try std.testing.expectEqual(@as(u6, 53), default_pixel.hash());

    const pixel2 = Pixel{ .r = 10, .g = 20, .b = 30, .a = 240 };
    // (30 + 100 + 210 + 2640) % 64 = 2980 % 64 = 36
    try std.testing.expectEqual(@as(u6, 36), pixel2.hash());

    try std.testing.expect(default_pixel.eql(Pixel{ .r = 0, .g = 0, .b = 0, .a = 255 }));
    try std.testing.expect(!default_pixel.eql(pixel2));
}

test "Pixel wraparound difference and addition" {
    const px1 = Pixel{ .r = 100, .g = 150, .b = 200, .a = 255 };
    const px2 = Pixel{ .r = 98, .g = 151, .b = 197, .a = 255 };

    const differences = px2.diff(px1);
    try std.testing.expectEqual(@as(i8, -2), differences.dr);
    try std.testing.expectEqual(@as(i8, 1), differences.dg);
    try std.testing.expectEqual(@as(i8, -3), differences.db);

    const reconstructed = px1.add(differences.dr, differences.dg, differences.db);
    try std.testing.expectEqual(@as(u8, 98), reconstructed.r);
    try std.testing.expectEqual(@as(u8, 151), reconstructed.g);
    try std.testing.expectEqual(@as(u8, 197), reconstructed.b);
    try std.testing.expectEqual(@as(u8, 255), reconstructed.a);
}

test "QoiHeader serialization and validate" {
    const header = QoiHeader{
        .width = 1920,
        .height = 1080,
        .channels = 4,
        .colorspace = 1,
    };

    try header.validate();

    const serialized = header.serialize();
    try std.testing.expectEqualStrings("qoif", serialized[0..4]);

    const deserialized = try QoiHeader.deserialize(serialized);
    try std.testing.expectEqual(@as(u32, 1920), deserialized.width);
    try std.testing.expectEqual(@as(u32, 1080), deserialized.height);
    try std.testing.expectEqual(@as(u8, 4), deserialized.channels);
    try std.testing.expectEqual(@as(u8, 1), deserialized.colorspace);

    // Invalid magic
    var bad_serialized = serialized;
    bad_serialized[0] = 'x';
    try std.testing.expectError(Error.InvalidMagic, QoiHeader.deserialize(bad_serialized));

    // Invalid dimensions
    const bad_header = QoiHeader{
        .width = 0,
        .height = 100,
        .channels = 3,
        .colorspace = 0,
    };
    try std.testing.expectError(Error.InvalidDimensions, bad_header.validate());
}

test "QoiHeader stream read/write" {
    const header = QoiHeader{
        .width = 800,
        .height = 600,
        .channels = 3,
        .colorspace = 0,
    };

    var buf: [14]u8 = undefined;
    var fbs_write = std.io.fixedBufferStream(&buf);
    try header.write(fbs_write.writer());

    var fbs_read = std.io.fixedBufferStream(&buf);
    const read_header = try QoiHeader.read(fbs_read.reader());

    try std.testing.expectEqual(@as(u32, 800), read_header.width);
    try std.testing.expectEqual(@as(u32, 600), read_header.height);
    try std.testing.expectEqual(@as(u8, 3), read_header.channels);
    try std.testing.expectEqual(@as(u8, 0), read_header.colorspace);
}
