const std = @import("std");
const qoi = @import("qoi.zig");

const Pixel = qoi.Pixel;
const QoiHeader = qoi.QoiHeader;

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
    header: QoiHeader,
    pixels: []Pixel,

    pub fn deinit(self: *DecodeResult, allocator: std.mem.Allocator) void {
        allocator.free(self.pixels);
        self.* = undefined;
    }
};

/// Decode a QOI byte stream into pixel data.
///
/// The `data` slice must contain the full QOI file: 14-byte header, data chunks,
/// and 8-byte end marker.
///
/// Returns the decoded header and pixel array (caller owns the allocation).
pub fn decode(allocator: std.mem.Allocator, data: []const u8) DecodeError!DecodeResult {
    const header = QoiHeader.decode(data) catch |err| switch (err) {
        error.InvalidMagic => return DecodeError.InvalidMagic,
        error.InvalidChannels => return DecodeError.InvalidChannels,
        error.InvalidColorspace => return DecodeError.InvalidColorspace,
        error.UnexpectedEndOfData => return DecodeError.UnexpectedEndOfData,
    };

    const pixel_count = header.pixelCount();
    if (pixel_count == 0) return DecodeError.InvalidDimensions;

    // Minimum file size: header + end marker
    if (data.len < qoi.QOI_HEADER_SIZE + qoi.QOI_END_MARKER.len)
        return DecodeError.UnexpectedEndOfData;

    const pixels = allocator.alloc(Pixel, pixel_count) catch return DecodeError.UnexpectedEndOfData;
    errdefer allocator.free(pixels);

    var index: [qoi.QOI_INDEX_SIZE]Pixel = .{Pixel{ .r = 0, .g = 0, .b = 0, .a = 0 }} ** qoi.QOI_INDEX_SIZE;
    var prev_pixel = Pixel.default;
    var pos: usize = qoi.QOI_HEADER_SIZE;
    var pixel_idx: usize = 0;

    const chunk_end = data.len - qoi.QOI_END_MARKER.len;

    while (pixel_idx < pixel_count) {
        if (pos >= chunk_end) return DecodeError.UnexpectedEndOfData;

        const b0 = data[pos];

        if (b0 == qoi.QOI_OP_RGB) {
            // QOI_OP_RGB: 4 bytes total
            if (pos + 4 > chunk_end) return DecodeError.UnexpectedEndOfData;
            prev_pixel.r = data[pos + 1];
            prev_pixel.g = data[pos + 2];
            prev_pixel.b = data[pos + 3];
            pos += 4;
        } else if (b0 == qoi.QOI_OP_RGBA) {
            // QOI_OP_RGBA: 5 bytes total
            if (pos + 5 > chunk_end) return DecodeError.UnexpectedEndOfData;
            prev_pixel.r = data[pos + 1];
            prev_pixel.g = data[pos + 2];
            prev_pixel.b = data[pos + 3];
            prev_pixel.a = data[pos + 4];
            pos += 5;
        } else {
            const tag2 = b0 & qoi.QOI_MASK_2;

            switch (tag2) {
                qoi.QOI_OP_INDEX => {
                    const idx: u6 = @truncate(b0 & 0x3f);
                    prev_pixel = index[idx];
                    pos += 1;
                },
                qoi.QOI_OP_DIFF => {
                    const dr: u8 = ((b0 >> 4) & 0x03) -% 2;
                    const dg: u8 = ((b0 >> 2) & 0x03) -% 2;
                    const db: u8 = (b0 & 0x03) -% 2;
                    prev_pixel.r = prev_pixel.r +% dr;
                    prev_pixel.g = prev_pixel.g +% dg;
                    prev_pixel.b = prev_pixel.b +% db;
                    pos += 1;
                },
                qoi.QOI_OP_LUMA => {
                    if (pos + 2 > chunk_end) return DecodeError.UnexpectedEndOfData;
                    const b1 = data[pos + 1];
                    const dg: u8 = (b0 & 0x3f) -% 32;
                    const dr_dg: u8 = ((b1 >> 4) & 0x0f) -% 8;
                    const db_dg: u8 = (b1 & 0x0f) -% 8;
                    prev_pixel.r = prev_pixel.r +% (dg +% dr_dg);
                    prev_pixel.g = prev_pixel.g +% dg;
                    prev_pixel.b = prev_pixel.b +% (dg +% db_dg);
                    pos += 2;
                },
                qoi.QOI_OP_RUN => {
                    const run_len: usize = @as(usize, b0 & 0x3f) + 1;
                    if (pixel_idx + run_len > pixel_count) return DecodeError.UnexpectedEndOfData;
                    for (0..run_len) |i| {
                        pixels[pixel_idx + i] = prev_pixel;
                    }
                    pixel_idx += run_len;
                    pos += 1;
                    // RUN doesn't update the index and prev_pixel stays the same.
                    // Skip the normal store below.
                    continue;
                },
                else => unreachable,
            }
        }

        // Store pixel and update index.
        index[prev_pixel.hash()] = prev_pixel;
        pixels[pixel_idx] = prev_pixel;
        pixel_idx += 1;
    }

    // Verify end marker
    if (pos + qoi.QOI_END_MARKER.len > data.len) return DecodeError.UnexpectedEndOfData;
    if (!std.mem.eql(u8, data[pos..][0..qoi.QOI_END_MARKER.len], &qoi.QOI_END_MARKER))
        return DecodeError.InvalidEndMarker;

    return DecodeResult{
        .header = header,
        .pixels = pixels,
    };
}

