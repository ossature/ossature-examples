const std = @import("std");
const types = @import("types.zig");

comptime {
    _ = @import("stubs.zig");
}
const Pixel = types.Pixel;

pub const Image = struct {
    width: u32,
    height: u32,
    channels: u8,
    pixels: []Pixel,

    pub fn deinit(self: Image, allocator: std.mem.Allocator) void {
        allocator.free(self.pixels);
    }
};

pub const ReadError = error{
    InvalidMagic,
    InvalidHeader,
    UnsupportedFormat,
    UnsupportedDepth,
    UnsupportedMaxval,
    UnexpectedEndOfStream,
    InvalidDimensions,
    OutOfMemory,
};

pub fn PeekableReader(comptime ReaderType: type) type {
    return struct {
        inner: ReaderType,
        peeked: ?u8 = null,

        const Self = @This();

        pub fn readByte(self: *Self) !u8 {
            if (self.peeked) |b| {
                self.peeked = null;
                return b;
            }
            return self.inner.readByte();
        }

        pub fn peekByte(self: *Self) !?u8 {
            if (self.peeked == null) {
                self.peeked = self.inner.readByte() catch |err| {
                    if (err == error.EndOfStream) return null;
                    return err;
                };
            }
            return self.peeked;
        }

        pub fn readNoEof(self: *Self, buf: []u8) !void {
            var i: usize = 0;
            while (i < buf.len) : (i += 1) {
                buf[i] = try self.readByte();
            }
        }
    };
}

pub fn peekableReader(reader: anytype) PeekableReader(@TypeOf(reader)) {
    return .{ .inner = reader };
}

fn skipWhitespacesAndComments(reader: anytype) !?u8 {
    while (true) {
        const b = (try reader.peekByte()) orelse return null;

        if (std.ascii.isWhitespace(b)) {
            _ = try reader.readByte(); // consume it
        } else if (b == '#') {
            _ = try reader.readByte(); // consume '#'
            // skip until newline
            while (true) {
                const cb = try reader.readByte();
                if (cb == '\n' or cb == '\r') {
                    break;
                }
            }
        } else {
            return try reader.readByte();
        }
    }
}

fn readToken(reader: anytype, buffer: []u8) !?[]const u8 {
    const first_byte = (try skipWhitespacesAndComments(reader)) orelse return null;
    buffer[0] = first_byte;
    var len: usize = 1;
    while (len < buffer.len) {
        const next_b = (try reader.peekByte()) orelse break;
        if (std.ascii.isWhitespace(next_b) or next_b == '#') {
            break;
        }
        _ = try reader.readByte(); // consume
        buffer[len] = next_b;
        len += 1;
    }
    return buffer[0..len];
}

fn parseU32(token: []const u8) !u32 {
    return std.fmt.parseInt(u32, token, 10) catch {
        return error.InvalidHeader;
    };
}

fn readPpmHeader(reader: anytype) !struct { width: u32, height: u32, maxval: u32 } {
    var token_buf: [256]u8 = undefined;

    // Read width
    const width_tok = (try readToken(reader, &token_buf)) orelse return error.InvalidHeader;
    const width = try parseU32(width_tok);

    // Read height
    const height_tok = (try readToken(reader, &token_buf)) orelse return error.InvalidHeader;
    const height = try parseU32(height_tok);

    // Read maxval
    const maxval_tok = (try readToken(reader, &token_buf)) orelse return error.InvalidHeader;
    const maxval = try parseU32(maxval_tok);

    if (width == 0 or height == 0) return error.InvalidDimensions;

    // Consume the single separator whitespace
    const last_ws = reader.readByte() catch |err| {
        if (err == error.EndOfStream) return error.UnexpectedEndOfStream;
        return err;
    };
    if (!std.ascii.isWhitespace(last_ws)) return error.InvalidHeader;
    if (last_ws == '\r') {
        if (try reader.peekByte()) |next_b| {
            if (next_b == '\n') {
                _ = try reader.readByte(); // consume '\n'
            }
        }
    }

    return .{ .width = width, .height = height, .maxval = maxval };
}

