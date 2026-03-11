const std = @import("std");
const image_io = @import("image_io.zig");

const ImageData = image_io.ImageData;
const readPpm = image_io.readPpm;
const readPam = image_io.readPam;
const writePpm = image_io.writePpm;
const writePam = image_io.writePam;
const readImage = image_io.readImage;
const writeImage = image_io.writeImage;

// ── PPM P6 Round-Trip Tests ─────────────────────────────────────────────────

test "PPM round-trip: single pixel" {
    const allocator = std.testing.allocator;
    const pixels = [_]u8{ 255, 128, 0 };

    const ppm_data = try writePpm(allocator, 1, 1, &pixels);
    defer allocator.free(ppm_data);

    var img = try readPpm(allocator, ppm_data);
    defer img.deinit();

    try std.testing.expectEqual(@as(u32, 1), img.width);
    try std.testing.expectEqual(@as(u32, 1), img.height);
    try std.testing.expectEqual(@as(u8, 3), img.channels);
    try std.testing.expectEqualSlices(u8, &pixels, img.pixels);
}

test "PPM round-trip: 2x2 image" {
    const allocator = std.testing.allocator;
    const pixels = [_]u8{
        255, 0,   0, // red
        0,   255, 0, // green
        0,   0,   255, // blue
        128, 128, 128, // gray
    };

    const ppm_data = try writePpm(allocator, 2, 2, &pixels);
    defer allocator.free(ppm_data);

    var img = try readPpm(allocator, ppm_data);
    defer img.deinit();

    try std.testing.expectEqual(@as(u32, 2), img.width);
    try std.testing.expectEqual(@as(u32, 2), img.height);
    try std.testing.expectEqual(@as(u8, 3), img.channels);
    try std.testing.expectEqualSlices(u8, &pixels, img.pixels);
}

test "PPM round-trip: larger image" {
    const allocator = std.testing.allocator;
    const width: u32 = 10;
    const height: u32 = 5;
    const count = @as(usize, width) * @as(usize, height) * 3;
    const pixels = try allocator.alloc(u8, count);
    defer allocator.free(pixels);
    for (0..count) |i| {
        pixels[i] = @truncate(i);
    }

    const ppm_data = try writePpm(allocator, width, height, pixels);
    defer allocator.free(ppm_data);

    var img = try readPpm(allocator, ppm_data);
    defer img.deinit();

    try std.testing.expectEqual(width, img.width);
    try std.testing.expectEqual(height, img.height);
    try std.testing.expectEqual(@as(u8, 3), img.channels);
    try std.testing.expectEqualSlices(u8, pixels, img.pixels);
}

test "PPM round-trip: all-zero pixels" {
    const allocator = std.testing.allocator;
    const pixels = [_]u8{0} ** (3 * 4); // 2x2 black

    const ppm_data = try writePpm(allocator, 2, 2, &pixels);
    defer allocator.free(ppm_data);

    var img = try readPpm(allocator, ppm_data);
    defer img.deinit();

    try std.testing.expectEqualSlices(u8, &pixels, img.pixels);
}

test "PPM round-trip: all-255 pixels" {
    const allocator = std.testing.allocator;
    const pixels = [_]u8{255} ** (3 * 4); // 2x2 white

    const ppm_data = try writePpm(allocator, 2, 2, &pixels);
    defer allocator.free(ppm_data);

    var img = try readPpm(allocator, ppm_data);
    defer img.deinit();

    try std.testing.expectEqualSlices(u8, &pixels, img.pixels);
}

// ── PPM P6 Header Parsing Edge Cases ────────────────────────────────────────

test "PPM: header with comments" {
    const allocator = std.testing.allocator;
    const data = "P6\n# This is a comment\n1 1\n255\n" ++ [_]u8{ 42, 43, 44 };

    var img = try readPpm(allocator, data);
    defer img.deinit();

    try std.testing.expectEqual(@as(u32, 1), img.width);
    try std.testing.expectEqual(@as(u32, 1), img.height);
    try std.testing.expectEqualSlices(u8, &[_]u8{ 42, 43, 44 }, img.pixels);
}

