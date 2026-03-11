const std = @import("std");
const qoi = @import("qoi.zig");
const encoder = @import("encoder.zig");
const decoder = @import("decoder.zig");

const Pixel = qoi.Pixel;
const ChannelDiff = qoi.ChannelDiff;
const QoiHeader = qoi.QoiHeader;
const Channels = qoi.Channels;
const Colorspace = qoi.Colorspace;
const DecodeError = decoder.DecodeError;

// ═══════════════════════════════════════════════════════════════════════════
// Round-trip: encode then decode
// ═══════════════════════════════════════════════════════════════════════════

test "round-trip 1x1 black RGB" {
    const alloc = std.testing.allocator;
    const pixels = [_]u8{ 0, 0, 0 };
    const encoded = try encoder.encode(alloc, &pixels, 1, 1, .rgb, .srgb);
    defer alloc.free(encoded);

    var result = try decoder.decode(alloc, encoded);
    defer result.deinit(alloc);

    try std.testing.expectEqual(@as(usize, 1), result.pixels.len);
    try std.testing.expect(result.pixels[0].eql(Pixel{ .r = 0, .g = 0, .b = 0, .a = 255 }));
    try std.testing.expectEqual(@as(u32, 1), result.header.width);
    try std.testing.expectEqual(@as(u32, 1), result.header.height);
    try std.testing.expectEqual(Channels.rgb, result.header.channels);
    try std.testing.expectEqual(Colorspace.srgb, result.header.colorspace);
}

test "round-trip 1x1 RGBA with alpha" {
    const alloc = std.testing.allocator;
    const pixels = [_]u8{ 100, 150, 200, 128 };
    const encoded = try encoder.encode(alloc, &pixels, 1, 1, .rgba, .srgb);
    defer alloc.free(encoded);

    var result = try decoder.decode(alloc, encoded);
    defer result.deinit(alloc);

    try std.testing.expectEqual(@as(usize, 1), result.pixels.len);
    try std.testing.expect(result.pixels[0].eql(Pixel{ .r = 100, .g = 150, .b = 200, .a = 128 }));
}

test "round-trip 2x2 solid red RGB" {
    const alloc = std.testing.allocator;
    // 4 pixels of (255, 0, 0)
    const pixels = [_]u8{
        255, 0, 0,
        255, 0, 0,
        255, 0, 0,
        255, 0, 0,
    };
    const encoded = try encoder.encode(alloc, &pixels, 2, 2, .rgb, .srgb);
    defer alloc.free(encoded);

    var result = try decoder.decode(alloc, encoded);
    defer result.deinit(alloc);

    try std.testing.expectEqual(@as(usize, 4), result.pixels.len);
    const expected = Pixel{ .r = 255, .g = 0, .b = 0, .a = 255 };
    for (result.pixels) |px| {
        try std.testing.expect(px.eql(expected));
    }
}

test "round-trip 2x2 distinct pixels RGB" {
    const alloc = std.testing.allocator;
    const pixels = [_]u8{
        10,  20,  30,
        40,  50,  60,
        70,  80,  90,
        100, 110, 120,
    };
    const encoded = try encoder.encode(alloc, &pixels, 2, 2, .rgb, .srgb);
    defer alloc.free(encoded);

    var result = try decoder.decode(alloc, encoded);
    defer result.deinit(alloc);

    try std.testing.expectEqual(@as(usize, 4), result.pixels.len);
    try std.testing.expect(result.pixels[0].eql(Pixel{ .r = 10, .g = 20, .b = 30, .a = 255 }));
    try std.testing.expect(result.pixels[1].eql(Pixel{ .r = 40, .g = 50, .b = 60, .a = 255 }));
    try std.testing.expect(result.pixels[2].eql(Pixel{ .r = 70, .g = 80, .b = 90, .a = 255 }));
    try std.testing.expect(result.pixels[3].eql(Pixel{ .r = 100, .g = 110, .b = 120, .a = 255 }));
}

test "round-trip gradient image" {
    const alloc = std.testing.allocator;
    const width: u32 = 16;
    const height: u32 = 16;
    var pixels: [width * height * 3]u8 = undefined;
    for (0..width * height) |i| {
        const v: u8 = @truncate(i);
        pixels[i * 3 + 0] = v;
        pixels[i * 3 + 1] = v;
        pixels[i * 3 + 2] = v;
    }

    const encoded = try encoder.encode(alloc, &pixels, width, height, .rgb, .srgb);
    defer alloc.free(encoded);

    var result = try decoder.decode(alloc, encoded);
    defer result.deinit(alloc);

    try std.testing.expectEqual(@as(usize, width * height), result.pixels.len);
    for (0..width * height) |i| {
        const v: u8 = @truncate(i);
        try std.testing.expectEqual(v, result.pixels[i].r);
        try std.testing.expectEqual(v, result.pixels[i].g);
        try std.testing.expectEqual(v, result.pixels[i].b);
        try std.testing.expectEqual(@as(u8, 255), result.pixels[i].a);
    }
}