pub fn read(allocator: std.mem.Allocator, raw_reader: anytype) !Image {
    var pr = peekableReader(raw_reader);
    var token_buf: [256]u8 = undefined;

    // Read magic format
    const magic = (try readToken(&pr, &token_buf)) orelse return error.InvalidMagic;

    var width: u32 = 0;
    var height: u32 = 0;
    var channels: u8 = 3;

    if (std.mem.eql(u8, magic, "P6")) {
        // PPM file
        const header = try readPpmHeader(&pr);
        if (header.maxval != 255) return error.UnsupportedMaxval;
        width = header.width;
        height = header.height;
        channels = 3;
    } else if (std.mem.eql(u8, magic, "P7")) {
        // PAM file
        var w_val: ?u32 = null;
        var h_val: ?u32 = null;
        var d_val: ?u32 = null;
        var m_val: ?u32 = null;
        var tupltype: [64]u8 = undefined;
        var tupltype_len: usize = 0;

        while (true) {
            const token = (try readToken(&pr, &token_buf)) orelse return error.InvalidHeader;
            if (std.mem.eql(u8, token, "ENDHDR")) {
                break;
            } else if (std.mem.eql(u8, token, "WIDTH")) {
                const val_tok = (try readToken(&pr, &token_buf)) orelse return error.InvalidHeader;
                w_val = try parseU32(val_tok);
            } else if (std.mem.eql(u8, token, "HEIGHT")) {
                const val_tok = (try readToken(&pr, &token_buf)) orelse return error.InvalidHeader;
                h_val = try parseU32(val_tok);
            } else if (std.mem.eql(u8, token, "DEPTH")) {
                const val_tok = (try readToken(&pr, &token_buf)) orelse return error.InvalidHeader;
                d_val = try parseU32(val_tok);
            } else if (std.mem.eql(u8, token, "MAXVAL")) {
                const val_tok = (try readToken(&pr, &token_buf)) orelse return error.InvalidHeader;
                m_val = try parseU32(val_tok);
            } else if (std.mem.eql(u8, token, "TUPLTYPE")) {
                const val_tok = (try readToken(&pr, &token_buf)) orelse return error.InvalidHeader;
                if (val_tok.len > tupltype.len) return error.InvalidHeader;
                @memcpy(tupltype[0..val_tok.len], val_tok);
                tupltype_len = val_tok.len;
            } else {
                // Unknown keyword: skip next token as value
                _ = (try readToken(&pr, &token_buf)) orelse return error.InvalidHeader;
            }
        }

        // Consume exactly one whitespace separating ENDHDR from pixel data
        const last_ws = pr.readByte() catch |err| {
            if (err == error.EndOfStream) return error.UnexpectedEndOfStream;
            return err;
        };
        if (!std.ascii.isWhitespace(last_ws)) return error.InvalidHeader;
        if (last_ws == '\r') {
            if (try pr.peekByte()) |next_b| {
                if (next_b == '\n') {
                    _ = try pr.readByte(); // consume '\n'
                }
            }
        }

        const final_width = w_val orelse return error.InvalidHeader;
        const final_height = h_val orelse return error.InvalidHeader;
        const final_depth = d_val orelse return error.InvalidHeader;
        const final_maxval = m_val orelse return error.InvalidHeader;

        if (final_width == 0 or final_height == 0) return error.InvalidDimensions;
        if (final_depth != 3 and final_depth != 4) return error.UnsupportedDepth;
        if (final_maxval != 255) return error.UnsupportedMaxval;

        // Verify that depth and tupltype aren't warning-mismatched if needed,
        // but strictly stick to DEPTH to determine pixel elements as required.
        width = final_width;
        height = final_height;
        channels = @intCast(final_depth);
    } else {
        return error.UnsupportedFormat;
    }

    // Now, read the pixels
    const num_pixels = @as(usize, width) * height;
    const pixels = try allocator.alloc(Pixel, num_pixels);
    errdefer allocator.free(pixels);

    var i: usize = 0;
    if (channels == 3) {
        var rgb: [3]u8 = undefined;
        while (i < num_pixels) : (i += 1) {
            pr.readNoEof(&rgb) catch |err| {
                if (err == error.EndOfStream) return error.UnexpectedEndOfStream;
                return err;
            };
            pixels[i] = Pixel{
                .r = rgb[0],
                .g = rgb[1],
                .b = rgb[2],
                .a = 255,
            };
        }
    } else if (channels == 4) {
        var rgba: [4]u8 = undefined;
        while (i < num_pixels) : (i += 1) {
            pr.readNoEof(&rgba) catch |err| {
                if (err == error.EndOfStream) return error.UnexpectedEndOfStream;
                return err;
            };
            pixels[i] = Pixel{
                .r = rgba[0],
                .g = rgba[1],
                .b = rgba[2],
                .a = rgba[3],
            };
        }
    }

    // Tolerating trailing spaces/newlines at the end of the file/stream
    while (true) {
        const maybe_b = pr.peekByte() catch null;
        if (maybe_b) |b| {
            if (std.ascii.isWhitespace(b)) {
                _ = pr.readByte() catch break;
            } else {
                break;
            }
        } else {
            break;
        }
    }

    return Image{
        .width = width,
        .height = height,
        .channels = channels,
        .pixels = pixels,
    };
}