// ── Tests ────────────────────────────────────────────────────────────────────

test "decode minimal 1x1 RGB image" {
    // 1×1 pixel, RGB, sRGB. Pixel = {0, 0, 0, 255} (default).
    // The default pixel matches the previous pixel, so it's a QOI_OP_RUN with run=1 (stored as 0).
    var buf: [qoi.QOI_HEADER_SIZE + 1 + qoi.QOI_END_MARKER.len]u8 = undefined;
    const hdr = QoiHeader{ .width = 1, .height = 1, .channels = .rgb, .colorspace = .srgb };
    @memcpy(buf[0..qoi.QOI_HEADER_SIZE], &hdr.encode());
    buf[qoi.QOI_HEADER_SIZE] = qoi.QOI_OP_RUN | 0x00; // run of 1 (bias -1 → stored as 0)
    @memcpy(buf[qoi.QOI_HEADER_SIZE + 1 ..][0..8], &qoi.QOI_END_MARKER);

    const allocator = std.testing.allocator;
    var result = try decode(allocator, &buf);
    defer result.deinit(allocator);

    try std.testing.expectEqual(@as(usize, 1), result.pixels.len);
    try std.testing.expect(result.pixels[0].eql(Pixel.default));
}

test "decode QOI_OP_RGB chunk" {
    // 1×1 pixel with RGB values {10, 20, 30}, alpha stays 255.
    var buf: [qoi.QOI_HEADER_SIZE + 4 + qoi.QOI_END_MARKER.len]u8 = undefined;
    const hdr = QoiHeader{ .width = 1, .height = 1, .channels = .rgb, .colorspace = .srgb };
    @memcpy(buf[0..qoi.QOI_HEADER_SIZE], &hdr.encode());
    buf[qoi.QOI_HEADER_SIZE + 0] = qoi.QOI_OP_RGB;
    buf[qoi.QOI_HEADER_SIZE + 1] = 10;
    buf[qoi.QOI_HEADER_SIZE + 2] = 20;
    buf[qoi.QOI_HEADER_SIZE + 3] = 30;
    @memcpy(buf[qoi.QOI_HEADER_SIZE + 4 ..][0..8], &qoi.QOI_END_MARKER);

    const allocator = std.testing.allocator;
    var result = try decode(allocator, &buf);
    defer result.deinit(allocator);

    try std.testing.expectEqual(@as(u8, 10), result.pixels[0].r);
    try std.testing.expectEqual(@as(u8, 20), result.pixels[0].g);
    try std.testing.expectEqual(@as(u8, 30), result.pixels[0].b);
    try std.testing.expectEqual(@as(u8, 255), result.pixels[0].a);
}

