const std = @import("std");
const qoi = @import("qoi.zig");
const encoder = @import("encoder.zig");
const decoder = @import("decoder.zig");
const image_io = @import("image_io.zig");

const Pixel = qoi.Pixel;

// ═══════════════════════════════════════════════════════════════════════════
// Helpers
// ═══════════════════════════════════════════════════════════════════════════

/// Create a PPM P6 byte buffer in memory for the given RGB pixel data.
fn makePpm(allocator: std.mem.Allocator, width: u32, height: u32, pixels: []const u8) ![]u8 {
    return image_io.writePpm(allocator, width, height, pixels);
}

/// Create a PAM P7 byte buffer in memory for the given RGBA pixel data.
fn makePam(allocator: std.mem.Allocator, width: u32, height: u32, pixels: []const u8) ![]u8 {
    return image_io.writePam(allocator, width, height, pixels);
}

/// Write bytes to a temp file and return the path. Caller owns the tmp_dir handle.
fn writeTempFile(tmp_dir: std.testing.TmpDir, sub_path: []const u8, data: []const u8) !void {
    const file = try tmp_dir.dir.createFile(sub_path, .{});
    defer file.close();
    try file.writeAll(data);
}

/// Read the full contents of a file from a tmp dir.
fn readTempFile(allocator: std.mem.Allocator, tmp_dir: std.testing.TmpDir, sub_path: []const u8) ![]u8 {
    const file = tmp_dir.dir.openFile(sub_path, .{}) catch return error.FileNotFound;
    defer file.close();
    return file.readToEndAlloc(allocator, std.math.maxInt(usize));
}

/// Run the qoizig CLI and return the result.
fn runCli(argv: []const []const u8) !std.process.Child.RunResult {
    return std.process.Child.run(.{
        .allocator = std.testing.allocator,
        .argv = argv,
    });
}

/// Build a full path from a TmpDir and sub-path.
fn tmpPath(buf: []u8, tmp_dir: std.testing.TmpDir, sub_path: []const u8) ![]const u8 {
    const dir_path = try tmp_dir.dir.realpath(".", buf);
    const total = dir_path.len + 1 + sub_path.len;
    if (total > buf.len) return error.NameTooLong;
    buf[dir_path.len] = '/';
    @memcpy(buf[dir_path.len + 1 ..][0..sub_path.len], sub_path);
    return buf[0..total];
}

// ═══════════════════════════════════════════════════════════════════════════
// Full pipeline: PPM → QOI → PPM round-trip (library API)
// ═══════════════════════════════════════════════════════════════════════════

test "full pipeline: PPM → encode → QOI → decode → PPM, verify pixel data (RGB)" {
    const alloc = std.testing.allocator;
    const width: u32 = 4;
    const height: u32 = 3;

    // Generate synthetic RGB pixel data
    var pixels: [width * height * 3]u8 = undefined;
    for (0..width * height) |i| {
        pixels[i * 3 + 0] = @truncate(i * 17);
        pixels[i * 3 + 1] = @truncate(i * 31);
        pixels[i * 3 + 2] = @truncate(i * 59);
    }

    // Step 1: Write pixels as PPM
    const ppm_data = try makePpm(alloc, width, height, &pixels);
    defer alloc.free(ppm_data);

    // Step 2: Read PPM back
    var img = try image_io.readPpm(alloc, ppm_data);
    defer img.deinit();

    try std.testing.expectEqual(width, img.width);
    try std.testing.expectEqual(height, img.height);
    try std.testing.expectEqual(@as(u8, 3), img.channels);

    // Step 3: Encode to QOI
    const qoi_data = try encoder.encode(alloc, img.pixels, img.width, img.height, .rgb, .srgb);
    defer alloc.free(qoi_data);

    // Verify QOI structure
    try std.testing.expectEqualSlices(u8, "qoif", qoi_data[0..4]);
    try std.testing.expectEqualSlices(u8, &qoi.QOI_END_MARKER, qoi_data[qoi_data.len - 8 ..]);

    // Step 4: Decode from QOI
    var decoded = try decoder.decode(alloc, qoi_data);
    defer decoded.deinit(alloc);

    try std.testing.expectEqual(width, decoded.header.width);
    try std.testing.expectEqual(height, decoded.header.height);

    // Step 5: Convert decoded pixels back to raw bytes and compare
    const num_channels: u8 = @intFromEnum(decoded.header.channels);
    const raw = try alloc.alloc(u8, decoded.pixels.len * num_channels);
    defer alloc.free(raw);

    for (decoded.pixels, 0..) |px, i| {
        raw[i * num_channels + 0] = px.r;
        raw[i * num_channels + 1] = px.g;
        raw[i * num_channels + 2] = px.b;
    }

    try std.testing.expectEqualSlices(u8, &pixels, raw);
}