pub fn writePpm(writer: anytype, width: u32, height: u32, pixels: []const Pixel) !void {
    if (pixels.len != @as(usize, width) * height) {
        return error.InvalidDimensions;
    }
    try writer.print("P6\n{d} {d}\n255\n", .{ width, height });

    var buf: [3072]u8 = undefined;
    var buf_idx: usize = 0;
    for (pixels) |px| {
        if (buf_idx + 3 > buf.len) {
            try writer.writeAll(buf[0..buf_idx]);
            buf_idx = 0;
        }
        buf[buf_idx] = px.r;
        buf[buf_idx + 1] = px.g;
        buf[buf_idx + 2] = px.b;
        buf_idx += 3;
    }
    if (buf_idx > 0) {
        try writer.writeAll(buf[0..buf_idx]);
    }
}

pub fn writePam(writer: anytype, width: u32, height: u32, channels: u8, pixels: []const Pixel) !void {
    if (pixels.len != @as(usize, width) * height) {
        return error.InvalidDimensions;
    }
    if (channels != 3 and channels != 4) {
        return error.UnsupportedDepth;
    }

    try writer.print("P7\n", .{});
    try writer.print("WIDTH {d}\n", .{width});
    try writer.print("HEIGHT {d}\n", .{height});
    try writer.print("DEPTH {d}\n", .{channels});
    try writer.print("MAXVAL 255\n", .{});
    if (channels == 3) {
        try writer.print("TUPLTYPE RGB\n", .{});
    } else {
        try writer.print("TUPLTYPE RGB_ALPHA\n", .{});
    }
    try writer.print("ENDHDR\n", .{});

    var buf: [4096]u8 = undefined;
    var buf_idx: usize = 0;
    if (channels == 3) {
        for (pixels) |px| {
            if (buf_idx + 3 > buf.len) {
                try writer.writeAll(buf[0..buf_idx]);
                buf_idx = 0;
            }
            buf[buf_idx] = px.r;
            buf[buf_idx + 1] = px.g;
            buf[buf_idx + 2] = px.b;
            buf_idx += 3;
        }
    } else {
        for (pixels) |px| {
            if (buf_idx + 4 > buf.len) {
                try writer.writeAll(buf[0..buf_idx]);
                buf_idx = 0;
            }
            buf[buf_idx] = px.r;
            buf[buf_idx + 1] = px.g;
            buf[buf_idx + 2] = px.b;
            buf[buf_idx + 3] = px.a;
            buf_idx += 4;
        }
    }
    if (buf_idx > 0) {
        try writer.writeAll(buf[0..buf_idx]);
    }
}

test "Netpbm PPM Read and Write" {
    const allocator = std.testing.allocator;

    const pixels = try allocator.alloc(Pixel, 4);
    defer allocator.free(pixels);
    pixels[0] = Pixel{ .r = 255, .g = 0, .b = 0, .a = 255 };
    pixels[1] = Pixel{ .r = 0, .g = 255, .b = 0, .a = 255 };
    pixels[2] = Pixel{ .r = 0, .g = 0, .b = 255, .a = 255 };
    pixels[3] = Pixel{ .r = 255, .g = 255, .b = 255, .a = 255 };

    var buf = std.ArrayList(u8).empty;
    defer buf.deinit(allocator);

    try writePpm(buf.writer(allocator), 2, 2, pixels);

    var fbs = std.io.fixedBufferStream(buf.items);
    const img = try read(allocator, fbs.reader());
    defer img.deinit(allocator);

    try std.testing.expectEqual(@as(u32, 2), img.width);
    try std.testing.expectEqual(@as(u32, 2), img.height);
    try std.testing.expectEqual(@as(u8, 3), img.channels);
    try std.testing.expectEqual(pixels[0].r, img.pixels[0].r);
    try std.testing.expectEqual(pixels[0].g, img.pixels[0].g);
    try std.testing.expectEqual(pixels[0].b, img.pixels[0].b);
}

