const std = @import("std");
const qoi = @import("qoizig");
const encoder = qoi.encoder;
const decoder = qoi.decoder;
const image_io = qoi.image_io;

const usage =
    \\Usage: qoizig <command> <input> <output>
    \\
    \\Commands:
    \\  encode  Encode a PPM/PAM image to QOI format
    \\  decode  Decode a QOI image to PPM/PAM format
    \\
;

fn getStdErr() std.fs.File {
    return .{ .handle = std.posix.STDERR_FILENO };
}

fn getStdOut() std.fs.File {
    return .{ .handle = std.posix.STDOUT_FILENO };
}

fn printErr(comptime fmt: []const u8, args: anytype) void {
    var buf: [1024]u8 = undefined;
    const msg = std.fmt.bufPrint(&buf, fmt, args) catch {
        getStdErr().writeAll("Error\n") catch {};
        return;
    };
    getStdErr().writeAll(msg) catch {};
}

fn printOut(comptime fmt: []const u8, args: anytype) void {
    var buf: [1024]u8 = undefined;
    const msg = std.fmt.bufPrint(&buf, fmt, args) catch return;
    getStdOut().writeAll(msg) catch {};
}

fn fatal(comptime fmt: []const u8, args: anytype) noreturn {
    printErr("Error: " ++ fmt ++ "\n", args);
    std.process.exit(1);
}

pub fn main() void {
    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = std.process.argsAlloc(allocator) catch {
        fatal("Out of memory", .{});
    };
    defer std.process.argsFree(allocator, args);

    if (args.len < 4) {
        getStdErr().writeAll(usage) catch {};
        std.process.exit(1);
    }

    const command = args[1];
    const input_path = args[2];
    const output_path = args[3];

    if (std.mem.eql(u8, command, "encode")) {
        doEncode(allocator, input_path, output_path);
    } else if (std.mem.eql(u8, command, "decode")) {
        doDecode(allocator, input_path, output_path);
    } else {
        getStdErr().writeAll(usage) catch {};
        std.process.exit(1);
    }
}

fn readFile(allocator: std.mem.Allocator, path: []const u8) []u8 {
    const file = std.fs.cwd().openFile(path, .{}) catch {
        fatal("File not found: {s}", .{path});
    };
    defer file.close();
    return file.readToEndAlloc(allocator, std.math.maxInt(usize)) catch {
        fatal("Failed to read file: {s}", .{path});
    };
}

fn writeFile(path: []const u8, data: []const u8) void {
    const file = std.fs.cwd().createFile(path, .{}) catch {
        fatal("Failed to create file: {s}", .{path});
    };
    defer file.close();
    file.writeAll(data) catch {
        fatal("Failed to write file: {s}", .{path});
    };
}

fn doEncode(allocator: std.mem.Allocator, input_path: []const u8, output_path: []const u8) void {
    const file_data = readFile(allocator, input_path);
    defer allocator.free(file_data);

    var img = image_io.readImage(allocator, file_data) catch |err| {
        switch (err) {
            error.InvalidHeader => fatal("Invalid PPM/PAM header", .{}),
            error.UnsupportedFormat => fatal("Invalid PPM/PAM header", .{}),
            error.SizeMismatch => fatal("Mismatch between declared size and actual data", .{}),
            error.OutOfMemory => fatal("Out of memory", .{}),
            else => fatal("Failed to read image", .{}),
        }
    };
    defer img.deinit();

    const channels: qoi.Channels = switch (img.channels) {
        3 => .rgb,
        4 => .rgba,
        else => fatal("Unsupported channel count: {d}", .{img.channels}),
    };

    const qoi_data = encoder.encode(
        allocator,
        img.pixels,
        img.width,
        img.height,
        channels,
        .srgb,
    ) catch |err| {
        switch (err) {
            error.InvalidPixelDataLength => fatal("Mismatch between declared size and actual data", .{}),
            error.OutOfMemory => fatal("Out of memory", .{}),
        }
    };
    defer allocator.free(qoi_data);

    writeFile(output_path, qoi_data);

    printOut("Encoded {d}x{d} image to {s}\n", .{ img.width, img.height, output_path });
}

fn doDecode(allocator: std.mem.Allocator, input_path: []const u8, output_path: []const u8) void {
    const file_data = readFile(allocator, input_path);
    defer allocator.free(file_data);

    var result = decoder.decode(allocator, file_data) catch |err| {
        switch (err) {
            error.InvalidMagic => fatal("Not a QOI file", .{}),
            error.UnexpectedEndOfData => fatal("Truncated file or unexpected end of data", .{}),
            error.InvalidEndMarker => fatal("Invalid stream of chunks", .{}),
            error.InvalidDimensions => fatal("Invalid image dimensions", .{}),
            error.InvalidChannels => fatal("Invalid channel count in QOI header", .{}),
            error.InvalidColorspace => fatal("Invalid colorspace in QOI header", .{}),
            error.ExcessData => fatal("Invalid stream of chunks", .{}),
        }
    };
    defer result.deinit(allocator);

    const header = result.header;
    const num_channels: u8 = @intFromEnum(header.channels);
    const pixel_count = header.pixelCount();

    // Convert Pixel array to raw bytes
    const raw_pixels = allocator.alloc(u8, pixel_count * num_channels) catch {
        fatal("Out of memory", .{});
    };
    defer allocator.free(raw_pixels);

    for (result.pixels, 0..) |px, i| {
        const offset = i * num_channels;
        raw_pixels[offset] = px.r;
        raw_pixels[offset + 1] = px.g;
        raw_pixels[offset + 2] = px.b;
        if (num_channels == 4) {
            raw_pixels[offset + 3] = px.a;
        }
    }

    const out_data = image_io.writeImage(allocator, header.width, header.height, num_channels, raw_pixels) catch |err| {
        switch (err) {
            error.SizeMismatch => fatal("Internal error: pixel data size mismatch", .{}),
            error.OutOfMemory => fatal("Out of memory", .{}),
            else => fatal("Failed to write image", .{}),
        }
    };
    defer allocator.free(out_data);

    writeFile(output_path, out_data);

    printOut("Decoded {d}x{d} image to {s}\n", .{ header.width, header.height, output_path });
}