test "PPM: header with multiple comments" {
    const allocator = std.testing.allocator;
    const data = "P6\n# comment 1\n# comment 2\n2 1\n255\n" ++ [_]u8{ 1, 2, 3, 4, 5, 6 };

    var img = try readPpm(allocator, data);
    defer img.deinit();

    try std.testing.expectEqual(@as(u32, 2), img.width);
    try std.testing.expectEqual(@as(u32, 1), img.height);
    try std.testing.expectEqualSlices(u8, &[_]u8{ 1, 2, 3, 4, 5, 6 }, img.pixels);
}

test "PPM: header with spaces instead of newlines between dimensions" {
    const allocator = std.testing.allocator;
    const data = "P6 1 1 255\n" ++ [_]u8{ 10, 20, 30 };

    var img = try readPpm(allocator, data);
    defer img.deinit();

    try std.testing.expectEqual(@as(u32, 1), img.width);
    try std.testing.expectEqual(@as(u32, 1), img.height);
}

test "PPM: header with tab whitespace" {
    const allocator = std.testing.allocator;
    const data = "P6\t1\t1\t255\n" ++ [_]u8{ 10, 20, 30 };

    var img = try readPpm(allocator, data);
    defer img.deinit();

    try std.testing.expectEqual(@as(u32, 1), img.width);
    try std.testing.expectEqual(@as(u32, 1), img.height);
}

// ── PPM P6 Error Handling ───────────────────────────────────────────────────

test "PPM: invalid magic bytes - P5" {
    const allocator = std.testing.allocator;
    const result = readPpm(allocator, "P5\n2 2\n255\n" ++ "\x00" ** 12);
    try std.testing.expectError(error.InvalidHeader, result);
}

test "PPM: invalid magic bytes - P7" {
    const allocator = std.testing.allocator;
    const result = readPpm(allocator, "P7\n2 2\n255\n" ++ "\x00" ** 12);
    try std.testing.expectError(error.InvalidHeader, result);
}

test "PPM: invalid magic bytes - random" {
    const allocator = std.testing.allocator;
    const result = readPpm(allocator, "XX\n1 1\n255\n" ++ "\x00" ** 3);
    try std.testing.expectError(error.InvalidHeader, result);
}

test "PPM: empty input" {
    const allocator = std.testing.allocator;
    const result = readPpm(allocator, "");
    try std.testing.expectError(error.InvalidHeader, result);
}

test "PPM: single byte input" {
    const allocator = std.testing.allocator;
    const result = readPpm(allocator, "P");
    try std.testing.expectError(error.InvalidHeader, result);
}

test "PPM: header only, no pixel data" {
    const allocator = std.testing.allocator;
    const result = readPpm(allocator, "P6\n2 2\n255\n");
    try std.testing.expectError(error.SizeMismatch, result);
}

test "PPM: size mismatch - too little pixel data" {
    const allocator = std.testing.allocator;
    const result = readPpm(allocator, "P6\n2 2\n255\n" ++ "\x00" ** 11);
    try std.testing.expectError(error.SizeMismatch, result);
}

test "PPM: size mismatch - too much pixel data" {
    const allocator = std.testing.allocator;
    const result = readPpm(allocator, "P6\n2 2\n255\n" ++ "\x00" ** 13);
    try std.testing.expectError(error.SizeMismatch, result);
}

test "PPM: zero width" {
    const allocator = std.testing.allocator;
    const result = readPpm(allocator, "P6\n0 1\n255\n");
    try std.testing.expectError(error.InvalidHeader, result);
}

test "PPM: zero height" {
    const allocator = std.testing.allocator;
    const result = readPpm(allocator, "P6\n1 0\n255\n");
    try std.testing.expectError(error.InvalidHeader, result);
}

test "PPM: unsupported maxval (not 255)" {
    const allocator = std.testing.allocator;
    const result = readPpm(allocator, "P6\n1 1\n65535\n" ++ "\x00" ** 3);
    try std.testing.expectError(error.UnsupportedFormat, result);
}

test "PPM: maxval 0" {
    const allocator = std.testing.allocator;
    const result = readPpm(allocator, "P6\n1 1\n0\n" ++ "\x00" ** 3);
    try std.testing.expectError(error.UnsupportedFormat, result);
}

test "PPM: maxval 128" {
    const allocator = std.testing.allocator;
    const result = readPpm(allocator, "P6\n1 1\n128\n" ++ "\x00" ** 3);
    try std.testing.expectError(error.UnsupportedFormat, result);
}

