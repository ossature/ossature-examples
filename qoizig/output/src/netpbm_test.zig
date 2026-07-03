const std = @import("std");
const types = @import("types.zig");
const netpbm = @import("netpbm.zig");
const Pixel = types.Pixel;

test "Netpbm PAM depth-3 parsing and writing" {
    const allocator = std.testing.allocator;

    const pixels = try allocator.alloc(Pixel, 4);
    defer allocator.free(pixels);
    pixels[0] = Pixel{ .r = 10, .g = 20, .b = 30, .a = 255 };
    pixels[1] = Pixel{ .r = 40, .g = 50, .b = 60, .a = 255 };
    pixels[2] = Pixel{ .r = 70, .g = 80, .b = 90, .a = 255 };
    pixels[3] = Pixel{ .r = 100, .g = 110, .b = 120, .a = 255 };

    var buf = std.ArrayList(u8).empty;
    defer buf.deinit(allocator);

    // Write as Depth-3 PAM (channels = 3)
    try netpbm.writePam(buf.writer(allocator), 2, 2, 3, pixels);

    // Verify it is indeed written with DEPTH 3 and TUPLTYPE RGB
    const header_str = buf.items[0..@min(buf.items.len, 200)];
    try std.testing.expect(std.mem.indexOf(u8, header_str, "DEPTH 3") != null);
    try std.testing.expect(std.mem.indexOf(u8, header_str, "TUPLTYPE RGB") != null);

    // Read back and verify
    var fbs = std.io.fixedBufferStream(buf.items);
    const img = try netpbm.read(allocator, fbs.reader());
    defer img.deinit(allocator);

    try std.testing.expectEqual(@as(u32, 2), img.width);
    try std.testing.expectEqual(@as(u32, 2), img.height);
    try std.testing.expectEqual(@as(u8, 3), img.channels);
    try std.testing.expectEqual(pixels[0].r, img.pixels[0].r);
    try std.testing.expectEqual(pixels[0].g, img.pixels[0].g);
    try std.testing.expectEqual(pixels[0].b, img.pixels[0].b);
    try std.testing.expectEqual(@as(u8, 255), img.pixels[0].a);
}

test "Netpbm PAM depth-4 parsing and writing" {
    const allocator = std.testing.allocator;

    const pixels = try allocator.alloc(Pixel, 2);
    defer allocator.free(pixels);
    pixels[0] = Pixel{ .r = 12, .g = 34, .b = 56, .a = 78 };
    pixels[1] = Pixel{ .r = 90, .g = 12, .b = 34, .a = 56 };

    var buf = std.ArrayList(u8).empty;
    defer buf.deinit(allocator);

    // Write as Depth-4 PAM (channels = 4)
    try netpbm.writePam(buf.writer(allocator), 2, 1, 4, pixels);

    // Verify written header
    const header_str = buf.items[0..@min(buf.items.len, 200)];
    try std.testing.expect(std.mem.indexOf(u8, header_str, "DEPTH 4") != null);
    try std.testing.expect(std.mem.indexOf(u8, header_str, "TUPLTYPE RGB_ALPHA") != null);

    // Read back and verify
    var fbs = std.io.fixedBufferStream(buf.items);
    const img = try netpbm.read(allocator, fbs.reader());
    defer img.deinit(allocator);

    try std.testing.expectEqual(@as(u32, 2), img.width);
    try std.testing.expectEqual(@as(u32, 1), img.height);
    try std.testing.expectEqual(@as(u8, 4), img.channels);
    try std.testing.expectEqual(pixels[0].r, img.pixels[0].r);
    try std.testing.expectEqual(pixels[0].g, img.pixels[0].g);
    try std.testing.expectEqual(pixels[0].b, img.pixels[0].b);
    try std.testing.expectEqual(pixels[0].a, img.pixels[0].a);
}

test "Netpbm whitespace tolerance and comment parsing" {
    const allocator = std.testing.allocator;

    // We use a header with multiple consecutive spaces, tabs, carriage returns, newlines,
    // and comments inserted in multiple places.
    const tricky_pam =
        "P7\n" ++
        "# A comment here\n" ++
        "  WIDTH   \t 2 # Comment after width identifier\n" ++
        "# another comment\n" ++
        "HEIGHT \n" ++
        "# mid comment\n" ++
        "1\n" ++
        "  DEPTH\t3#comment\n" ++
        "MAXVAL   255\n" ++
        "TUPLTYPE   RGB\n" ++
        "# final comment\n" ++
        "ENDHDR\n";

    var full_pam = std.ArrayList(u8).empty;
    defer full_pam.deinit(allocator);
    try full_pam.appendSlice(allocator, tricky_pam);
    
    // Add raw image data: 2 pixels of 3 channels (RGB)
    const raw_data = [_]u8{
        1, 2, 3,
        4, 5, 6,
    };
    try full_pam.appendSlice(allocator, &raw_data);
    try full_pam.appendSlice(allocator, " \r\n\t "); // trailing whitespace

    var fbs = std.io.fixedBufferStream(full_pam.items);
    const img = try netpbm.read(allocator, fbs.reader());
    defer img.deinit(allocator);

    try std.testing.expectEqual(@as(u32, 2), img.width);
    try std.testing.expectEqual(@as(u32, 1), img.height);
    try std.testing.expectEqual(@as(u8, 3), img.channels);
    try std.testing.expectEqual(@as(u8, 1), img.pixels[0].r);
    try std.testing.expectEqual(@as(u8, 2), img.pixels[0].g);
    try std.testing.expectEqual(@as(u8, 3), img.pixels[0].b);
    try std.testing.expectEqual(@as(u8, 255), img.pixels[0].a);
    try std.testing.expectEqual(@as(u8, 4), img.pixels[1].r);
    try std.testing.expectEqual(@as(u8, 5), img.pixels[1].g);
    try std.testing.expectEqual(@as(u8, 6), img.pixels[1].b);
    try std.testing.expectEqual(@as(u8, 255), img.pixels[1].a);
}