test "round-trip solid color large image" {
    const alloc = std.testing.allocator;
    const width: u32 = 100;
    const height: u32 = 100;
    var pixels: [width * height * 4]u8 = undefined;
    for (0..width * height) |i| {
        pixels[i * 4 + 0] = 42;
        pixels[i * 4 + 1] = 84;
        pixels[i * 4 + 2] = 126;
        pixels[i * 4 + 3] = 200;
    }

    const encoded = try encoder.encode(alloc, &pixels, width, height, .rgba, .srgb);
    defer alloc.free(encoded);

    var result = try decoder.decode(alloc, encoded);
    defer result.deinit(alloc);

    try std.testing.expectEqual(@as(usize, width * height), result.pixels.len);
    const expected = Pixel{ .r = 42, .g = 84, .b = 126, .a = 200 };
    for (result.pixels) |px| {
        try std.testing.expect(px.eql(expected));
    }
}

test "round-trip RGBA with varying alpha" {
    const alloc = std.testing.allocator;
    const pixels = [_]u8{
        255, 0,   0,   255, // opaque red
        0,   255, 0,   128, // semi-transparent green
        0,   0,   255, 0, //   transparent blue
        255, 255, 255, 255, // opaque white
    };
    const encoded = try encoder.encode(alloc, &pixels, 2, 2, .rgba, .srgb);
    defer alloc.free(encoded);

    var result = try decoder.decode(alloc, encoded);
    defer result.deinit(alloc);

    try std.testing.expectEqual(@as(usize, 4), result.pixels.len);
    try std.testing.expect(result.pixels[0].eql(Pixel{ .r = 255, .g = 0, .b = 0, .a = 255 }));
    try std.testing.expect(result.pixels[1].eql(Pixel{ .r = 0, .g = 255, .b = 0, .a = 128 }));
    try std.testing.expect(result.pixels[2].eql(Pixel{ .r = 0, .g = 0, .b = 255, .a = 0 }));
    try std.testing.expect(result.pixels[3].eql(Pixel{ .r = 255, .g = 255, .b = 255, .a = 255 }));
}

test "round-trip colorspace linear" {
    const alloc = std.testing.allocator;
    const pixels = [_]u8{ 50, 100, 150 };
    const encoded = try encoder.encode(alloc, &pixels, 1, 1, .rgb, .linear);
    defer alloc.free(encoded);

    var result = try decoder.decode(alloc, encoded);
    defer result.deinit(alloc);

    try std.testing.expectEqual(Colorspace.linear, result.header.colorspace);
    try std.testing.expect(result.pixels[0].eql(Pixel{ .r = 50, .g = 100, .b = 150, .a = 255 }));
}

// ═══════════════════════════════════════════════════════════════════════════
// Header serialization (Big Endian)
// ═══════════════════════════════════════════════════════════════════════════

test "header big-endian encoding" {
    const hdr = QoiHeader{
        .width = 0x01020304,
        .height = 0x05060708,
        .channels = .rgba,
        .colorspace = .linear,
    };
    const bytes = hdr.encode();

    // Magic
    try std.testing.expectEqualSlices(u8, "qoif", bytes[0..4]);
    // Width in big-endian
    try std.testing.expectEqual(@as(u8, 0x01), bytes[4]);
    try std.testing.expectEqual(@as(u8, 0x02), bytes[5]);
    try std.testing.expectEqual(@as(u8, 0x03), bytes[6]);
    try std.testing.expectEqual(@as(u8, 0x04), bytes[7]);
    // Height in big-endian
    try std.testing.expectEqual(@as(u8, 0x05), bytes[8]);
    try std.testing.expectEqual(@as(u8, 0x06), bytes[9]);
    try std.testing.expectEqual(@as(u8, 0x07), bytes[10]);
    try std.testing.expectEqual(@as(u8, 0x08), bytes[11]);
    // Channels and colorspace
    try std.testing.expectEqual(@as(u8, 4), bytes[12]);
    try std.testing.expectEqual(@as(u8, 1), bytes[13]);
}

test "header big-endian round-trip for width=1920, height=1080" {
    const hdr = QoiHeader{
        .width = 1920,
        .height = 1080,
        .channels = .rgb,
        .colorspace = .srgb,
    };
    const bytes = hdr.encode();
    // 1920 = 0x00000780, 1080 = 0x00000438
    try std.testing.expectEqual(@as(u8, 0x00), bytes[4]);
    try std.testing.expectEqual(@as(u8, 0x00), bytes[5]);
    try std.testing.expectEqual(@as(u8, 0x07), bytes[6]);
    try std.testing.expectEqual(@as(u8, 0x80), bytes[7]);
    try std.testing.expectEqual(@as(u8, 0x00), bytes[8]);
    try std.testing.expectEqual(@as(u8, 0x00), bytes[9]);
    try std.testing.expectEqual(@as(u8, 0x04), bytes[10]);
    try std.testing.expectEqual(@as(u8, 0x38), bytes[11]);

    const decoded = try QoiHeader.decode(&bytes);
    try std.testing.expectEqual(@as(u32, 1920), decoded.width);
    try std.testing.expectEqual(@as(u32, 1080), decoded.height);
}