test "PPM: missing maxval" {
    const allocator = std.testing.allocator;
    const result = readPpm(allocator, "P6\n1 1\n");
    try std.testing.expectError(error.InvalidHeader, result);
}

test "PPM: missing height" {
    const allocator = std.testing.allocator;
    const result = readPpm(allocator, "P6\n1\n");
    try std.testing.expectError(error.InvalidHeader, result);
}

test "PPM writer: size mismatch" {
    const allocator = std.testing.allocator;
    const pixels = [_]u8{ 1, 2 }; // too few for 1x1
    const result = writePpm(allocator, 1, 1, &pixels);
    try std.testing.expectError(error.SizeMismatch, result);
}

test "PPM writer: size mismatch - too many pixels" {
    const allocator = std.testing.allocator;
    const pixels = [_]u8{ 1, 2, 3, 4 }; // too many for 1x1
    const result = writePpm(allocator, 1, 1, &pixels);
    try std.testing.expectError(error.SizeMismatch, result);
}

// ── PAM P7 Round-Trip Tests ─────────────────────────────────────────────────

test "PAM round-trip: single pixel" {
    const allocator = std.testing.allocator;
    const pixels = [_]u8{ 255, 128, 0, 200 };

    const pam_data = try writePam(allocator, 1, 1, &pixels);
    defer allocator.free(pam_data);

    var img = try readPam(allocator, pam_data);
    defer img.deinit();

    try std.testing.expectEqual(@as(u32, 1), img.width);
    try std.testing.expectEqual(@as(u32, 1), img.height);
    try std.testing.expectEqual(@as(u8, 4), img.channels);
    try std.testing.expectEqualSlices(u8, &pixels, img.pixels);
}

test "PAM round-trip: 2x1 image" {
    const allocator = std.testing.allocator;
    const pixels = [_]u8{
        255, 0,   0,   255, // red opaque
        0,   255, 0,   128, // green half-transparent
    };

    const pam_data = try writePam(allocator, 2, 1, &pixels);
    defer allocator.free(pam_data);

    var img = try readPam(allocator, pam_data);
    defer img.deinit();

    try std.testing.expectEqual(@as(u32, 2), img.width);
    try std.testing.expectEqual(@as(u32, 1), img.height);
    try std.testing.expectEqual(@as(u8, 4), img.channels);
    try std.testing.expectEqualSlices(u8, &pixels, img.pixels);
}

test "PAM round-trip: 3x2 image" {
    const allocator = std.testing.allocator;
    const width: u32 = 3;
    const height: u32 = 2;
    const count = @as(usize, width) * @as(usize, height) * 4;
    const pixels = try allocator.alloc(u8, count);
    defer allocator.free(pixels);
    for (0..count) |i| {
        pixels[i] = @truncate(i * 7);
    }

    const pam_data = try writePam(allocator, width, height, pixels);
    defer allocator.free(pam_data);

    var img = try readPam(allocator, pam_data);
    defer img.deinit();

    try std.testing.expectEqual(width, img.width);
    try std.testing.expectEqual(height, img.height);
    try std.testing.expectEqual(@as(u8, 4), img.channels);
    try std.testing.expectEqualSlices(u8, pixels, img.pixels);
}

test "PAM round-trip: all-zero pixels" {
    const allocator = std.testing.allocator;
    const pixels = [_]u8{0} ** (4 * 4); // 2x2 transparent black

    const pam_data = try writePam(allocator, 2, 2, &pixels);
    defer allocator.free(pam_data);

    var img = try readPam(allocator, pam_data);
    defer img.deinit();

    try std.testing.expectEqualSlices(u8, &pixels, img.pixels);
}

// ── PAM P7 Header Parsing Edge Cases ────────────────────────────────────────

test "PAM: header with comments" {
    const allocator = std.testing.allocator;
    const data = "P7\n# A comment\nWIDTH 1\nHEIGHT 1\nDEPTH 4\nMAXVAL 255\nTUPLTYPE RGB_ALPHA\nENDHDR\n" ++ [_]u8{ 10, 20, 30, 40 };

    var img = try readPam(allocator, data);
    defer img.deinit();

    try std.testing.expectEqual(@as(u32, 1), img.width);
    try std.testing.expectEqual(@as(u32, 1), img.height);
    try std.testing.expectEqualSlices(u8, &[_]u8{ 10, 20, 30, 40 }, img.pixels);
}