test "full pipeline: PAM → encode → QOI → decode → PAM, verify pixel data (RGBA)" {
    const alloc = std.testing.allocator;
    const width: u32 = 3;
    const height: u32 = 2;

    // Generate synthetic RGBA pixel data
    var pixels: [width * height * 4]u8 = undefined;
    for (0..width * height) |i| {
        pixels[i * 4 + 0] = @truncate(i * 43);
        pixels[i * 4 + 1] = @truncate(i * 67);
        pixels[i * 4 + 2] = @truncate(i * 89);
        pixels[i * 4 + 3] = @truncate(200 + i * 10);
    }

    // Step 1: Write pixels as PAM
    const pam_data = try makePam(alloc, width, height, &pixels);
    defer alloc.free(pam_data);

    // Step 2: Read PAM back
    var img = try image_io.readPam(alloc, pam_data);
    defer img.deinit();

    try std.testing.expectEqual(@as(u8, 4), img.channels);

    // Step 3: Encode to QOI
    const qoi_data = try encoder.encode(alloc, img.pixels, img.width, img.height, .rgba, .srgb);
    defer alloc.free(qoi_data);

    // Step 4: Decode from QOI
    var decoded = try decoder.decode(alloc, qoi_data);
    defer decoded.deinit(alloc);

    // Step 5: Verify pixel data
    for (decoded.pixels, 0..) |px, i| {
        try std.testing.expectEqual(pixels[i * 4 + 0], px.r);
        try std.testing.expectEqual(pixels[i * 4 + 1], px.g);
        try std.testing.expectEqual(pixels[i * 4 + 2], px.b);
        try std.testing.expectEqual(pixels[i * 4 + 3], px.a);
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// Full pipeline with temp files (file I/O round-trip)
// ═══════════════════════════════════════════════════════════════════════════

test "file round-trip: write PPM → encode QOI → decode PPM → compare" {
    const alloc = std.testing.allocator;
    var tmp_dir = std.testing.tmpDir(.{});
    defer tmp_dir.cleanup();

    const width: u32 = 8;
    const height: u32 = 8;

    // Generate synthetic pixel data
    var pixels: [width * height * 3]u8 = undefined;
    for (0..width * height) |i| {
        pixels[i * 3 + 0] = @truncate(i * 7);
        pixels[i * 3 + 1] = @truncate(i * 13);
        pixels[i * 3 + 2] = @truncate(i * 23);
    }

    // Write PPM to temp file
    const ppm_data = try makePpm(alloc, width, height, &pixels);
    defer alloc.free(ppm_data);
    try writeTempFile(tmp_dir, "input.ppm", ppm_data);

    // Read it back and encode to QOI
    const ppm_read = try readTempFile(alloc, tmp_dir, "input.ppm");
    defer alloc.free(ppm_read);

    var img = try image_io.readImage(alloc, ppm_read);
    defer img.deinit();

    const qoi_data = try encoder.encode(alloc, img.pixels, img.width, img.height, .rgb, .srgb);
    defer alloc.free(qoi_data);

    // Write QOI to temp file
    try writeTempFile(tmp_dir, "output.qoi", qoi_data);

    // Read QOI back and decode
    const qoi_read = try readTempFile(alloc, tmp_dir, "output.qoi");
    defer alloc.free(qoi_read);

    var result = try decoder.decode(alloc, qoi_read);
    defer result.deinit(alloc);

    // Convert to PPM for comparison
    const num_ch: u8 = @intFromEnum(result.header.channels);
    const raw_pixels = try alloc.alloc(u8, result.pixels.len * num_ch);
    defer alloc.free(raw_pixels);

    for (result.pixels, 0..) |px, i| {
        raw_pixels[i * num_ch + 0] = px.r;
        raw_pixels[i * num_ch + 1] = px.g;
        raw_pixels[i * num_ch + 2] = px.b;
    }

    const ppm_out = try image_io.writePpm(alloc, result.header.width, result.header.height, raw_pixels);
    defer alloc.free(ppm_out);

    try writeTempFile(tmp_dir, "output.ppm", ppm_out);

    // Read output PPM and verify pixels
    const ppm_check = try readTempFile(alloc, tmp_dir, "output.ppm");
    defer alloc.free(ppm_check);

    var img2 = try image_io.readPpm(alloc, ppm_check);
    defer img2.deinit();

    try std.testing.expectEqual(width, img2.width);
    try std.testing.expectEqual(height, img2.height);
    try std.testing.expectEqualSlices(u8, &pixels, img2.pixels);
}

test "file round-trip: write PAM → encode QOI → decode PAM → compare" {
    const alloc = std.testing.allocator;
    var tmp_dir = std.testing.tmpDir(.{});
    defer tmp_dir.cleanup();

    const width: u32 = 5;
    const height: u32 = 3;

    var pixels: [width * height * 4]u8 = undefined;
    for (0..width * height) |i| {
        pixels[i * 4 + 0] = @truncate(i * 19);
        pixels[i * 4 + 1] = @truncate(i * 37);
        pixels[i * 4 + 2] = @truncate(i * 53);
        pixels[i * 4 + 3] = @truncate(255 -% @as(u8, @truncate(i * 5)));
    }

    // Write PAM
    const pam_data = try makePam(alloc, width, height, &pixels);
    defer alloc.free(pam_data);
    try writeTempFile(tmp_dir, "input.pam", pam_data);

    // Read and encode
    const pam_read = try readTempFile(alloc, tmp_dir, "input.pam");
    defer alloc.free(pam_read);

    var img = try image_io.readImage(alloc, pam_read);
    defer img.deinit();

    const qoi_data = try encoder.encode(alloc, img.pixels, img.width, img.height, .rgba, .srgb);
    defer alloc.free(qoi_data);
    try writeTempFile(tmp_dir, "output.qoi", qoi_data);

    // Read QOI and decode
    const qoi_read = try readTempFile(alloc, tmp_dir, "output.qoi");
    defer alloc.free(qoi_read);

    var result = try decoder.decode(alloc, qoi_read);
    defer result.deinit(alloc);

    // Convert to raw pixels and write PAM
    const raw_pixels = try alloc.alloc(u8, result.pixels.len * 4);
    defer alloc.free(raw_pixels);

    for (result.pixels, 0..) |px, i| {
        raw_pixels[i * 4 + 0] = px.r;
        raw_pixels[i * 4 + 1] = px.g;
        raw_pixels[i * 4 + 2] = px.b;
        raw_pixels[i * 4 + 3] = px.a;
    }

    const pam_out = try image_io.writePam(alloc, result.header.width, result.header.height, raw_pixels);
    defer alloc.free(pam_out);
    try writeTempFile(tmp_dir, "output.pam", pam_out);

    // Read output and compare
    const pam_check = try readTempFile(alloc, tmp_dir, "output.pam");
    defer alloc.free(pam_check);

    var img2 = try image_io.readPam(alloc, pam_check);
    defer img2.deinit();

    try std.testing.expectEqual(width, img2.width);
    try std.testing.expectEqual(height, img2.height);
    try std.testing.expectEqualSlices(u8, &pixels, img2.pixels);
}

// ═══════════════════════════════════════════════════════════════════════════
// Error paths: corrupt / invalid input
// ═══════════════════════════════════════════════════════════════════════════

test "error: corrupt PPM header" {
    const alloc = std.testing.allocator;
    // P6 magic but invalid header content
    const corrupt = "P6\nNOTVALID\n";
    const result = image_io.readImage(alloc, corrupt);
    try std.testing.expectError(error.InvalidHeader, result);
}

test "error: corrupt PAM header (missing ENDHDR)" {
    const alloc = std.testing.allocator;
    const corrupt = "P7\nWIDTH 1\nHEIGHT 1\nDEPTH 4\nMAXVAL 255\nTUPLTYPE RGB_ALPHA\n";
    const result = image_io.readImage(alloc, corrupt);
    // Missing ENDHDR and pixel data → SizeMismatch or InvalidHeader
    try std.testing.expect(std.meta.isError(result));
}

test "error: not a PPM/PAM file" {
    const alloc = std.testing.allocator;
    const garbage = "This is not an image file at all!";
    const result = image_io.readImage(alloc, garbage);
    try std.testing.expectError(error.UnsupportedFormat, result);
}

test "error: truncated QOI data" {
    const alloc = std.testing.allocator;

    // Create a valid 2x2 QOI but truncate it
    const pixels = [_]u8{ 100, 150, 200, 50, 100, 150, 200, 50, 100, 150, 200, 50 };
    const qoi_data = try encoder.encode(alloc, &pixels, 2, 2, .rgb, .srgb);
    defer alloc.free(qoi_data);

    // Truncate: remove end marker and some data
    const truncated_len = qoi.QOI_HEADER_SIZE + 2; // header + partial data
    const result = decoder.decode(alloc, qoi_data[0..truncated_len]);
    try std.testing.expectError(decoder.DecodeError.UnexpectedEndOfData, result);
}

test "error: QOI with corrupted magic bytes" {
    const alloc = std.testing.allocator;

    const pixels = [_]u8{ 0, 0, 0 };
    const qoi_data = try encoder.encode(alloc, &pixels, 1, 1, .rgb, .srgb);
    defer alloc.free(qoi_data);

    // Corrupt magic
    var corrupted = try alloc.alloc(u8, qoi_data.len);
    defer alloc.free(corrupted);
    @memcpy(corrupted, qoi_data);
    corrupted[0] = 'X';
    corrupted[1] = 'Y';
    corrupted[2] = 'Z';

    const result = decoder.decode(alloc, corrupted);
    try std.testing.expectError(decoder.DecodeError.InvalidMagic, result);
}

test "error: QOI with corrupted end marker" {
    const alloc = std.testing.allocator;

    const pixels = [_]u8{ 0, 0, 0 };
    const qoi_data = try encoder.encode(alloc, &pixels, 1, 1, .rgb, .srgb);
    defer alloc.free(qoi_data);

    // Corrupt end marker
    var corrupted = try alloc.alloc(u8, qoi_data.len);
    defer alloc.free(corrupted);
    @memcpy(corrupted, qoi_data);
    corrupted[corrupted.len - 1] = 0x00; // should be 0x01

    const result = decoder.decode(alloc, corrupted);
    try std.testing.expectError(decoder.DecodeError.InvalidEndMarker, result);
}

test "error: encode with wrong pixel data length" {
    const alloc = std.testing.allocator;
    const pixels = [_]u8{ 0, 0 }; // too short for 1x1 RGB
    try std.testing.expectError(error.InvalidPixelDataLength, encoder.encode(alloc, &pixels, 1, 1, .rgb, .srgb));
}

test "error: PPM with size mismatch" {
    const alloc = std.testing.allocator;
    // Header says 2x2 (12 bytes of pixel data) but we only provide 6
    const data = "P6\n2 2\n255\n" ++ "\x00\x00\x00\x00\x00\x00";
    const result = image_io.readPpm(alloc, data);
    try std.testing.expectError(error.SizeMismatch, result);
}

test "error: decode empty data" {
    const alloc = std.testing.allocator;
    const result = decoder.decode(alloc, &[_]u8{});
    try std.testing.expectError(decoder.DecodeError.UnexpectedEndOfData, result);
}

test "error: decode just magic bytes, nothing else" {
    const alloc = std.testing.allocator;
    const result = decoder.decode(alloc, "qoif");
    try std.testing.expectError(decoder.DecodeError.UnexpectedEndOfData, result);
}

test "error: QOI with invalid channels in header" {
    const alloc = std.testing.allocator;
    var buf: [qoi.QOI_HEADER_SIZE + 1 + qoi.QOI_END_MARKER.len]u8 = undefined;
    const hdr = qoi.QoiHeader{ .width = 1, .height = 1, .channels = .rgb, .colorspace = .srgb };
    @memcpy(buf[0..qoi.QOI_HEADER_SIZE], &hdr.encode());
    buf[12] = 5; // invalid channels
    buf[qoi.QOI_HEADER_SIZE] = qoi.QOI_OP_RUN | 0;
    @memcpy(buf[qoi.QOI_HEADER_SIZE + 1 ..][0..8], &qoi.QOI_END_MARKER);
    try std.testing.expectError(decoder.DecodeError.InvalidChannels, decoder.decode(alloc, &buf));
}

test "error: QOI with invalid colorspace in header" {
    const alloc = std.testing.allocator;
    var buf: [qoi.QOI_HEADER_SIZE + 1 + qoi.QOI_END_MARKER.len]u8 = undefined;
    const hdr = qoi.QoiHeader{ .width = 1, .height = 1, .channels = .rgb, .colorspace = .srgb };
    @memcpy(buf[0..qoi.QOI_HEADER_SIZE], &hdr.encode());
    buf[13] = 99; // invalid colorspace
    buf[qoi.QOI_HEADER_SIZE] = qoi.QOI_OP_RUN | 0;
    @memcpy(buf[qoi.QOI_HEADER_SIZE + 1 ..][0..8], &qoi.QOI_END_MARKER);
    try std.testing.expectError(decoder.DecodeError.InvalidColorspace, decoder.decode(alloc, &buf));
}

test "error: QOI with zero dimensions" {
    const alloc = std.testing.allocator;
    var buf: [qoi.QOI_HEADER_SIZE + 1 + qoi.QOI_END_MARKER.len]u8 = undefined;
    @memcpy(buf[0..4], &qoi.QOI_MAGIC);
    std.mem.writeInt(u32, buf[4..8], 0, .big);
    std.mem.writeInt(u32, buf[8..12], 1, .big);
    buf[12] = 3;
    buf[13] = 0;
    buf[qoi.QOI_HEADER_SIZE] = qoi.QOI_OP_RUN | 0;
    @memcpy(buf[qoi.QOI_HEADER_SIZE + 1 ..][0..8], &qoi.QOI_END_MARKER);
    try std.testing.expectError(decoder.DecodeError.InvalidDimensions, decoder.decode(alloc, &buf));
}

// ═══════════════════════════════════════════════════════════════════════════
// CLI invocation tests (via child process)
// ═══════════════════════════════════════════════════════════════════════════

fn getExePath(buf: []u8) ![]const u8 {
    // The test binary is built by the build system.
    // The CLI binary should be at zig-out/bin/qoizig relative to the project root.
    // We can find it relative to our own binary's location.
    // Use a known relative path from the test runner.
    const self_exe = try std.fs.selfExePath(buf);
    // The self exe is typically in .zig-cache/... We need zig-out/bin/qoizig
    // Let's try to find it by going up from the current working directory.
    const cwd = std.fs.cwd();
    if (cwd.openFile("zig-out/bin/qoizig", .{})) |file| {
        file.close();
        const real = try cwd.realpath("zig-out/bin/qoizig", buf);
        return real;
    } else |_| {
        // Might not be installed yet, skip these tests gracefully
        _ = self_exe;
        return error.SkipZigTest;
    }
}

test "CLI: encode PPM to QOI succeeds" {
    const alloc = std.testing.allocator;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    const width: u32 = 2;
    const height: u32 = 2;
    const pixels = [_]u8{
        255, 0,   0,
        0,   255, 0,
        0,   0,   255,
        128, 128, 128,
    };

    const ppm_data = try makePpm(alloc, width, height, &pixels);
    defer alloc.free(ppm_data);
    try writeTempFile(tmp, "test.ppm", ppm_data);

    var path_buf1: [std.fs.max_path_bytes]u8 = undefined;
    var path_buf2: [std.fs.max_path_bytes]u8 = undefined;
    var exe_buf: [std.fs.max_path_bytes]u8 = undefined;

    const exe_path = getExePath(&exe_buf) catch |err| {
        if (err == error.SkipZigTest) return err;
        return err;
    };

    const input_path = try tmpPath(&path_buf1, tmp, "test.ppm");
    const output_path = try tmpPath(&path_buf2, tmp, "test.qoi");

    const result = try runCli(&.{ exe_path, "encode", input_path, output_path });
    defer alloc.free(result.stdout);
    defer alloc.free(result.stderr);

    try std.testing.expectEqual(@as(u8, 0), result.term.Exited);

    // Verify the QOI file was created and is valid
    const qoi_data = try readTempFile(alloc, tmp, "test.qoi");
    defer alloc.free(qoi_data);

    try std.testing.expectEqualSlices(u8, "qoif", qoi_data[0..4]);
    try std.testing.expectEqualSlices(u8, &qoi.QOI_END_MARKER, qoi_data[qoi_data.len - 8 ..]);

    // Verify stdout contains expected message
    try std.testing.expect(std.mem.indexOf(u8, result.stdout, "Encoded 2x2 image to") != null);
}

test "CLI: decode QOI to PAM succeeds" {
    const alloc = std.testing.allocator;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    // First create a QOI file
    const width: u32 = 3;
    const height: u32 = 2;
    var pixels: [width * height * 4]u8 = undefined;
    for (0..width * height) |i| {
        pixels[i * 4 + 0] = @truncate(i * 40);
        pixels[i * 4 + 1] = @truncate(i * 60);
        pixels[i * 4 + 2] = @truncate(i * 80);
        pixels[i * 4 + 3] = 255;
    }
    const qoi_data = try encoder.encode(alloc, &pixels, width, height, .rgba, .srgb);
    defer alloc.free(qoi_data);
    try writeTempFile(tmp, "test.qoi", qoi_data);

    var path_buf1: [std.fs.max_path_bytes]u8 = undefined;
    var path_buf2: [std.fs.max_path_bytes]u8 = undefined;
    var exe_buf: [std.fs.max_path_bytes]u8 = undefined;

    const exe_path = getExePath(&exe_buf) catch |err| {
        if (err == error.SkipZigTest) return err;
        return err;
    };

    const input_path = try tmpPath(&path_buf1, tmp, "test.qoi");
    const output_path = try tmpPath(&path_buf2, tmp, "test.pam");

    const result = try runCli(&.{ exe_path, "decode", input_path, output_path });
    defer alloc.free(result.stdout);
    defer alloc.free(result.stderr);

    try std.testing.expectEqual(@as(u8, 0), result.term.Exited);

    // Verify the PAM file was created and pixel data matches
    const pam_data = try readTempFile(alloc, tmp, "test.pam");
    defer alloc.free(pam_data);

    var img = try image_io.readPam(alloc, pam_data);
    defer img.deinit();

    try std.testing.expectEqual(width, img.width);
    try std.testing.expectEqual(height, img.height);
    try std.testing.expectEqualSlices(u8, &pixels, img.pixels);

    // Verify stdout
    try std.testing.expect(std.mem.indexOf(u8, result.stdout, "Decoded 3x2 image to") != null);
}

test "CLI: full round-trip PPM → QOI → PPM" {
    const alloc = std.testing.allocator;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var exe_buf: [std.fs.max_path_bytes]u8 = undefined;
    const exe_path = getExePath(&exe_buf) catch |err| {
        if (err == error.SkipZigTest) return err;
        return err;
    };

    const width: u32 = 10;
    const height: u32 = 10;
    var pixels: [width * height * 3]u8 = undefined;
    for (0..width * height) |i| {
        pixels[i * 3 + 0] = @truncate(i * 3);
        pixels[i * 3 + 1] = @truncate(i * 7);
        pixels[i * 3 + 2] = @truncate(i * 11);
    }

    const ppm_data = try makePpm(alloc, width, height, &pixels);
    defer alloc.free(ppm_data);
    try writeTempFile(tmp, "original.ppm", ppm_data);

    // Encode
    var pb1: [std.fs.max_path_bytes]u8 = undefined;
    var pb2: [std.fs.max_path_bytes]u8 = undefined;

    const enc_in = try tmpPath(&pb1, tmp, "original.ppm");
    const enc_out = try tmpPath(&pb2, tmp, "encoded.qoi");

    const enc_result = try runCli(&.{ exe_path, "encode", enc_in, enc_out });
    defer alloc.free(enc_result.stdout);
    defer alloc.free(enc_result.stderr);
    try std.testing.expectEqual(@as(u8, 0), enc_result.term.Exited);

    // Decode
    var pb3: [std.fs.max_path_bytes]u8 = undefined;
    var pb4: [std.fs.max_path_bytes]u8 = undefined;

    const dec_in = try tmpPath(&pb3, tmp, "encoded.qoi");
    const dec_out = try tmpPath(&pb4, tmp, "decoded.ppm");

    const dec_result = try runCli(&.{ exe_path, "decode", dec_in, dec_out });
    defer alloc.free(dec_result.stdout);
    defer alloc.free(dec_result.stderr);
    try std.testing.expectEqual(@as(u8, 0), dec_result.term.Exited);

    // Compare original with decoded
    // Note: decoded output will be PPM (3 channels) since encoder was RGB
    const decoded_data = try readTempFile(alloc, tmp, "decoded.ppm");
    defer alloc.free(decoded_data);

    // The decoded file might be PAM if the decoder always outputs PAM.
    // Let's read it with the auto-detect reader
    var decoded_img = try image_io.readImage(alloc, decoded_data);
    defer decoded_img.deinit();

    try std.testing.expectEqual(width, decoded_img.width);
    try std.testing.expectEqual(height, decoded_img.height);

    // Compare pixel data (channels may differ: original is 3-ch, decoded might be 3 or 4)
    if (decoded_img.channels == 3) {
        try std.testing.expectEqualSlices(u8, &pixels, decoded_img.pixels);
    } else {
        // If PAM (4 channels), compare RGB channels ignoring alpha
        for (0..width * height) |i| {
            try std.testing.expectEqual(pixels[i * 3 + 0], decoded_img.pixels[i * 4 + 0]);
            try std.testing.expectEqual(pixels[i * 3 + 1], decoded_img.pixels[i * 4 + 1]);
            try std.testing.expectEqual(pixels[i * 3 + 2], decoded_img.pixels[i * 4 + 2]);
        }
    }
}

test "CLI: error on non-existent input file" {
    const alloc = std.testing.allocator;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var exe_buf: [std.fs.max_path_bytes]u8 = undefined;
    const exe_path = getExePath(&exe_buf) catch |err| {
        if (err == error.SkipZigTest) return err;
        return err;
    };

    var pb: [std.fs.max_path_bytes]u8 = undefined;
    const output_path = try tmpPath(&pb, tmp, "out.qoi");

    const result = try runCli(&.{ exe_path, "encode", "/tmp/nonexistent_qoizig_test_file.ppm", output_path });
    defer alloc.free(result.stdout);
    defer alloc.free(result.stderr);

    try std.testing.expectEqual(@as(u8, 1), result.term.Exited);
    try std.testing.expect(std.mem.indexOf(u8, result.stderr, "Error:") != null);
}

test "CLI: error on corrupt PPM header" {
    const alloc = std.testing.allocator;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var exe_buf: [std.fs.max_path_bytes]u8 = undefined;
    const exe_path = getExePath(&exe_buf) catch |err| {
        if (err == error.SkipZigTest) return err;
        return err;
    };

    // Write a corrupt file
    try writeTempFile(tmp, "corrupt.txt", "This is not a valid image file");

    var pb1: [std.fs.max_path_bytes]u8 = undefined;
    var pb2: [std.fs.max_path_bytes]u8 = undefined;

    const input_path = try tmpPath(&pb1, tmp, "corrupt.txt");
    const output_path = try tmpPath(&pb2, tmp, "out.qoi");

    const result = try runCli(&.{ exe_path, "encode", input_path, output_path });
    defer alloc.free(result.stdout);
    defer alloc.free(result.stderr);

    try std.testing.expectEqual(@as(u8, 1), result.term.Exited);
    try std.testing.expect(std.mem.indexOf(u8, result.stderr, "Error: Invalid PPM/PAM header") != null);
}

test "CLI: error on truncated QOI decode" {
    const alloc = std.testing.allocator;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var exe_buf: [std.fs.max_path_bytes]u8 = undefined;
    const exe_path = getExePath(&exe_buf) catch |err| {
        if (err == error.SkipZigTest) return err;
        return err;
    };

    // Create a truncated QOI file (just header, no data or end marker)
    const hdr = qoi.QoiHeader{ .width = 10, .height = 10, .channels = .rgb, .colorspace = .srgb };
    const header_bytes = hdr.encode();
    try writeTempFile(tmp, "truncated.qoi", &header_bytes);

    var pb1: [std.fs.max_path_bytes]u8 = undefined;
    var pb2: [std.fs.max_path_bytes]u8 = undefined;

    const input_path = try tmpPath(&pb1, tmp, "truncated.qoi");
    const output_path = try tmpPath(&pb2, tmp, "out.pam");

    const result = try runCli(&.{ exe_path, "decode", input_path, output_path });
    defer alloc.free(result.stdout);
    defer alloc.free(result.stderr);

    try std.testing.expectEqual(@as(u8, 1), result.term.Exited);
    try std.testing.expect(std.mem.indexOf(u8, result.stderr, "Error:") != null);
}

test "CLI: error on invalid command" {
    const alloc = std.testing.allocator;

    var exe_buf: [std.fs.max_path_bytes]u8 = undefined;
    const exe_path = getExePath(&exe_buf) catch |err| {
        if (err == error.SkipZigTest) return err;
        return err;
    };

    const result = try runCli(&.{ exe_path, "invalid", "a", "b" });
    defer alloc.free(result.stdout);
    defer alloc.free(result.stderr);

    try std.testing.expectEqual(@as(u8, 1), result.term.Exited);
}

test "CLI: error on missing arguments" {
    const alloc = std.testing.allocator;

    var exe_buf: [std.fs.max_path_bytes]u8 = undefined;
    const exe_path = getExePath(&exe_buf) catch |err| {
        if (err == error.SkipZigTest) return err;
        return err;
    };

    const result = try runCli(&.{exe_path});
    defer alloc.free(result.stdout);
    defer alloc.free(result.stderr);

    try std.testing.expectEqual(@as(u8, 1), result.term.Exited);
}

test "CLI: error decoding non-QOI file" {
    const alloc = std.testing.allocator;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var exe_buf: [std.fs.max_path_bytes]u8 = undefined;
    const exe_path = getExePath(&exe_buf) catch |err| {
        if (err == error.SkipZigTest) return err;
        return err;
    };

    try writeTempFile(tmp, "notqoi.qoi", "This is definitely not a QOI file");

    var pb1: [std.fs.max_path_bytes]u8 = undefined;
    var pb2: [std.fs.max_path_bytes]u8 = undefined;

    const input_path = try tmpPath(&pb1, tmp, "notqoi.qoi");
    const output_path = try tmpPath(&pb2, tmp, "out.pam");

    const result = try runCli(&.{ exe_path, "decode", input_path, output_path });
    defer alloc.free(result.stdout);
    defer alloc.free(result.stderr);

    try std.testing.expectEqual(@as(u8, 1), result.term.Exited);
    try std.testing.expect(std.mem.indexOf(u8, result.stderr, "Error: Not a QOI file") != null);
}

// ═══════════════════════════════════════════════════════════════════════════
// Large / stress tests
// ═══════════════════════════════════════════════════════════════════════════

test "large image round-trip: 256x256 gradient" {
    const alloc = std.testing.allocator;
    const width: u32 = 256;
    const height: u32 = 256;
    const pixel_count = width * height;

    const pixels = try alloc.alloc(u8, pixel_count * 3);
    defer alloc.free(pixels);

    for (0..pixel_count) |i| {
        const x: u8 = @truncate(i % width);
        const y: u8 = @truncate(i / width);
        pixels[i * 3 + 0] = x;
        pixels[i * 3 + 1] = y;
        pixels[i * 3 + 2] = x ^ y;
    }

    // PPM round-trip through QOI
    const ppm_data = try makePpm(alloc, width, height, pixels);
    defer alloc.free(ppm_data);

    var img = try image_io.readPpm(alloc, ppm_data);
    defer img.deinit();

    const qoi_data = try encoder.encode(alloc, img.pixels, img.width, img.height, .rgb, .srgb);
    defer alloc.free(qoi_data);

    var decoded = try decoder.decode(alloc, qoi_data);
    defer decoded.deinit(alloc);

    try std.testing.expectEqual(pixel_count, decoded.pixels.len);
    for (0..pixel_count) |i| {
        try std.testing.expectEqual(pixels[i * 3 + 0], decoded.pixels[i].r);
        try std.testing.expectEqual(pixels[i * 3 + 1], decoded.pixels[i].g);
        try std.testing.expectEqual(pixels[i * 3 + 2], decoded.pixels[i].b);
    }
}

test "large image round-trip: 128x128 RGBA with varying alpha" {
    const alloc = std.testing.allocator;
    const width: u32 = 128;
    const height: u32 = 128;
    const pixel_count = width * height;

    const pixels = try alloc.alloc(u8, pixel_count * 4);
    defer alloc.free(pixels);

    for (0..pixel_count) |i| {
        pixels[i * 4 + 0] = @truncate(i * 3);
        pixels[i * 4 + 1] = @truncate(i * 7);
        pixels[i * 4 + 2] = @truncate(i * 13);
        pixels[i * 4 + 3] = @truncate(i * 17);
    }

    const qoi_data = try encoder.encode(alloc, pixels, width, height, .rgba, .srgb);
    defer alloc.free(qoi_data);

    var decoded = try decoder.decode(alloc, qoi_data);
    defer decoded.deinit(alloc);

    try std.testing.expectEqual(pixel_count, decoded.pixels.len);
    for (0..pixel_count) |i| {
        try std.testing.expectEqual(pixels[i * 4 + 0], decoded.pixels[i].r);
        try std.testing.expectEqual(pixels[i * 4 + 1], decoded.pixels[i].g);
        try std.testing.expectEqual(pixels[i * 4 + 2], decoded.pixels[i].b);
        try std.testing.expectEqual(pixels[i * 4 + 3], decoded.pixels[i].a);
    }
}

test "solid color image: all pixels identical, high compression" {
    const alloc = std.testing.allocator;
    const width: u32 = 100;
    const height: u32 = 100;
    const pixel_count = width * height;

    const pixels = try alloc.alloc(u8, pixel_count * 3);
    defer alloc.free(pixels);

    // All red
    for (0..pixel_count) |i| {
        pixels[i * 3 + 0] = 255;
        pixels[i * 3 + 1] = 0;
        pixels[i * 3 + 2] = 0;
    }

    const qoi_data = try encoder.encode(alloc, pixels, width, height, .rgb, .srgb);
    defer alloc.free(qoi_data);

    // Should be very compact: header + a few chunks + end marker
    // 10000 pixels: first pixel QOI_OP_RGB(4 bytes), then 9999 in runs of 62
    // 9999 / 62 = 161 runs + 17 remainder = 162 run chunks
    // Total ≈ 14 + 4 + 162 + 8 = 188 bytes (much less than raw 30000)
    try std.testing.expect(qoi_data.len < 300);

    var decoded = try decoder.decode(alloc, qoi_data);
    defer decoded.deinit(alloc);

    for (decoded.pixels) |px| {
        try std.testing.expectEqual(@as(u8, 255), px.r);
        try std.testing.expectEqual(@as(u8, 0), px.g);
        try std.testing.expectEqual(@as(u8, 0), px.b);
        try std.testing.expectEqual(@as(u8, 255), px.a);
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// QOI output structure verification
// ═══════════════════════════════════════════════════════════════════════════

test "QOI output is exactly header + data + end marker" {
    const alloc = std.testing.allocator;

    // 1x1 black pixel → run of 1
    const pixels = [_]u8{ 0, 0, 0 };
    const qoi_data = try encoder.encode(alloc, &pixels, 1, 1, .rgb, .srgb);
    defer alloc.free(qoi_data);

    // header(14) + 1 run byte + end_marker(8) = 23
    try std.testing.expectEqual(@as(usize, 23), qoi_data.len);
    try std.testing.expectEqual(@as(usize, 14), qoi.QOI_HEADER_SIZE);
    try std.testing.expectEqual(@as(usize, 8), qoi.QOI_END_MARKER.len);

    // Verify total = header_size + data_size + end_marker_size
    const data_size = qoi_data.len - qoi.QOI_HEADER_SIZE - qoi.QOI_END_MARKER.len;
    try std.testing.expectEqual(@as(usize, 1), data_size);
}

test "QOI header big-endian width and height in encoded output" {
    const alloc = std.testing.allocator;

    const width: u32 = 300;
    const height: u32 = 200;
    const pixel_count = width * height;

    const pixels = try alloc.alloc(u8, pixel_count * 3);
    defer alloc.free(pixels);
    @memset(pixels, 0);

    const qoi_data = try encoder.encode(alloc, pixels, width, height, .rgb, .srgb);
    defer alloc.free(qoi_data);

    // Read width from bytes 4..8 big-endian
    const encoded_width = std.mem.readInt(u32, qoi_data[4..8], .big);
    const encoded_height = std.mem.readInt(u32, qoi_data[8..12], .big);
    try std.testing.expectEqual(width, encoded_width);
    try std.testing.expectEqual(height, encoded_height);
}

// ═══════════════════════════════════════════════════════════════════════════
// Edge cases: 1xN and Nx1 images
// ═══════════════════════════════════════════════════════════════════════════

test "round-trip 1x100 tall image" {
    const alloc = std.testing.allocator;
    const width: u32 = 1;
    const height: u32 = 100;

    var pixels: [width * height * 3]u8 = undefined;
    for (0..width * height) |i| {
        pixels[i * 3 + 0] = @truncate(i);
        pixels[i * 3 + 1] = @truncate(i * 2);
        pixels[i * 3 + 2] = @truncate(i * 3);
    }

    const qoi_data = try encoder.encode(alloc, &pixels, width, height, .rgb, .srgb);
    defer alloc.free(qoi_data);

    var decoded = try decoder.decode(alloc, qoi_data);
    defer decoded.deinit(alloc);

    try std.testing.expectEqual(width, decoded.header.width);
    try std.testing.expectEqual(height, decoded.header.height);
    for (0..width * height) |i| {
        try std.testing.expectEqual(pixels[i * 3 + 0], decoded.pixels[i].r);
        try std.testing.expectEqual(pixels[i * 3 + 1], decoded.pixels[i].g);
        try std.testing.expectEqual(pixels[i * 3 + 2], decoded.pixels[i].b);
    }
}

test "round-trip 100x1 wide image" {
    const alloc = std.testing.allocator;
    const width: u32 = 100;
    const height: u32 = 1;

    var pixels: [width * height * 3]u8 = undefined;
    for (0..width * height) |i| {
        pixels[i * 3 + 0] = @truncate(i * 5);
        pixels[i * 3 + 1] = @truncate(i * 11);
        pixels[i * 3 + 2] = @truncate(i * 17);
    }

    const qoi_data = try encoder.encode(alloc, &pixels, width, height, .rgb, .srgb);
    defer alloc.free(qoi_data);

    var decoded = try decoder.decode(alloc, qoi_data);
    defer decoded.deinit(alloc);

    try std.testing.expectEqual(width, decoded.header.width);
    try std.testing.expectEqual(height, decoded.header.height);
    for (0..width * height) |i| {
        try std.testing.expectEqual(pixels[i * 3 + 0], decoded.pixels[i].r);
        try std.testing.expectEqual(pixels[i * 3 + 1], decoded.pixels[i].g);
        try std.testing.expectEqual(pixels[i * 3 + 2], decoded.pixels[i].b);
    }
}

test "round-trip 1x1 single pixel all chunk types possible" {
    const alloc = std.testing.allocator;

    // Test a variety of single-pixel values
    const test_pixels = [_][3]u8{
        .{ 0, 0, 0 }, // matches default → RUN
        .{ 1, 1, 1 }, // small diff → DIFF
        .{ 255, 255, 255 }, // small diff (negative) → DIFF
        .{ 10, 8, 6 }, // luma → LUMA
        .{ 200, 100, 50 }, // big → RGB
    };

    for (test_pixels) |px| {
        const encoded = try encoder.encode(alloc, &px, 1, 1, .rgb, .srgb);
        defer alloc.free(encoded);

        var decoded = try decoder.decode(alloc, encoded);
        defer decoded.deinit(alloc);

        try std.testing.expectEqual(px[0], decoded.pixels[0].r);
        try std.testing.expectEqual(px[1], decoded.pixels[0].g);
        try std.testing.expectEqual(px[2], decoded.pixels[0].b);
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// Interoperability: verify auto-detect readImage works for both formats
// ═══════════════════════════════════════════════════════════════════════════

test "auto-detect: PPM through full pipeline" {
    const alloc = std.testing.allocator;
    const pixels = [_]u8{ 42, 84, 126, 168, 210, 252 };

    const ppm = try image_io.writePpm(alloc, 2, 1, &pixels);
    defer alloc.free(ppm);

    var img = try image_io.readImage(alloc, ppm);
    defer img.deinit();

    try std.testing.expectEqual(@as(u8, 3), img.channels);
    try std.testing.expectEqualSlices(u8, &pixels, img.pixels);
}

test "auto-detect: PAM through full pipeline" {
    const alloc = std.testing.allocator;
    const pixels = [_]u8{ 42, 84, 126, 200, 168, 210, 252, 100 };

    const pam = try image_io.writePam(alloc, 2, 1, &pixels);
    defer alloc.free(pam);

    var img = try image_io.readImage(alloc, pam);
    defer img.deinit();

    try std.testing.expectEqual(@as(u8, 4), img.channels);
    try std.testing.expectEqualSlices(u8, &pixels, img.pixels);
}

test "writeImage dispatches correctly by channel count" {
    const alloc = std.testing.allocator;

    // 3 channels → PPM
    const rgb_pixels = [_]u8{ 1, 2, 3 };
    const ppm = try image_io.writeImage(alloc, 1, 1, 3, &rgb_pixels);
    defer alloc.free(ppm);
    try std.testing.expect(ppm[0] == 'P' and ppm[1] == '6');

    // 4 channels → PAM
    const rgba_pixels = [_]u8{ 1, 2, 3, 4 };
    const pam = try image_io.writeImage(alloc, 1, 1, 4, &rgba_pixels);
    defer alloc.free(pam);
    try std.testing.expect(pam[0] == 'P' and pam[1] == '7');
}