test "decode QOI_OP_RGBA chunk" {
    var buf: [qoi.QOI_HEADER_SIZE + 5 + qoi.QOI_END_MARKER.len]u8 = undefined;
    const hdr = QoiHeader{ .width = 1, .height = 1, .channels = .rgba, .colorspace = .srgb };
    @memcpy(buf[0..qoi.QOI_HEADER_SIZE], &hdr.encode());
    buf[qoi.QOI_HEADER_SIZE + 0] = qoi.QOI_OP_RGBA;
    buf[qoi.QOI_HEADER_SIZE + 1] = 100;
    buf[qoi.QOI_HEADER_SIZE + 2] = 150;
    buf[qoi.QOI_HEADER_SIZE + 3] = 200;
    buf[qoi.QOI_HEADER_SIZE + 4] = 128;
    @memcpy(buf[qoi.QOI_HEADER_SIZE + 5 ..][0..8], &qoi.QOI_END_MARKER);

    const allocator = std.testing.allocator;
    var result = try decode(allocator, &buf);
    defer result.deinit(allocator);

    try std.testing.expectEqual(@as(u8, 100), result.pixels[0].r);
    try std.testing.expectEqual(@as(u8, 150), result.pixels[0].g);
    try std.testing.expectEqual(@as(u8, 200), result.pixels[0].b);
    try std.testing.expectEqual(@as(u8, 128), result.pixels[0].a);
}

test "decode invalid magic" {
    var buf: [qoi.QOI_HEADER_SIZE + 1 + qoi.QOI_END_MARKER.len]u8 = undefined;
    const hdr = QoiHeader{ .width = 1, .height = 1, .channels = .rgb, .colorspace = .srgb };
    @memcpy(buf[0..qoi.QOI_HEADER_SIZE], &hdr.encode());
    buf[0] = 'x'; // corrupt magic
    buf[qoi.QOI_HEADER_SIZE] = qoi.QOI_OP_RUN | 0x00;
    @memcpy(buf[qoi.QOI_HEADER_SIZE + 1 ..][0..8], &qoi.QOI_END_MARKER);

    const allocator = std.testing.allocator;
    try std.testing.expectError(DecodeError.InvalidMagic, decode(allocator, &buf));
}

test "decode truncated file" {
    // Only header, no data or end marker
    const hdr = QoiHeader{ .width = 1, .height = 1, .channels = .rgb, .colorspace = .srgb };
    const header_bytes = hdr.encode();
    const allocator = std.testing.allocator;
    try std.testing.expectError(DecodeError.UnexpectedEndOfData, decode(allocator, &header_bytes));
}

test "decode invalid end marker" {
    var buf: [qoi.QOI_HEADER_SIZE + 1 + qoi.QOI_END_MARKER.len]u8 = undefined;
    const hdr = QoiHeader{ .width = 1, .height = 1, .channels = .rgb, .colorspace = .srgb };
    @memcpy(buf[0..qoi.QOI_HEADER_SIZE], &hdr.encode());
    buf[qoi.QOI_HEADER_SIZE] = qoi.QOI_OP_RUN | 0x00;
    @memcpy(buf[qoi.QOI_HEADER_SIZE + 1 ..][0..8], &qoi.QOI_END_MARKER);
    buf[buf.len - 1] = 0x02; // corrupt end marker

    const allocator = std.testing.allocator;
    try std.testing.expectError(DecodeError.InvalidEndMarker, decode(allocator, &buf));
}

test "decode QOI_OP_DIFF chunk" {
    // Previous pixel: {0, 0, 0, 255}. Diff: dr=1, dg=0, db=-1 → stored with bias 2 as 3,2,1.
    // Byte: 0b01_11_10_01 = 0x79
    var buf: [qoi.QOI_HEADER_SIZE + 1 + qoi.QOI_END_MARKER.len]u8 = undefined;
    const hdr = QoiHeader{ .width = 1, .height = 1, .channels = .rgb, .colorspace = .srgb };
    @memcpy(buf[0..qoi.QOI_HEADER_SIZE], &hdr.encode());
    buf[qoi.QOI_HEADER_SIZE] = 0b01_11_10_01;
    @memcpy(buf[qoi.QOI_HEADER_SIZE + 1 ..][0..8], &qoi.QOI_END_MARKER);

    const allocator = std.testing.allocator;
    var result = try decode(allocator, &buf);
    defer result.deinit(allocator);

    try std.testing.expectEqual(@as(u8, 1), result.pixels[0].r);
    try std.testing.expectEqual(@as(u8, 0), result.pixels[0].g);
    try std.testing.expectEqual(@as(u8, 255), result.pixels[0].b);
    try std.testing.expectEqual(@as(u8, 255), result.pixels[0].a);
}