test "header size is exactly 14 bytes" {
    try std.testing.expectEqual(@as(usize, 14), qoi.QOI_HEADER_SIZE);
}

test "encoded output structure: header + data + end marker" {
    const alloc = std.testing.allocator;
    const pixels = [_]u8{ 128, 64, 32 };
    const encoded = try encoder.encode(alloc, &pixels, 1, 1, .rgb, .srgb);
    defer alloc.free(encoded);

    // Must start with magic
    try std.testing.expectEqualSlices(u8, "qoif", encoded[0..4]);
    // Must end with end marker
    try std.testing.expectEqualSlices(u8, &qoi.QOI_END_MARKER, encoded[encoded.len - 8 ..]);
    // Total size >= header + end marker
    try std.testing.expect(encoded.len >= qoi.QOI_HEADER_SIZE + qoi.QOI_END_MARKER.len);
}

// ═══════════════════════════════════════════════════════════════════════════
// Pixel hash function
// ═══════════════════════════════════════════════════════════════════════════

test "pixel hash formula matches reference spec" {
    // hash = (r*3 + g*5 + b*7 + a*11) % 64
    const cases = [_]struct { px: Pixel, expected: u6 }{
        .{ .px = Pixel{ .r = 0, .g = 0, .b = 0, .a = 0 }, .expected = 0 },
        .{ .px = Pixel{ .r = 0, .g = 0, .b = 0, .a = 255 }, .expected = @truncate((255 * 11) % 64) },
        .{ .px = Pixel{ .r = 255, .g = 255, .b = 255, .a = 255 }, .expected = @truncate((@as(u32, 255) * 3 + @as(u32, 255) * 5 + @as(u32, 255) * 7 + @as(u32, 255) * 11) % 64) },
        .{ .px = Pixel{ .r = 1, .g = 0, .b = 0, .a = 0 }, .expected = 3 },
        .{ .px = Pixel{ .r = 0, .g = 1, .b = 0, .a = 0 }, .expected = 5 },
        .{ .px = Pixel{ .r = 0, .g = 0, .b = 1, .a = 0 }, .expected = 7 },
        .{ .px = Pixel{ .r = 0, .g = 0, .b = 0, .a = 1 }, .expected = 11 },
    };
    for (cases) |c| {
        try std.testing.expectEqual(c.expected, c.px.hash());
    }
}

