const std = @import("std");

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
    channels: u8, // 3 for RGB, 4 for RGBA
    pixels: []u8, // raw pixel data, row-major, `width * height * channels` bytes
    allocator: std.mem.Allocator,

    pub fn deinit(self: *ImageData) void {
        self.allocator.free(self.pixels);
        self.* = undefined;
    }
};

// ── PPM P6 Reader ───────────────────────────────────────────────────────────

/// Read a PPM P6 (binary RGB) file from raw bytes.
pub fn readPpm(allocator: std.mem.Allocator, data: []const u8) ImageError!ImageData {
    return readPpmInternal(allocator, data);
}

fn readPpmInternal(allocator: std.mem.Allocator, data: []const u8) ImageError!ImageData {
    var pos: usize = 0;

    // Magic number
    if (data.len < 2 or data[0] != 'P' or data[1] != '6')
        return error.InvalidHeader;
    pos = 2;

    const width = parseNextInt(data, &pos) orelse return error.InvalidHeader;
    const height = parseNextInt(data, &pos) orelse return error.InvalidHeader;
    const maxval = parseNextInt(data, &pos) orelse return error.InvalidHeader;

    if (width == 0 or height == 0) return error.InvalidHeader;
    if (maxval != 255) return error.UnsupportedFormat;

    // After maxval there must be exactly one whitespace character before pixel data.
    if (pos >= data.len or !isWhitespace(data[pos]))
        return error.InvalidHeader;
    pos += 1;

    const pixel_count = @as(usize, width) * @as(usize, height);
    const expected_bytes = pixel_count * 3;

    if (data.len - pos < expected_bytes) return error.SizeMismatch;
    // Strict: there should be exactly the right amount of pixel data.
    if (data.len - pos != expected_bytes) return error.SizeMismatch;

    const pixels = allocator.alloc(u8, expected_bytes) catch return error.OutOfMemory;
    @memcpy(pixels, data[pos .. pos + expected_bytes]);

    return .{
        .width = width,
        .height = height,
        .channels = 3,
        .pixels = pixels,
        .allocator = allocator,
    };
}

// ── PAM P7 Reader ───────────────────────────────────────────────────────────

/// Read a PAM P7 (RGBA) file from raw bytes.
pub fn readPam(allocator: std.mem.Allocator, data: []const u8) ImageError!ImageData {
    return readPamInternal(allocator, data);
}

fn readPamInternal(allocator: std.mem.Allocator, data: []const u8) ImageError!ImageData {
    var pos: usize = 0;

    // Magic number "P7\n"
    if (data.len < 3 or data[0] != 'P' or data[1] != '7')
        return error.InvalidHeader;
    pos = 2;
    skipToNextLine(data, &pos);

    var width: ?u32 = null;
    var height: ?u32 = null;
    var depth: ?u32 = null;
    var maxval: ?u32 = null;
    var tupltype: ?[]const u8 = null;

    while (pos < data.len) {
        const line_start = pos;
        const line = readLine(data, &pos);

        // Skip comments
        if (line.len > 0 and line[0] == '#') continue;

        if (std.mem.eql(u8, line, "ENDHDR")) break;

        if (std.mem.startsWith(u8, line, "WIDTH ")) {
            width = parseU32(stripPrefix(line, "WIDTH ")) orelse return error.InvalidHeader;
        } else if (std.mem.startsWith(u8, line, "HEIGHT ")) {
            height = parseU32(stripPrefix(line, "HEIGHT ")) orelse return error.InvalidHeader;
        } else if (std.mem.startsWith(u8, line, "DEPTH ")) {
            depth = parseU32(stripPrefix(line, "DEPTH ")) orelse return error.InvalidHeader;
        } else if (std.mem.startsWith(u8, line, "MAXVAL ")) {
            maxval = parseU32(stripPrefix(line, "MAXVAL ")) orelse return error.InvalidHeader;
        } else if (std.mem.startsWith(u8, line, "TUPLTYPE ")) {
            tupltype = stripPrefix(line, "TUPLTYPE ");
        } else {
            // Unknown header line; skip if empty otherwise it may be fine.
            _ = line_start;
        }
    }

    const w = width orelse return error.InvalidHeader;
    const h = height orelse return error.InvalidHeader;
    const d = depth orelse return error.InvalidHeader;
    const mv = maxval orelse return error.InvalidHeader;

    if (w == 0 or h == 0) return error.InvalidHeader;
    if (d != 4) return error.UnsupportedFormat;
    if (mv != 255) return error.UnsupportedFormat;

    if (tupltype) |tt| {
        if (!std.mem.eql(u8, tt, "RGB_ALPHA")) return error.UnsupportedFormat;
    }

    const pixel_count = @as(usize, w) * @as(usize, h);
    const expected_bytes = pixel_count * 4;

    if (data.len - pos < expected_bytes) return error.SizeMismatch;
    // Allow trailing data (some writers may add newlines), but require at least enough.
    // Actually, be strict like PPM.
    // PAM files sometimes have no trailing data — let's just require at least enough.
    const available = data.len - pos;
    if (available < expected_bytes) return error.SizeMismatch;

    const pixels = allocator.alloc(u8, expected_bytes) catch return error.OutOfMemory;
    @memcpy(pixels, data[pos .. pos + expected_bytes]);

    return .{
        .width = w,
        .height = h,
        .channels = 4,
        .pixels = pixels,
        .allocator = allocator,
    };
}