test "decode QOI_OP_LUMA chunk" {
    // Previous pixel: {0, 0, 0, 255}. dg = 5 (bias 32 → stored as 37).
    // dr_dg = 1 (bias 8 → stored as 9), db_dg = -1 (bias 8 → stored as 7).
    // dr = dg + dr_dg = 5 + 1 = 6, db = dg + db_dg = 5 + (-1) = 4.
    // Byte0: 0b10_100101 = 0x80 | 37 = 0xa5
    // Byte1: 0b1001_0111 = (9 << 4) | 7 = 0x97
    var buf: [qoi.QOI_HEADER_SIZE + 2 + qoi.QOI_END_MARKER.len]u8 = undefined;
    const hdr = QoiHeader{ .width = 1, .height = 1, .channels = .rgb, .colorspace = .srgb };
    @memcpy(buf[0..qoi.QOI_HEADER_SIZE], &hdr.encode());
    buf[qoi.QOI_HEADER_SIZE + 0] = 0x80 | 37;
    buf[qoi.QOI_HEADER_SIZE + 1] = (9 << 4) | 7;
    @memcpy(buf[qoi.QOI_HEADER_SIZE + 2 ..][0..8], &qoi.QOI_END_MARKER);

    const allocator = std.testing.allocator;
    var result = try decode(allocator, &buf);
    defer result.deinit(allocator);

    try std.testing.expectEqual(@as(u8, 6), result.pixels[0].r);
    try std.testing.expectEqual(@as(u8, 5), result.pixels[0].g);
    try std.testing.expectEqual(@as(u8, 4), result.pixels[0].b);
}

test "decode QOI_OP_INDEX chunk" {
    // 2×1 image. First pixel via RGB, second via INDEX.
    // First pixel: {42, 84, 126, 255}
    // hash = (42*3 + 84*5 + 126*7 + 255*11) % 64 = (126+420+882+2805) % 64 = 4233 % 64 = 9
    var buf: [qoi.QOI_HEADER_SIZE + 4 + 1 + qoi.QOI_END_MARKER.len]u8 = undefined;
    const hdr = QoiHeader{ .width = 2, .height = 1, .channels = .rgb, .colorspace = .srgb };
    @memcpy(buf[0..qoi.QOI_HEADER_SIZE], &hdr.encode());
    buf[qoi.QOI_HEADER_SIZE + 0] = qoi.QOI_OP_RGB;
    buf[qoi.QOI_HEADER_SIZE + 1] = 42;
    buf[qoi.QOI_HEADER_SIZE + 2] = 84;
    buf[qoi.QOI_HEADER_SIZE + 3] = 126;
    // Now use QOI_OP_INDEX to refer back. hash=9 → 0b00_001001 = 0x09
    const px = Pixel{ .r = 42, .g = 84, .b = 126, .a = 255 };
    buf[qoi.QOI_HEADER_SIZE + 4] = qoi.QOI_OP_INDEX | px.hash();
    @memcpy(buf[qoi.QOI_HEADER_SIZE + 5 ..][0..8], &qoi.QOI_END_MARKER);

    const allocator = std.testing.allocator;
    var result = try decode(allocator, &buf);
    defer result.deinit(allocator);

    try std.testing.expectEqual(@as(usize, 2), result.pixels.len);
    try std.testing.expect(result.pixels[0].eql(px));
    try std.testing.expect(result.pixels[1].eql(px));
}

test "decode run of multiple pixels" {
    // 5×1 image, all default pixels → run of 5 (stored as 4 with bias -1).
    var buf: [qoi.QOI_HEADER_SIZE + 1 + qoi.QOI_END_MARKER.len]u8 = undefined;
    const hdr = QoiHeader{ .width = 5, .height = 1, .channels = .rgb, .colorspace = .srgb };
    @memcpy(buf[0..qoi.QOI_HEADER_SIZE], &hdr.encode());
    buf[qoi.QOI_HEADER_SIZE] = qoi.QOI_OP_RUN | 4; // run of 5
    @memcpy(buf[qoi.QOI_HEADER_SIZE + 1 ..][0..8], &qoi.QOI_END_MARKER);

    const allocator = std.testing.allocator;
    var result = try decode(allocator, &buf);
    defer result.deinit(allocator);

    try std.testing.expectEqual(@as(usize, 5), result.pixels.len);
    for (result.pixels) |px| {
        try std.testing.expect(px.eql(Pixel.default));
    }
}