test "pixel hash is always in 0..63" {
    // Test a spread of pixel values
    var r: u16 = 0;
    while (r <= 255) : (r += 51) {
        var g: u16 = 0;
        while (g <= 255) : (g += 51) {
            var b: u16 = 0;
            while (b <= 255) : (b += 51) {
                var a: u16 = 0;
                while (a <= 255) : (a += 85) {
                    const px = Pixel{
                        .r = @truncate(r),
                        .g = @truncate(g),
                        .b = @truncate(b),
                        .a = @truncate(a),
                    };
                    try std.testing.expect(px.hash() < 64);
                }
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// Chunk type coverage
// ═══════════════════════════════════════════════════════════════════════════

test "chunk: QOI_OP_RUN is emitted for repeated pixels" {
    const alloc = std.testing.allocator;
    // 5 identical black pixels (matching default prev_px) → run of 5
    var pixels: [5 * 3]u8 = .{0} ** (5 * 3);
    _ = &pixels;
    const encoded = try encoder.encode(alloc, &pixels, 5, 1, .rgb, .srgb);
    defer alloc.free(encoded);

    // First data byte should be QOI_OP_RUN with run-1 = 4
    try std.testing.expectEqual(@as(u8, qoi.QOI_OP_RUN | 4), encoded[qoi.QOI_HEADER_SIZE]);
    // Total: header(14) + 1 run byte + 8 end marker = 23
    try std.testing.expectEqual(@as(usize, 23), encoded.len);
}

test "chunk: QOI_OP_RUN max 62 then continues" {
    const alloc = std.testing.allocator;
    // 63 identical black pixels → run of 62 (max) + run of 1
    var pixels: [63 * 3]u8 = .{0} ** (63 * 3);
    _ = &pixels;
    const encoded = try encoder.encode(alloc, &pixels, 63, 1, .rgb, .srgb);
    defer alloc.free(encoded);

    // First run: QOI_OP_RUN | 61 (run=62)
    try std.testing.expectEqual(@as(u8, qoi.QOI_OP_RUN | 61), encoded[qoi.QOI_HEADER_SIZE]);
    // Second run: QOI_OP_RUN | 0 (run=1)
    try std.testing.expectEqual(@as(u8, qoi.QOI_OP_RUN | 0), encoded[qoi.QOI_HEADER_SIZE + 1]);
}

test "chunk: QOI_OP_DIFF for small differences" {
    const alloc = std.testing.allocator;
    // Pixel (1, 1, 1) from prev (0,0,0,255): dr=1, dg=1, db=1
    // Each fits in -2..1. Stored with bias 2: 3,3,3
    // QOI_OP_DIFF | (3<<4) | (3<<2) | 3 = 0x40 | 0x30 | 0x0c | 0x03 = 0x7f
    const pixels = [_]u8{ 1, 1, 1 };
    const encoded = try encoder.encode(alloc, &pixels, 1, 1, .rgb, .srgb);
    defer alloc.free(encoded);

    try std.testing.expectEqual(@as(u8, 0x7f), encoded[qoi.QOI_HEADER_SIZE]);
}

test "chunk: QOI_OP_DIFF negative differences" {
    const alloc = std.testing.allocator;
    // prev = (0,0,0,255), pixel = (255, 255, 255) i.e. diff = -1,-1,-1
    // unsigned: 255,255,255. (255+%2) = 1 < 4 each → fits small diff
    // Stored: 1,1,1. QOI_OP_DIFF | (1<<4) | (1<<2) | 1 = 0x40 | 0x10 | 0x04 | 0x01 = 0x55
    const pixels = [_]u8{ 255, 255, 255 };
    const encoded = try encoder.encode(alloc, &pixels, 1, 1, .rgb, .srgb);
    defer alloc.free(encoded);

    try std.testing.expectEqual(@as(u8, 0x55), encoded[qoi.QOI_HEADER_SIZE]);
}

test "chunk: QOI_OP_LUMA for medium differences" {
    const alloc = std.testing.allocator;
    // prev = (0,0,0,255), pixel = (10, 8, 6, 255)
    // dr=10, dg=8, db=6, da=0
    // fitsSmallDiff? 10+%2=12≥4. No.
    // fitsLumaDiff? dg=8, 8+%32=40<64. dr_dg=10-%8=2, 2+%8=10<16. db_dg=6-%8=254, 254+%8=6<16. Yes!
    // Byte0: QOI_OP_LUMA | (8+32) = 0x80 | 40 = 0xa8
    // Byte1: ((2+8)<<4) | (254+8) = (10<<4) | 6 = 0xa6
    const pixels = [_]u8{ 10, 8, 6 };
    const encoded = try encoder.encode(alloc, &pixels, 1, 1, .rgb, .srgb);
    defer alloc.free(encoded);

    try std.testing.expectEqual(@as(u8, 0xa8), encoded[qoi.QOI_HEADER_SIZE]);
    try std.testing.expectEqual(@as(u8, 0xa6), encoded[qoi.QOI_HEADER_SIZE + 1]);
}

test "chunk: QOI_OP_RGB for large RGB difference" {
    const alloc = std.testing.allocator;
    // prev = (0,0,0,255), pixel = (200, 100, 50, 255) — too large for diff/luma
    const pixels = [_]u8{ 200, 100, 50 };
    const encoded = try encoder.encode(alloc, &pixels, 1, 1, .rgb, .srgb);
    defer alloc.free(encoded);

    try std.testing.expectEqual(qoi.QOI_OP_RGB, encoded[qoi.QOI_HEADER_SIZE]);
    try std.testing.expectEqual(@as(u8, 200), encoded[qoi.QOI_HEADER_SIZE + 1]);
    try std.testing.expectEqual(@as(u8, 100), encoded[qoi.QOI_HEADER_SIZE + 2]);
    try std.testing.expectEqual(@as(u8, 50), encoded[qoi.QOI_HEADER_SIZE + 3]);
}

test "chunk: QOI_OP_RGBA when alpha changes" {
    const alloc = std.testing.allocator;
    // prev = (0,0,0,255), pixel = (0, 0, 0, 128) — alpha changed
    const pixels = [_]u8{ 0, 0, 0, 128 };
    const encoded = try encoder.encode(alloc, &pixels, 1, 1, .rgba, .srgb);
    defer alloc.free(encoded);

    try std.testing.expectEqual(qoi.QOI_OP_RGBA, encoded[qoi.QOI_HEADER_SIZE]);
    try std.testing.expectEqual(@as(u8, 0), encoded[qoi.QOI_HEADER_SIZE + 1]);
    try std.testing.expectEqual(@as(u8, 0), encoded[qoi.QOI_HEADER_SIZE + 2]);
    try std.testing.expectEqual(@as(u8, 0), encoded[qoi.QOI_HEADER_SIZE + 3]);
    try std.testing.expectEqual(@as(u8, 128), encoded[qoi.QOI_HEADER_SIZE + 4]);
}

test "chunk: QOI_OP_INDEX for repeated non-adjacent pixel" {
    const alloc = std.testing.allocator;
    // pixels: A=(200,100,50), B=(0,0,0) via some encoding, A again via INDEX
    // A from prev (0,0,0,255): big diff → QOI_OP_RGB
    // B=(0,0,0) from prev A: big diff → check index. hash(0,0,0,255)=53. index[53] starts as (0,0,0,0)≠(0,0,0,255). → encode (RGB or other)
    // A again from prev B: hash(A)=? check index. Should match → QOI_OP_INDEX.
    const pixels = [_]u8{ 200, 100, 50, 0, 0, 0, 200, 100, 50 };
    const encoded = try encoder.encode(alloc, &pixels, 3, 1, .rgb, .srgb);
    defer alloc.free(encoded);

    var result = try decoder.decode(alloc, encoded);
    defer result.deinit(alloc);

    try std.testing.expectEqual(@as(usize, 3), result.pixels.len);
    try std.testing.expect(result.pixels[0].eql(Pixel{ .r = 200, .g = 100, .b = 50, .a = 255 }));
    try std.testing.expect(result.pixels[2].eql(Pixel{ .r = 200, .g = 100, .b = 50, .a = 255 }));
}

// ═══════════════════════════════════════════════════════════════════════════
// Wraparound arithmetic edge cases
// ═══════════════════════════════════════════════════════════════════════════

test "wraparound: 1 - 2 = 255" {
    const a = Pixel{ .r = 1, .g = 0, .b = 0, .a = 255 };
    const b = Pixel{ .r = 2, .g = 0, .b = 0, .a = 255 };
    const d = a.diff(b);
    try std.testing.expectEqual(@as(u8, 255), d.dr);
}

test "wraparound: 255 + 1 = 0" {
    const prev = Pixel{ .r = 255, .g = 0, .b = 0, .a = 255 };
    const d = ChannelDiff{ .dr = 1, .dg = 0, .db = 0, .da = 0 };
    const result = prev.addDiff(d);
    try std.testing.expectEqual(@as(u8, 0), result.r);
}

test "wraparound: 0 - 1 = 255" {
    const a = Pixel{ .r = 0, .g = 0, .b = 0, .a = 255 };
    const b = Pixel{ .r = 1, .g = 0, .b = 0, .a = 255 };
    const d = a.diff(b);
    try std.testing.expectEqual(@as(u8, 255), d.dr);
}

test "wraparound: round-trip encode/decode across 0 boundary" {
    const alloc = std.testing.allocator;
    // Two pixels: first = (1, 1, 1), second = (0, 0, 0) → diff = (255, 255, 255) = (-1,-1,-1)
    // This should fit QOI_OP_DIFF since 255+%2=1 < 4
    const pixels = [_]u8{ 1, 1, 1, 0, 0, 0 };
    const encoded = try encoder.encode(alloc, &pixels, 2, 1, .rgb, .srgb);
    defer alloc.free(encoded);

    var result = try decoder.decode(alloc, encoded);
    defer result.deinit(alloc);

    try std.testing.expect(result.pixels[0].eql(Pixel{ .r = 1, .g = 1, .b = 1, .a = 255 }));
    try std.testing.expect(result.pixels[1].eql(Pixel{ .r = 0, .g = 0, .b = 0, .a = 255 }));
}

test "wraparound: 128 - 130 = 254 via diff" {
    const a = Pixel{ .r = 128, .g = 128, .b = 128, .a = 255 };
    const b = Pixel{ .r = 130, .g = 130, .b = 130, .a = 255 };
    const d = a.diff(b);
    // 128 - 130 = -2 = 254 unsigned. fitsSmallDiff? 254+%2=0 < 4. Yes!
    try std.testing.expectEqual(@as(u8, 254), d.dr);
    try std.testing.expect(d.fitsSmallDiff());
}

test "wraparound: large difference round-trip" {
    const alloc = std.testing.allocator;
    // Pixels that force wraparound in luma range
    // prev = (250, 250, 250, 255), cur = (5, 5, 5, 255)
    // diff: 5-250 = 11 unsigned. dg=11, 11+%32=43 < 64. dr_dg=0, db_dg=0. Fits luma.
    const pixels = [_]u8{ 250, 250, 250, 5, 5, 5 };
    const encoded = try encoder.encode(alloc, &pixels, 2, 1, .rgb, .srgb);
    defer alloc.free(encoded);

    var result = try decoder.decode(alloc, encoded);
    defer result.deinit(alloc);

    try std.testing.expect(result.pixels[0].eql(Pixel{ .r = 250, .g = 250, .b = 250, .a = 255 }));
    try std.testing.expect(result.pixels[1].eql(Pixel{ .r = 5, .g = 5, .b = 5, .a = 255 }));
}

// ═══════════════════════════════════════════════════════════════════════════
// End marker
// ═══════════════════════════════════════════════════════════════════════════

test "end marker value is 7 zero bytes + 0x01" {
    try std.testing.expectEqual([8]u8{ 0, 0, 0, 0, 0, 0, 0, 1 }, qoi.QOI_END_MARKER);
}

test "end marker present at end of every encoded file" {
    const alloc = std.testing.allocator;

    // Test with different image sizes
    const test_cases = [_]struct { w: u32, h: u32 }{
        .{ .w = 1, .h = 1 },
        .{ .w = 2, .h = 2 },
        .{ .w = 10, .h = 10 },
    };

    for (test_cases) |tc| {
        const count = tc.w * tc.h * 3;
        const pixels = try alloc.alloc(u8, count);
        defer alloc.free(pixels);
        @memset(pixels, 128);

        const encoded = try encoder.encode(alloc, pixels, tc.w, tc.h, .rgb, .srgb);
        defer alloc.free(encoded);

        try std.testing.expectEqualSlices(u8, &qoi.QOI_END_MARKER, encoded[encoded.len - 8 ..]);
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// Error cases
// ═══════════════════════════════════════════════════════════════════════════

test "decode error: invalid magic bytes" {
    const alloc = std.testing.allocator;
    var buf: [qoi.QOI_HEADER_SIZE + 1 + qoi.QOI_END_MARKER.len]u8 = undefined;
    const hdr = QoiHeader{ .width = 1, .height = 1, .channels = .rgb, .colorspace = .srgb };
    @memcpy(buf[0..qoi.QOI_HEADER_SIZE], &hdr.encode());
    buf[qoi.QOI_HEADER_SIZE] = qoi.QOI_OP_RUN | 0;
    @memcpy(buf[qoi.QOI_HEADER_SIZE + 1 ..][0..8], &qoi.QOI_END_MARKER);

    // Corrupt magic
    buf[0] = 'X';
    buf[1] = 'Y';
    try std.testing.expectError(DecodeError.InvalidMagic, decoder.decode(alloc, &buf));
}

test "decode error: truncated data (only header)" {
    const alloc = std.testing.allocator;
    const hdr = QoiHeader{ .width = 1, .height = 1, .channels = .rgb, .colorspace = .srgb };
    const header_bytes = hdr.encode();
    try std.testing.expectError(DecodeError.UnexpectedEndOfData, decoder.decode(alloc, &header_bytes));
}

test "decode error: truncated data (too few bytes)" {
    const alloc = std.testing.allocator;
    // Only 5 bytes total — not even a full header
    const buf = [_]u8{ 'q', 'o', 'i', 'f', 0 };
    try std.testing.expectError(DecodeError.UnexpectedEndOfData, decoder.decode(alloc, &buf));
}

test "decode error: invalid end marker" {
    const alloc = std.testing.allocator;
    var buf: [qoi.QOI_HEADER_SIZE + 1 + qoi.QOI_END_MARKER.len]u8 = undefined;
    const hdr = QoiHeader{ .width = 1, .height = 1, .channels = .rgb, .colorspace = .srgb };
    @memcpy(buf[0..qoi.QOI_HEADER_SIZE], &hdr.encode());
    buf[qoi.QOI_HEADER_SIZE] = qoi.QOI_OP_RUN | 0;
    @memcpy(buf[qoi.QOI_HEADER_SIZE + 1 ..][0..8], &qoi.QOI_END_MARKER);
    // Corrupt end marker
    buf[buf.len - 1] = 0x00; // should be 0x01
    try std.testing.expectError(DecodeError.InvalidEndMarker, decoder.decode(alloc, &buf));
}

test "decode error: invalid channels value" {
    const alloc = std.testing.allocator;
    var buf: [qoi.QOI_HEADER_SIZE + 1 + qoi.QOI_END_MARKER.len]u8 = undefined;
    const hdr = QoiHeader{ .width = 1, .height = 1, .channels = .rgb, .colorspace = .srgb };
    @memcpy(buf[0..qoi.QOI_HEADER_SIZE], &hdr.encode());
    buf[12] = 5; // invalid channels
    buf[qoi.QOI_HEADER_SIZE] = qoi.QOI_OP_RUN | 0;
    @memcpy(buf[qoi.QOI_HEADER_SIZE + 1 ..][0..8], &qoi.QOI_END_MARKER);
    try std.testing.expectError(DecodeError.InvalidChannels, decoder.decode(alloc, &buf));
}

test "decode error: invalid colorspace value" {
    const alloc = std.testing.allocator;
    var buf: [qoi.QOI_HEADER_SIZE + 1 + qoi.QOI_END_MARKER.len]u8 = undefined;
    const hdr = QoiHeader{ .width = 1, .height = 1, .channels = .rgb, .colorspace = .srgb };
    @memcpy(buf[0..qoi.QOI_HEADER_SIZE], &hdr.encode());
    buf[13] = 2; // invalid colorspace
    buf[qoi.QOI_HEADER_SIZE] = qoi.QOI_OP_RUN | 0;
    @memcpy(buf[qoi.QOI_HEADER_SIZE + 1 ..][0..8], &qoi.QOI_END_MARKER);
    try std.testing.expectError(DecodeError.InvalidColorspace, decoder.decode(alloc, &buf));
}

test "encode error: invalid pixel data length" {
    const alloc = std.testing.allocator;
    // 1x1 RGB should need 3 bytes, provide 2
    const pixels = [_]u8{ 0, 0 };
    try std.testing.expectError(error.InvalidPixelDataLength, encoder.encode(alloc, &pixels, 1, 1, .rgb, .srgb));
}

test "encode error: invalid pixel data length RGBA" {
    const alloc = std.testing.allocator;
    // 1x1 RGBA should need 4 bytes, provide 3
    const pixels = [_]u8{ 0, 0, 0 };
    try std.testing.expectError(error.InvalidPixelDataLength, encoder.encode(alloc, &pixels, 1, 1, .rgba, .srgb));
}

test "decode error: data truncated mid-chunk (QOI_OP_RGB)" {
    const alloc = std.testing.allocator;
    // QOI_OP_RGB needs 4 bytes but we only provide the tag + 2 bytes before end marker
    var buf: [qoi.QOI_HEADER_SIZE + 3 + qoi.QOI_END_MARKER.len]u8 = undefined;
    const hdr = QoiHeader{ .width = 1, .height = 1, .channels = .rgb, .colorspace = .srgb };
    @memcpy(buf[0..qoi.QOI_HEADER_SIZE], &hdr.encode());
    buf[qoi.QOI_HEADER_SIZE + 0] = qoi.QOI_OP_RGB;
    buf[qoi.QOI_HEADER_SIZE + 1] = 10;
    buf[qoi.QOI_HEADER_SIZE + 2] = 20;
    @memcpy(buf[qoi.QOI_HEADER_SIZE + 3 ..][0..8], &qoi.QOI_END_MARKER);

    try std.testing.expectError(DecodeError.UnexpectedEndOfData, decoder.decode(alloc, &buf));
}

test "decode error: zero dimensions" {
    const alloc = std.testing.allocator;
    // Manually craft a header with width=0
    var buf: [qoi.QOI_HEADER_SIZE + 1 + qoi.QOI_END_MARKER.len]u8 = undefined;
    @memcpy(buf[0..4], &qoi.QOI_MAGIC);
    std.mem.writeInt(u32, buf[4..8], 0, .big); // width = 0
    std.mem.writeInt(u32, buf[8..12], 1, .big); // height = 1
    buf[12] = 3; // channels = rgb
    buf[13] = 0; // colorspace = srgb
    buf[qoi.QOI_HEADER_SIZE] = qoi.QOI_OP_RUN | 0;
    @memcpy(buf[qoi.QOI_HEADER_SIZE + 1 ..][0..8], &qoi.QOI_END_MARKER);

    try std.testing.expectError(DecodeError.InvalidDimensions, decoder.decode(alloc, &buf));
}

// ═══════════════════════════════════════════════════════════════════════════
// ChannelDiff helpers
// ═══════════════════════════════════════════════════════════════════════════

test "fitsSmallDiff boundary: exactly -2" {
    // dr = -2 → unsigned 254. 254+%2 = 0 < 4. Should fit.
    const d = ChannelDiff{ .dr = 254, .dg = 0, .db = 0, .da = 0 };
    try std.testing.expect(d.fitsSmallDiff());
}

test "fitsSmallDiff boundary: exactly +1" {
    // dr = 1 → unsigned 1. 1+%2 = 3 < 4. Should fit.
    const d = ChannelDiff{ .dr = 1, .dg = 0, .db = 0, .da = 0 };
    try std.testing.expect(d.fitsSmallDiff());
}

test "fitsSmallDiff boundary: +2 does not fit" {
    // dr = 2 → unsigned 2. 2+%2 = 4, not < 4. Should NOT fit.
    const d = ChannelDiff{ .dr = 2, .dg = 0, .db = 0, .da = 0 };
    try std.testing.expect(!d.fitsSmallDiff());
}

test "fitsSmallDiff boundary: -3 does not fit" {
    // dr = -3 → unsigned 253. 253+%2 = 255, not < 4. Should NOT fit.
    const d = ChannelDiff{ .dr = 253, .dg = 0, .db = 0, .da = 0 };
    try std.testing.expect(!d.fitsSmallDiff());
}

test "fitsLumaDiff boundary: green = -32 (unsigned 224)" {
    // dg = 224. 224+%32 = 0 < 64. Fits green.
    // dr_dg = dr - dg. dr = 224 (same as dg) → dr_dg = 0. 0+%8=8 < 16.
    // db_dg similarly.
    const d = ChannelDiff{ .dr = 224, .dg = 224, .db = 224, .da = 0 };
    try std.testing.expect(d.fitsLumaDiff());
}

test "fitsLumaDiff boundary: green = +31 (unsigned 31)" {
    // dg = 31. 31+%32 = 63 < 64. Fits green.
    const d = ChannelDiff{ .dr = 31, .dg = 31, .db = 31, .da = 0 };
    try std.testing.expect(d.fitsLumaDiff());
}

test "fitsLumaDiff boundary: green = +32 does not fit" {
    // dg = 32. 32+%32 = 64, not < 64. Does NOT fit.
    const d = ChannelDiff{ .dr = 32, .dg = 32, .db = 32, .da = 0 };
    try std.testing.expect(!d.fitsLumaDiff());
}

test "fitsLumaDiff: alpha change prevents fit" {
    const d = ChannelDiff{ .dr = 0, .dg = 0, .db = 0, .da = 1 };
    try std.testing.expect(!d.fitsLumaDiff());
}

// ═══════════════════════════════════════════════════════════════════════════
// Additional round-trip edge cases
// ═══════════════════════════════════════════════════════════════════════════

test "round-trip all same pixel triggers long run sequences" {
    const alloc = std.testing.allocator;
    // 200 identical pixels → multiple run chunks (max 62 each)
    const count: u32 = 200;
    var pixels: [count * 3]u8 = undefined;
    @memset(&pixels, 42);

    const encoded = try encoder.encode(alloc, &pixels, count, 1, .rgb, .srgb);
    defer alloc.free(encoded);

    var result = try decoder.decode(alloc, encoded);
    defer result.deinit(alloc);

    try std.testing.expectEqual(@as(usize, count), result.pixels.len);
    // First pixel (42,42,42) differs from default (0,0,0), rest are runs
    for (result.pixels) |px| {
        try std.testing.expectEqual(@as(u8, 42), px.r);
        try std.testing.expectEqual(@as(u8, 42), px.g);
        try std.testing.expectEqual(@as(u8, 42), px.b);
    }
}

test "round-trip pixel at every channel extreme" {
    const alloc = std.testing.allocator;
    const pixels = [_]u8{
        0,   0,   0,   0, //   all zeros
        255, 255, 255, 255, // all max
        0,   0,   0,   255, // black opaque
        255, 0,   0,   255, // red
        0,   255, 0,   255, // green
        0,   0,   255, 255, // blue
    };
    const encoded = try encoder.encode(alloc, &pixels, 6, 1, .rgba, .srgb);
    defer alloc.free(encoded);

    var result = try decoder.decode(alloc, encoded);
    defer result.deinit(alloc);

    try std.testing.expectEqual(@as(usize, 6), result.pixels.len);
    try std.testing.expect(result.pixels[0].eql(Pixel{ .r = 0, .g = 0, .b = 0, .a = 0 }));
    try std.testing.expect(result.pixels[1].eql(Pixel{ .r = 255, .g = 255, .b = 255, .a = 255 }));
    try std.testing.expect(result.pixels[2].eql(Pixel{ .r = 0, .g = 0, .b = 0, .a = 255 }));
    try std.testing.expect(result.pixels[3].eql(Pixel{ .r = 255, .g = 0, .b = 0, .a = 255 }));
    try std.testing.expect(result.pixels[4].eql(Pixel{ .r = 0, .g = 255, .b = 0, .a = 255 }));
    try std.testing.expect(result.pixels[5].eql(Pixel{ .r = 0, .g = 0, .b = 255, .a = 255 }));
}

test "round-trip non-square image" {
    const alloc = std.testing.allocator;
    const width: u32 = 3;
    const height: u32 = 7;
    var pixels: [width * height * 3]u8 = undefined;
    for (0..width * height) |i| {
        pixels[i * 3 + 0] = @truncate(i * 12);
        pixels[i * 3 + 1] = @truncate(i * 34);
        pixels[i * 3 + 2] = @truncate(i * 56);
    }

    const encoded = try encoder.encode(alloc, &pixels, width, height, .rgb, .srgb);
    defer alloc.free(encoded);

    var result = try decoder.decode(alloc, encoded);
    defer result.deinit(alloc);

    try std.testing.expectEqual(@as(u32, width), result.header.width);
    try std.testing.expectEqual(@as(u32, height), result.header.height);
    for (0..width * height) |i| {
        const expected_r: u8 = @truncate(i * 12);
        const expected_g: u8 = @truncate(i * 34);
        const expected_b: u8 = @truncate(i * 56);
        try std.testing.expectEqual(expected_r, result.pixels[i].r);
        try std.testing.expectEqual(expected_g, result.pixels[i].g);
        try std.testing.expectEqual(expected_b, result.pixels[i].b);
    }
}