// ── PPM P6 Writer ───────────────────────────────────────────────────────────

/// Write raw RGB pixel data as a PPM P6 file.
pub fn writePpm(allocator: std.mem.Allocator, width: u32, height: u32, pixels: []const u8) ImageError![]u8 {
    const pixel_count = @as(usize, width) * @as(usize, height);
    const expected = pixel_count * 3;
    if (pixels.len != expected) return error.SizeMismatch;

    var header_buf: [128]u8 = undefined;
    const header = std.fmt.bufPrint(&header_buf, "P6\n{} {}\n255\n", .{ width, height }) catch return error.IoError;

    const total = header.len + expected;
    const out = allocator.alloc(u8, total) catch return error.OutOfMemory;
    @memcpy(out[0..header.len], header);
    @memcpy(out[header.len..], pixels);
    return out;
}

// ── PAM P7 Writer ───────────────────────────────────────────────────────────

/// Write raw RGBA pixel data as a PAM P7 file.
pub fn writePam(allocator: std.mem.Allocator, width: u32, height: u32, pixels: []const u8) ImageError![]u8 {
    const pixel_count = @as(usize, width) * @as(usize, height);
    const expected = pixel_count * 4;
    if (pixels.len != expected) return error.SizeMismatch;

    var header_buf: [256]u8 = undefined;
    const header = std.fmt.bufPrint(&header_buf, "P7\nWIDTH {}\nHEIGHT {}\nDEPTH 4\nMAXVAL 255\nTUPLTYPE RGB_ALPHA\nENDHDR\n", .{ width, height }) catch return error.IoError;

    const total = header.len + expected;
    const out = allocator.alloc(u8, total) catch return error.OutOfMemory;
    @memcpy(out[0..header.len], header);
    @memcpy(out[header.len..], pixels);
    return out;
}

// ── Auto-detect Reader ──────────────────────────────────────────────────────

/// Detect format from magic bytes and read accordingly.
pub fn readImage(allocator: std.mem.Allocator, data: []const u8) ImageError!ImageData {
    if (data.len >= 2 and data[0] == 'P') {
        if (data[1] == '6') return readPpm(allocator, data);
        if (data[1] == '7') return readPam(allocator, data);
    }
    return error.UnsupportedFormat;
}

/// Write image data to the appropriate format based on channel count.
/// channels=3 -> PPM P6, channels=4 -> PAM P7.
pub fn writeImage(allocator: std.mem.Allocator, width: u32, height: u32, channels: u8, pixels: []const u8) ImageError![]u8 {
    return switch (channels) {
        3 => writePpm(allocator, width, height, pixels),
        4 => writePam(allocator, width, height, pixels),
        else => error.UnsupportedFormat,
    };
}

// ── Utility Functions ───────────────────────────────────────────────────────

fn isWhitespace(c: u8) bool {
    return c == ' ' or c == '\t' or c == '\n' or c == '\r';
}

fn skipWhitespaceAndComments(data: []const u8, pos: *usize) void {
    while (pos.* < data.len) {
        if (isWhitespace(data[pos.*])) {
            pos.* += 1;
        } else if (data[pos.*] == '#') {
            // Skip comment until end of line
            while (pos.* < data.len and data[pos.*] != '\n') {
                pos.* += 1;
            }
        } else {
            break;
        }
    }
}

fn parseNextInt(data: []const u8, pos: *usize) ?u32 {
    skipWhitespaceAndComments(data, pos);
    if (pos.* >= data.len) return null;

    var result: u32 = 0;
    var found_digit = false;
    while (pos.* < data.len and data[pos.*] >= '0' and data[pos.*] <= '9') {
        result = result *% 10 +% (data[pos.*] - '0');
        found_digit = true;
        pos.* += 1;
    }
    if (!found_digit) return null;
    return result;
}

fn skipToNextLine(data: []const u8, pos: *usize) void {
    while (pos.* < data.len and data[pos.*] != '\n') {
        pos.* += 1;
    }
    if (pos.* < data.len) pos.* += 1; // skip the '\n'
}

fn readLine(data: []const u8, pos: *usize) []const u8 {
    const start = pos.*;
    while (pos.* < data.len and data[pos.*] != '\n') {
        pos.* += 1;
    }
    var end = pos.*;
    // Strip trailing \r
    if (end > start and data[end - 1] == '\r') end -= 1;
    if (pos.* < data.len) pos.* += 1; // skip '\n'
    return data[start..end];
}

fn stripPrefix(s: []const u8, prefix: []const u8) []const u8 {
    if (s.len >= prefix.len and std.mem.eql(u8, s[0..prefix.len], prefix)) {
        return s[prefix.len..];
    }
    return s;
}