test "Netpbm PAM Read and Write" {
    const allocator = std.testing.allocator;

    const pixels = try allocator.alloc(Pixel, 4);
    defer allocator.free(pixels);
    pixels[0] = Pixel{ .r = 255, .g = 0, .b = 0, .a = 128 };
    pixels[1] = Pixel{ .r = 0, .g = 255, .b = 0, .a = 64 };
    pixels[2] = Pixel{ .r = 0, .g = 0, .b = 255, .a = 32 };
    pixels[3] = Pixel{ .r = 255, .g = 255, .b = 255, .a = 255 };

    var buf = std.ArrayList(u8).empty;
    defer buf.deinit(allocator);

    try writePam(buf.writer(allocator), 2, 2, 4, pixels);

    var fbs = std.io.fixedBufferStream(buf.items);
    const img = try read(allocator, fbs.reader());
    defer img.deinit(allocator);

    try std.testing.expectEqual(@as(u32, 2), img.width);
    try std.testing.expectEqual(@as(u32, 2), img.height);
    try std.testing.expectEqual(@as(u8, 4), img.channels);
    try std.testing.expectEqual(pixels[0].r, img.pixels[0].r);
    try std.testing.expectEqual(pixels[0].g, img.pixels[0].g);
    try std.testing.expectEqual(pixels[0].b, img.pixels[0].b);
    try std.testing.expectEqual(pixels[0].a, img.pixels[0].a);
}

test "Netpbm PPM with comments and lax whitespaces" {
    const allocator = std.testing.allocator;
    const test_ppm =
        \\P6
        \\# This is a comment
        \\# Another comment
        \\2 2
        \\# comment before maxval
        \\255
        \\
    ;
    // Let's build the complete PPM containing the pixels
    var full_ppm = std.ArrayList(u8).empty;
    defer full_ppm.deinit(allocator);
    try full_ppm.appendSlice(allocator, test_ppm);
    // pixel 0: red, pixel 1: green, pixel 2: blue, pixel 3: white
    const bin_data = [_]u8{
        255, 0,   0,
        0,   255, 0,
        0,   0,   255,
        255, 255, 255,
    };
    try full_ppm.appendSlice(allocator, &bin_data);
    // Add some trailing spaces and newlines
    try full_ppm.appendSlice(allocator, " \n  \r\n ");

    var fbs = std.io.fixedBufferStream(full_ppm.items);
    const img = try read(allocator, fbs.reader());
    defer img.deinit(allocator);

    try std.testing.expectEqual(@as(u32, 2), img.width);
    try std.testing.expectEqual(@as(u32, 2), img.height);
    try std.testing.expectEqual(@as(u8, 3), img.channels);
    try std.testing.expectEqual(@as(u8, 255), img.pixels[0].r);
    try std.testing.expectEqual(@as(u8, 255), img.pixels[1].g);
    try std.testing.expectEqual(@as(u8, 255), img.pixels[2].b);
}

test "Netpbm PAM invalid depth and invalid headers" {
    const allocator = std.testing.allocator;

    // Depth = 5 (Unsupported)
    const bad_pam_depth =
        \\P7
        \\WIDTH 2
        \\HEIGHT 2
        \\DEPTH 5
        \\MAXVAL 255
        \\TUPLTYPE RGB_ALPHA
        \\ENDHDR
        \\
    ;
    var fbs1 = std.io.fixedBufferStream(bad_pam_depth);
    try std.testing.expectError(error.UnsupportedDepth, read(allocator, fbs1.reader()));

    // Invalid maxval (UnsupportedMaxval)
    const bad_pam_maxval =
        \\P7
        \\WIDTH 2
        \\HEIGHT 2
        \\DEPTH 4
        \\MAXVAL 65535
        \\TUPLTYPE RGB_ALPHA
        \\ENDHDR
        \\
    ;
    var fbs2 = std.io.fixedBufferStream(bad_pam_maxval);
    try std.testing.expectError(error.UnsupportedMaxval, read(allocator, fbs2.reader()));

    // Missing HEIGHT
    const bad_pam_missing =
        \\P7
        \\WIDTH 2
        \\DEPTH 4
        \\MAXVAL 255
        \\ENDHDR
        \\
    ;
    var fbs3 = std.io.fixedBufferStream(bad_pam_missing);
    try std.testing.expectError(error.InvalidHeader, read(allocator, fbs3.reader()));

    // Invalid dimensions
    const bad_pam_dim =
        \\P7
        \\WIDTH 0
        \\HEIGHT 2
        \\DEPTH 4
        \\MAXVAL 255
        \\ENDHDR
        \\
    ;
    var fbs4 = std.io.fixedBufferStream(bad_pam_dim);
    try std.testing.expectError(error.InvalidDimensions, read(allocator, fbs4.reader()));

    // Invalid magic format
    const bad_magic =
        \\P9
        \\WIDTH 2
        \\HEIGHT 2
        \\DEPTH 4
        \\MAXVAL 255
        \\ENDHDR
        \\
    ;
    var fbs5 = std.io.fixedBufferStream(bad_magic);
    try std.testing.expectError(error.UnsupportedFormat, read(allocator, fbs5.reader()));
}