test "PAM: header fields in different order" {
    const allocator = std.testing.allocator;
    const data = "P7\nMAXVAL 255\nDEPTH 4\nHEIGHT 1\nWIDTH 1\nTUPLTYPE RGB_ALPHA\nENDHDR\n" ++ [_]u8{ 99, 98, 97, 96 };

    var img = try readPam(allocator, data);
    defer img.deinit();

    try std.testing.expectEqual(@as(u32, 1), img.width);
    try std.testing.expectEqual(@as(u32, 1), img.height);
    try std.testing.expectEqualSlices(u8, &[_]u8{ 99, 98, 97, 96 }, img.pixels);
}

test "PAM: header without TUPLTYPE (optional)" {
    const allocator = std.testing.allocator;
    const data = "P7\nWIDTH 1\nHEIGHT 1\nDEPTH 4\nMAXVAL 255\nENDHDR\n" ++ [_]u8{ 10, 20, 30, 40 };

    var img = try readPam(allocator, data);
    defer img.deinit();

    try std.testing.expectEqual(@as(u32, 1), img.width);
    try std.testing.expectEqual(@as(u32, 1), img.height);
    try std.testing.expectEqual(@as(u8, 4), img.channels);
}

// ── PAM P7 Error Handling ───────────────────────────────────────────────────

test "PAM: invalid magic bytes" {
    const allocator = std.testing.allocator;
    const result = readPam(allocator, "P6\nWIDTH 1\nHEIGHT 1\nDEPTH 4\nMAXVAL 255\nENDHDR\n" ++ "\x00" ** 4);
    try std.testing.expectError(error.InvalidHeader, result);
}

test "PAM: empty input" {
    const allocator = std.testing.allocator;
    const result = readPam(allocator, "");
    try std.testing.expectError(error.InvalidHeader, result);
}

test "PAM: missing WIDTH" {
    const allocator = std.testing.allocator;
    const result = readPam(allocator, "P7\nHEIGHT 1\nDEPTH 4\nMAXVAL 255\nENDHDR\n" ++ "\x00" ** 4);
    try std.testing.expectError(error.InvalidHeader, result);
}

test "PAM: missing HEIGHT" {
    const allocator = std.testing.allocator;
    const result = readPam(allocator, "P7\nWIDTH 1\nDEPTH 4\nMAXVAL 255\nENDHDR\n" ++ "\x00" ** 4);
    try std.testing.expectError(error.InvalidHeader, result);
}

test "PAM: missing DEPTH" {
    const allocator = std.testing.allocator;
    const result = readPam(allocator, "P7\nWIDTH 1\nHEIGHT 1\nMAXVAL 255\nENDHDR\n" ++ "\x00" ** 4);
    try std.testing.expectError(error.InvalidHeader, result);
}

test "PAM: missing MAXVAL" {
    const allocator = std.testing.allocator;
    const result = readPam(allocator, "P7\nWIDTH 1\nHEIGHT 1\nDEPTH 4\nENDHDR\n" ++ "\x00" ** 4);
    try std.testing.expectError(error.InvalidHeader, result);
}

test "PAM: unsupported depth (3 instead of 4)" {
    const allocator = std.testing.allocator;
    const result = readPam(allocator, "P7\nWIDTH 1\nHEIGHT 1\nDEPTH 3\nMAXVAL 255\nTUPLTYPE RGB\nENDHDR\n" ++ "\x00" ** 3);
    try std.testing.expectError(error.UnsupportedFormat, result);
}

test "PAM: unsupported maxval (65535)" {
    const allocator = std.testing.allocator;
    const result = readPam(allocator, "P7\nWIDTH 1\nHEIGHT 1\nDEPTH 4\nMAXVAL 65535\nENDHDR\n" ++ "\x00" ** 4);
    try std.testing.expectError(error.UnsupportedFormat, result);
}

test "PAM: unsupported tupltype" {
    const allocator = std.testing.allocator;
    const result = readPam(allocator, "P7\nWIDTH 1\nHEIGHT 1\nDEPTH 4\nMAXVAL 255\nTUPLTYPE GRAYSCALE\nENDHDR\n" ++ "\x00" ** 4);
    try std.testing.expectError(error.UnsupportedFormat, result);
}