fn parseU32(s: []const u8) ?u32 {
    // Trim trailing whitespace
    var end: usize = s.len;
    while (end > 0 and isWhitespace(s[end - 1])) end -= 1;
    const trimmed = s[0..end];
    if (trimmed.len == 0) return null;
    var result: u32 = 0;
    for (trimmed) |c| {
        if (c < '0' or c > '9') return null;
        result = result *% 10 +% (c - '0');
    }
    return result;
}

// ── Tests ───────────────────────────────────────────────────────────────────

test "roundtrip PPM P6" {
    const allocator = std.testing.allocator;
    const width: u32 = 2;
    const height: u32 = 2;
    const pixels = [_]u8{
        255, 0,   0, // red
        0,   255, 0, // green
        0,   0,   255, // blue
        128, 128, 128, // gray
    };

    const ppm_data = try writePpm(allocator, width, height, &pixels);
    defer allocator.free(ppm_data);

    var img = try readPpm(allocator, ppm_data);
    defer img.deinit();

    try std.testing.expectEqual(width, img.width);
    try std.testing.expectEqual(height, img.height);
    try std.testing.expectEqual(@as(u8, 3), img.channels);
    try std.testing.expectEqualSlices(u8, &pixels, img.pixels);
}

test "roundtrip PAM P7" {
    const allocator = std.testing.allocator;
    const width: u32 = 2;
    const height: u32 = 1;
    const pixels = [_]u8{
        255, 0,   0,   255, // red opaque
        0,   255, 0,   128, // green half-transparent
    };

    const pam_data = try writePam(allocator, width, height, &pixels);
    defer allocator.free(pam_data);

    var img = try readPam(allocator, pam_data);
    defer img.deinit();

    try std.testing.expectEqual(width, img.width);
    try std.testing.expectEqual(height, img.height);
    try std.testing.expectEqual(@as(u8, 4), img.channels);
    try std.testing.expectEqualSlices(u8, &pixels, img.pixels);
}

test "PPM invalid magic" {
    const allocator = std.testing.allocator;
    const result = readPpm(allocator, "P5\n2 2\n255\n" ++ "\x00" ** 12);
    try std.testing.expectError(error.InvalidHeader, result);
}

test "PPM size mismatch - too little data" {
    const allocator = std.testing.allocator;
    const result = readPpm(allocator, "P6\n2 2\n255\n" ++ "\x00" ** 11);
    try std.testing.expectError(error.SizeMismatch, result);
}

test "PPM with comments" {
    const allocator = std.testing.allocator;
    const header = "P6\n# comment\n1 1\n255\n";
    const pixels = [_]u8{ 42, 43, 44 };
    const data = header ++ pixels;

    var img = try readPpm(allocator, data);
    defer img.deinit();

    try std.testing.expectEqual(@as(u32, 1), img.width);
    try std.testing.expectEqual(@as(u32, 1), img.height);
    try std.testing.expectEqualSlices(u8, &pixels, img.pixels);
}

test "PAM invalid depth" {
    const allocator = std.testing.allocator;
    const data = "P7\nWIDTH 1\nHEIGHT 1\nDEPTH 3\nMAXVAL 255\nTUPLTYPE RGB\nENDHDR\n" ++ "\x00" ** 3;
    const result = readPam(allocator, data);
    try std.testing.expectError(error.UnsupportedFormat, result);
}

test "auto-detect readImage PPM" {
    const allocator = std.testing.allocator;
    const pixels = [_]u8{ 10, 20, 30 };
    const data = "P6\n1 1\n255\n" ++ pixels;

    var img = try readImage(allocator, data);
    defer img.deinit();

    try std.testing.expectEqual(@as(u8, 3), img.channels);
}

test "auto-detect readImage PAM" {
    const allocator = std.testing.allocator;
    const pixels = [_]u8{ 10, 20, 30, 40 };
    const data = "P7\nWIDTH 1\nHEIGHT 1\nDEPTH 4\nMAXVAL 255\nTUPLTYPE RGB_ALPHA\nENDHDR\n" ++ pixels;

    var img = try readImage(allocator, data);
    defer img.deinit();

    try std.testing.expectEqual(@as(u8, 4), img.channels);
}

test "writeImage dispatches by channel count" {
    const allocator = std.testing.allocator;
    const pixels3 = [_]u8{ 1, 2, 3 };
    const out3 = try writeImage(allocator, 1, 1, 3, &pixels3);
    defer allocator.free(out3);
    try std.testing.expect(out3[0] == 'P' and out3[1] == '6');

    const pixels4 = [_]u8{ 1, 2, 3, 4 };
    const out4 = try writeImage(allocator, 1, 1, 4, &pixels4);
    defer allocator.free(out4);
    try std.testing.expect(out4[0] == 'P' and out4[1] == '7');

    const result = writeImage(allocator, 1, 1, 2, &[_]u8{ 1, 2 });
    try std.testing.expectError(error.UnsupportedFormat, result);
}