test "Netpbm PAM header validity and edge case errors" {
    const allocator = std.testing.allocator;

    // Test cases that should return errors

    // 1. Invalid Width
    const bad_width =
        "P7\n" ++
        "WIDTH abc\n" ++
        "HEIGHT 1\n" ++
        "DEPTH 3\n" ++
        "MAXVAL 255\n" ++
        "ENDHDR\n";
    {
        var fbs = std.io.fixedBufferStream(bad_width);
        try std.testing.expectError(error.InvalidHeader, netpbm.read(allocator, fbs.reader()));
    }

    // 2. Zero Width
    const zero_width =
        "P7\n" ++
        "WIDTH 0\n" ++
        "HEIGHT 1\n" ++
        "DEPTH 3\n" ++
        "MAXVAL 255\n" ++
        "ENDHDR\n";
    {
        var fbs = std.io.fixedBufferStream(zero_width);
        try std.testing.expectError(error.InvalidDimensions, netpbm.read(allocator, fbs.reader()));
    }

    // 3. Zero Height
    const zero_height =
        "P7\n" ++
        "WIDTH 1\n" ++
        "HEIGHT 0\n" ++
        "DEPTH 3\n" ++
        "MAXVAL 255\n" ++
        "ENDHDR\n";
    {
        var fbs = std.io.fixedBufferStream(zero_height);
        try std.testing.expectError(error.InvalidDimensions, netpbm.read(allocator, fbs.reader()));
    }

    // 4. Missing ENDHDR
    const missing_endhdr =
        "P7\n" ++
        "WIDTH 1\n" ++
        "HEIGHT 1\n" ++
        "DEPTH 3\n" ++
        "MAXVAL 255";
    {
        var fbs = std.io.fixedBufferStream(missing_endhdr);
        try std.testing.expectError(error.InvalidHeader, netpbm.read(allocator, fbs.reader()));
    }

    // 5. Unknown Header Key is tolerated but missing values is bad
    const bad_unknown_val =
        "P7\n" ++
        "WIDTH 1\n" ++
        "HEIGHT 1\n" ++
        "FOOBAR\n" ++
        "DEPTH 3\n" ++
        "MAXVAL 255\n" ++
        "ENDHDR\n";
    {
        var fbs = std.io.fixedBufferStream(bad_unknown_val);
        try std.testing.expectError(error.InvalidHeader, netpbm.read(allocator, fbs.reader()));
    }

    // 6. Tupltype exceeds buffer size (long invalid tupltype)
    const long_tupltype =
        "P7\n" ++
        "WIDTH 1\n" ++
        "HEIGHT 1\n" ++
        "DEPTH 3\n" ++
        "MAXVAL 255\n" ++
        "TUPLTYPE THIS_IS_A_WAY_TOO_LONG_TUPLTYPE_NAME_THAT_EXCEEDS_SIXTY_FOUR_BYTES_TUPLE_TYPE_DEFINITIONS\n" ++
        "ENDHDR\n";
    {
        var fbs = std.io.fixedBufferStream(long_tupltype);
        try std.testing.expectError(error.InvalidHeader, netpbm.read(allocator, fbs.reader()));
    }
}

test "Netpbm PPM writer invalid dimensions" {
    const pixels = [_]Pixel{
        Pixel{ .r = 0, .g = 0, .b = 0, .a = 255 },
    };

    var buf = std.ArrayList(u8).empty;
    defer buf.deinit(std.testing.allocator);

    // Writing 1 pixel with 2x2 dimensions should fail
    try std.testing.expectError(error.InvalidDimensions, netpbm.writePpm(buf.writer(std.testing.allocator), 2, 2, &pixels));
}

test "Netpbm PAM writer invalid dimensions and depth" {
    const pixels = [_]Pixel{
        Pixel{ .r = 0, .g = 0, .b = 0, .a = 255 },
    };

    var buf = std.ArrayList(u8).empty;
    defer buf.deinit(std.testing.allocator);

    // 1. Invalid dimensions
    try std.testing.expectError(error.InvalidDimensions, netpbm.writePam(buf.writer(std.testing.allocator), 2, 2, 3, &pixels));

    // 2. Unsupported depth (e.g., 2 or 5)
    try std.testing.expectError(error.UnsupportedDepth, netpbm.writePam(buf.writer(std.testing.allocator), 1, 1, 2, &pixels));
    try std.testing.expectError(error.UnsupportedDepth, netpbm.writePam(buf.writer(std.testing.allocator), 1, 1, 5, &pixels));
}

comptime {
    _ = @import("stubs.zig");
}