test "PAM: zero width" {
    const allocator = std.testing.allocator;
    const result = readPam(allocator, "P7\nWIDTH 0\nHEIGHT 1\nDEPTH 4\nMAXVAL 255\nENDHDR\n");
    try std.testing.expectError(error.InvalidHeader, result);
}

test "PAM: zero height" {
    const allocator = std.testing.allocator;
    const result = readPam(allocator, "P7\nWIDTH 1\nHEIGHT 0\nDEPTH 4\nMAXVAL 255\nENDHDR\n");
    try std.testing.expectError(error.InvalidHeader, result);
}

test "PAM: size mismatch - too little pixel data" {
    const allocator = std.testing.allocator;
    const result = readPam(allocator, "P7\nWIDTH 2\nHEIGHT 2\nDEPTH 4\nMAXVAL 255\nTUPLTYPE RGB_ALPHA\nENDHDR\n" ++ "\x00" ** 15);
    try std.testing.expectError(error.SizeMismatch, result);
}

test "PAM: size mismatch - no pixel data" {
    const allocator = std.testing.allocator;
    const result = readPam(allocator, "P7\nWIDTH 1\nHEIGHT 1\nDEPTH 4\nMAXVAL 255\nENDHDR\n");
    try std.testing.expectError(error.SizeMismatch, result);
}

test "PAM writer: size mismatch - too few pixels" {
    const allocator = std.testing.allocator;
    const pixels = [_]u8{ 1, 2, 3 }; // 3 bytes for 1x1 RGBA
    const result = writePam(allocator, 1, 1, &pixels);
    try std.testing.expectError(error.SizeMismatch, result);
}

test "PAM writer: size mismatch - too many pixels" {
    const allocator = std.testing.allocator;
    const pixels = [_]u8{ 1, 2, 3, 4, 5 }; // 5 bytes for 1x1 RGBA
    const result = writePam(allocator, 1, 1, &pixels);
    try std.testing.expectError(error.SizeMismatch, result);
}

// ── Auto-detect readImage / writeImage ──────────────────────────────────────

test "readImage: auto-detect PPM" {
    const allocator = std.testing.allocator;
    const pixels = [_]u8{ 10, 20, 30 };
    const data = "P6\n1 1\n255\n" ++ pixels;

    var img = try readImage(allocator, data);
    defer img.deinit();

    try std.testing.expectEqual(@as(u8, 3), img.channels);
    try std.testing.expectEqualSlices(u8, &pixels, img.pixels);
}

test "readImage: auto-detect PAM" {
    const allocator = std.testing.allocator;
    const pixels = [_]u8{ 10, 20, 30, 40 };
    const data = "P7\nWIDTH 1\nHEIGHT 1\nDEPTH 4\nMAXVAL 255\nTUPLTYPE RGB_ALPHA\nENDHDR\n" ++ pixels;

    var img = try readImage(allocator, data);
    defer img.deinit();

    try std.testing.expectEqual(@as(u8, 4), img.channels);
    try std.testing.expectEqualSlices(u8, &pixels, img.pixels);
}

test "readImage: unsupported format" {
    const allocator = std.testing.allocator;
    const result = readImage(allocator, "BM" ++ "\x00" ** 10);
    try std.testing.expectError(error.UnsupportedFormat, result);
}

test "readImage: P5 is unsupported" {
    const allocator = std.testing.allocator;
    const result = readImage(allocator, "P5\n1 1\n255\n\x00");
    try std.testing.expectError(error.UnsupportedFormat, result);
}

test "readImage: empty data" {
    const allocator = std.testing.allocator;
    const result = readImage(allocator, "");
    try std.testing.expectError(error.UnsupportedFormat, result);
}

test "writeImage: dispatches to PPM for 3 channels" {
    const allocator = std.testing.allocator;
    const pixels = [_]u8{ 1, 2, 3 };
    const out = try writeImage(allocator, 1, 1, 3, &pixels);
    defer allocator.free(out);

    try std.testing.expect(out[0] == 'P' and out[1] == '6');
}

test "writeImage: dispatches to PAM for 4 channels" {
    const allocator = std.testing.allocator;
    const pixels = [_]u8{ 1, 2, 3, 4 };
    const out = try writeImage(allocator, 1, 1, 4, &pixels);
    defer allocator.free(out);

    try std.testing.expect(out[0] == 'P' and out[1] == '7');
}

test "writeImage: unsupported channel count" {
    const allocator = std.testing.allocator;
    const result = writeImage(allocator, 1, 1, 1, &[_]u8{0});
    try std.testing.expectError(error.UnsupportedFormat, result);

    const result2 = writeImage(allocator, 1, 1, 2, &[_]u8{ 0, 0 });
    try std.testing.expectError(error.UnsupportedFormat, result2);
}

// ── PPM writer output format verification ───────────────────────────────────

test "PPM writer: output starts with correct header" {
    const allocator = std.testing.allocator;
    const pixels = [_]u8{ 1, 2, 3, 4, 5, 6 };
    const out = try writePpm(allocator, 2, 1, &pixels);
    defer allocator.free(out);

    // Check the output starts with "P6\n2 1\n255\n"
    const expected_header = "P6\n2 1\n255\n";
    try std.testing.expect(out.len >= expected_header.len);
    try std.testing.expectEqualSlices(u8, expected_header, out[0..expected_header.len]);
    try std.testing.expectEqualSlices(u8, &pixels, out[expected_header.len..]);
}

test "PAM writer: output starts with correct header" {
    const allocator = std.testing.allocator;
    const pixels = [_]u8{ 1, 2, 3, 4 };
    const out = try writePam(allocator, 1, 1, &pixels);
    defer allocator.free(out);

    const expected_header = "P7\nWIDTH 1\nHEIGHT 1\nDEPTH 4\nMAXVAL 255\nTUPLTYPE RGB_ALPHA\nENDHDR\n";
    try std.testing.expect(out.len >= expected_header.len);
    try std.testing.expectEqualSlices(u8, expected_header, out[0..expected_header.len]);
    try std.testing.expectEqualSlices(u8, &pixels, out[expected_header.len..]);
}

// ── Comprehensive round-trip: write then read via auto-detect ───────────────

test "writeImage then readImage round-trip: RGB" {
    const allocator = std.testing.allocator;
    const width: u32 = 3;
    const height: u32 = 2;
    const pixels = [_]u8{
        255, 0,   0,
        0,   255, 0,
        0,   0,   255,
        128, 128, 128,
        64,  32,  16,
        200, 100, 50,
    };

    const out = try writeImage(allocator, width, height, 3, &pixels);
    defer allocator.free(out);

    var img = try readImage(allocator, out);
    defer img.deinit();

    try std.testing.expectEqual(width, img.width);
    try std.testing.expectEqual(height, img.height);
    try std.testing.expectEqual(@as(u8, 3), img.channels);
    try std.testing.expectEqualSlices(u8, &pixels, img.pixels);
}

test "writeImage then readImage round-trip: RGBA" {
    const allocator = std.testing.allocator;
    const width: u32 = 2;
    const height: u32 = 2;
    const pixels = [_]u8{
        255, 0,   0,   255,
        0,   255, 0,   128,
        0,   0,   255, 64,
        128, 128, 128, 0,
    };

    const out = try writeImage(allocator, width, height, 4, &pixels);
    defer allocator.free(out);

    var img = try readImage(allocator, out);
    defer img.deinit();

    try std.testing.expectEqual(width, img.width);
    try std.testing.expectEqual(height, img.height);
    try std.testing.expectEqual(@as(u8, 4), img.channels);
    try std.testing.expectEqualSlices(u8, &pixels, img.pixels);
}

// ── PAM: extra trailing data is tolerated ───────────────────────────────────

test "PAM: trailing data after pixels is tolerated" {
    const allocator = std.testing.allocator;
    // PAM reader requires at least enough data but allows trailing
    const data = "P7\nWIDTH 1\nHEIGHT 1\nDEPTH 4\nMAXVAL 255\nTUPLTYPE RGB_ALPHA\nENDHDR\n" ++ [_]u8{ 10, 20, 30, 40, 0xFF, 0xFF };

    var img = try readPam(allocator, data);
    defer img.deinit();

    try std.testing.expectEqual(@as(u32, 1), img.width);
    try std.testing.expectEqual(@as(u32, 1), img.height);
    try std.testing.expectEqualSlices(u8, &[_]u8{ 10, 20, 30, 40 }, img.pixels);
}
