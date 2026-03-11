const std = @import("std");
const qoi = @import("qoi.zig");

const Pixel = qoi.Pixel;
const ChannelDiff = qoi.ChannelDiff;
const QoiHeader = qoi.QoiHeader;
const Channels = qoi.Channels;
const Colorspace = qoi.Colorspace;

/// Encode raw pixel data into a complete QOI byte stream.
///
/// `pixels` must contain exactly `width * height * channels` bytes of
/// interleaved RGB or RGBA data (depending on `channels`).
///
/// Returns an owned slice allocated with `allocator`. Caller must free it.
pub fn encode(
    allocator: std.mem.Allocator,
    pixels: []const u8,
    width: u32,
    height: u32,
    channels: Channels,
    colorspace: Colorspace,
) error{ InvalidPixelDataLength, OutOfMemory }![]u8 {
    const num_channels: usize = @intFromEnum(channels);
    const pixel_count: usize = @as(usize, width) * @as(usize, height);
    const expected_len = pixel_count * num_channels;

    if (pixels.len != expected_len) return error.InvalidPixelDataLength;

    // Max output size: header + each pixel worst-case 5 bytes + end marker
    const max_size = qoi.QOI_HEADER_SIZE + pixel_count * 5 + qoi.QOI_END_MARKER.len;
    var output = try allocator.alloc(u8, max_size);
    errdefer allocator.free(output);

    var pos: usize = 0;

    // Write header
    const header = QoiHeader{
        .width = width,
        .height = height,
        .channels = channels,
        .colorspace = colorspace,
    };
    const header_bytes = header.encode();
    @memcpy(output[pos .. pos + qoi.QOI_HEADER_SIZE], &header_bytes);
    pos += qoi.QOI_HEADER_SIZE;

    // Encoder state
    var index: [qoi.QOI_INDEX_SIZE]Pixel = .{Pixel{ .r = 0, .g = 0, .b = 0, .a = 0 }} ** qoi.QOI_INDEX_SIZE;
    var prev_px: Pixel = Pixel.default;
    var run: u8 = 0;

    var px_offset: usize = 0;
    for (0..pixel_count) |_| {
        const cur_px: Pixel = switch (channels) {
            .rgb => .{
                .r = pixels[px_offset],
                .g = pixels[px_offset + 1],
                .b = pixels[px_offset + 2],
                .a = prev_px.a,
            },
            .rgba => .{
                .r = pixels[px_offset],
                .g = pixels[px_offset + 1],
                .b = pixels[px_offset + 2],
                .a = pixels[px_offset + 3],
            },
        };
        px_offset += num_channels;

        if (cur_px.eql(prev_px)) {
            run += 1;
            if (run == 62) {
                output[pos] = qoi.QOI_OP_RUN | (run - 1);
                pos += 1;
                run = 0;
            }
        } else {
            // Flush any pending run
            if (run > 0) {
                output[pos] = qoi.QOI_OP_RUN | (run - 1);
                pos += 1;
                run = 0;
            }

            const hash_idx = cur_px.hash();

            if (index[hash_idx].eql(cur_px)) {
                // QOI_OP_INDEX
                output[pos] = qoi.QOI_OP_INDEX | @as(u8, hash_idx);
                pos += 1;
            } else {
                index[hash_idx] = cur_px;

                const d = cur_px.diff(prev_px);

                if (d.fitsSmallDiff()) {
                    // QOI_OP_DIFF
                    output[pos] = qoi.QOI_OP_DIFF |
                        ((d.dr +% 2) << 4) |
                        ((d.dg +% 2) << 2) |
                        (d.db +% 2);
                    pos += 1;
                } else if (d.fitsLumaDiff()) {
                    // QOI_OP_LUMA
                    const dr_dg = d.dr -% d.dg;
                    const db_dg = d.db -% d.dg;
                    output[pos] = qoi.QOI_OP_LUMA | (d.dg +% 32);
                    output[pos + 1] = ((dr_dg +% 8) << 4) | (db_dg +% 8);
                    pos += 2;
                } else if (d.da == 0) {
                    // QOI_OP_RGB
                    output[pos] = qoi.QOI_OP_RGB;
                    output[pos + 1] = cur_px.r;
                    output[pos + 2] = cur_px.g;
                    output[pos + 3] = cur_px.b;
                    pos += 4;
                } else {
                    // QOI_OP_RGBA
                    output[pos] = qoi.QOI_OP_RGBA;
                    output[pos + 1] = cur_px.r;
                    output[pos + 2] = cur_px.g;
                    output[pos + 3] = cur_px.b;
                    output[pos + 4] = cur_px.a;
                    pos += 5;
                }
            }
        }

        prev_px = cur_px;
    }

    // Flush any remaining run
    if (run > 0) {
        output[pos] = qoi.QOI_OP_RUN | (run - 1);
        pos += 1;
    }

    // Write end marker
    @memcpy(output[pos .. pos + qoi.QOI_END_MARKER.len], &qoi.QOI_END_MARKER);
    pos += qoi.QOI_END_MARKER.len;

    // Shrink to actual size
    if (allocator.resize(output, pos)) {
        return output[0..pos];
    } else {
        const shrunk = try allocator.alloc(u8, pos);
        @memcpy(shrunk, output[0..pos]);
        allocator.free(output);
        return shrunk;
    }
}

// ── Tests ────────────────────────────────────────────────────────────────────

test "encode single black pixel RGB" {
    const allocator = std.testing.allocator;
    // Single 1x1 black pixel (RGB: 0,0,0). Previous pixel starts as (0,0,0,255)
    // so this is a run of 1.
    const pixels = [_]u8{ 0, 0, 0 };
    const result = try encode(allocator, &pixels, 1, 1, .rgb, .srgb);
    defer allocator.free(result);

    // Check header
    try std.testing.expectEqualSlices(u8, &qoi.QOI_MAGIC, result[0..4]);
    // Width = 1 big-endian
    try std.testing.expectEqualSlices(u8, &[_]u8{ 0, 0, 0, 1 }, result[4..8]);
    // Height = 1 big-endian
    try std.testing.expectEqualSlices(u8, &[_]u8{ 0, 0, 0, 1 }, result[8..12]);
    // Channels = 3
    try std.testing.expectEqual(@as(u8, 3), result[12]);
    // Colorspace = 0
    try std.testing.expectEqual(@as(u8, 0), result[13]);

    // Data: pixel (0,0,0,255) == prev_px → run of 1 → QOI_OP_RUN | 0 = 0xc0
    try std.testing.expectEqual(@as(u8, 0xc0), result[14]);

    // End marker
    const end_start = result.len - 8;
    try std.testing.expectEqualSlices(u8, &qoi.QOI_END_MARKER, result[end_start..]);
}

test "encode single white pixel RGB" {
    const allocator = std.testing.allocator;
    // Single 1x1 white pixel (RGB: 255,255,255). Alpha stays 255.
    // Diff from default (0,0,0,255): dr=255, dg=255, db=255, da=0
    // 255 +% 2 = 1 < 4 for all channels → fitsSmallDiff? 255+%2 = 1, yes all fit.
    // Wait: dr=255, 255+%2 = 1 < 4. dg=255, 255+%2 = 1 < 4. db=255, 255+%2 = 1 < 4. da=0. Yes fits small diff.
    // QOI_OP_DIFF | ((255+%2)<<4) | ((255+%2)<<2) | (255+%2) = 0x40 | (1<<4) | (1<<2) | 1 = 0x40 | 0x10 | 0x04 | 0x01 = 0x55
    // Hmm wait: that's a diff of -1,-1,-1 which gives pixel (255,255,255). That's correct.
    const pixels = [_]u8{ 255, 255, 255 };
    const result = try encode(allocator, &pixels, 1, 1, .rgb, .srgb);
    defer allocator.free(result);

    try std.testing.expectEqual(@as(u8, 0x55), result[14]);
}

test "encode invalid pixel data length" {
    const allocator = std.testing.allocator;
    const pixels = [_]u8{ 0, 0 }; // Too short for 1x1 RGB
    try std.testing.expectError(error.InvalidPixelDataLength, encode(allocator, &pixels, 1, 1, .rgb, .srgb));
}

test "encode run length 62" {
    const allocator = std.testing.allocator;
    // 62 identical pixels that match prev_px (black with alpha 255)
    var pixels: [62 * 3]u8 = .{0} ** (62 * 3);
    _ = &pixels;
    const result = try encode(allocator, &pixels, 62, 1, .rgb, .srgb);
    defer allocator.free(result);

    // Should be one run chunk of 62: QOI_OP_RUN | 61 = 0xc0 | 0x3d = 0xfd
    try std.testing.expectEqual(@as(u8, 0xfd), result[14]);
    // Then end marker
    try std.testing.expectEqualSlices(u8, &qoi.QOI_END_MARKER, result[15 .. 15 + 8]);
}

test "encode RGBA with alpha change" {
    const allocator = std.testing.allocator;
    // Pixel with alpha != 255 requires QOI_OP_RGBA
    const pixels = [_]u8{ 100, 150, 200, 128 };
    const result = try encode(allocator, &pixels, 1, 1, .rgba, .srgb);
    defer allocator.free(result);

    try std.testing.expectEqual(qoi.QOI_OP_RGBA, result[14]);
    try std.testing.expectEqual(@as(u8, 100), result[15]);
    try std.testing.expectEqual(@as(u8, 150), result[16]);
    try std.testing.expectEqual(@as(u8, 200), result[17]);
    try std.testing.expectEqual(@as(u8, 128), result[18]);
}

test "encode index hit" {
    const allocator = std.testing.allocator;
    // Two pixels: first is (10,20,30) which gets encoded, second is default (0,0,0) → run,
    // third is (10,20,30) again → should be QOI_OP_INDEX.
    // Actually let's do: pixel A, pixel B (different), pixel A again.
    // pixel A = (10, 20, 30), channels=rgb so alpha=255
    // prev = (0,0,0,255), A = (10,20,30,255)
    // diff: dr=10, dg=20, db=30. fitsSmallDiff? 10+%2=12 ≥4. No.
    // fitsLumaDiff? dg=20, 20+%32=52 < 64. dr_dg=10-%20=246, 246+%8=254≥16. No.
    // So QOI_OP_RGB for pixel A.
    // pixel B = (0,0,0), prev=(10,20,30,255), B=(0,0,0,255)
    // diff: dr=246, dg=236, db=226, da=0. fitsSmallDiff? No. fitsLuma? dg=236, 236+%32=268 truncated... 236+32=268, as u8 = 12, so 12 < 64, yes. dr_dg=246-%236=10, 10+%8=18≥16. No.
    // So QOI_OP_RGB for pixel B.
    // pixel C = (10,20,30,255) = pixel A. Check index: hash of A should still be A.
    // → QOI_OP_INDEX
    const pixels = [_]u8{ 10, 20, 30, 0, 0, 0, 10, 20, 30 };
    const result = try encode(allocator, &pixels, 3, 1, .rgb, .srgb);
    defer allocator.free(result);

    // First pixel: QOI_OP_RGB
    try std.testing.expectEqual(qoi.QOI_OP_RGB, result[14]);
    // Second pixel at offset 18
    // But wait, (0,0,0,255) is in the index at hash(0,0,0,255) from the start? No, the index is zero-initialized with (0,0,0,0), not (0,0,0,255). So hash(0,0,0,255) = (0+0+0+255*11)%64 = 2805%64 = 53. index[53] starts as (0,0,0,0) ≠ (0,0,0,255). So no index hit.
    // After first pixel (10,20,30,255), index[hash(10,20,30,255)] = (10,20,30,255).
    // Second pixel (0,0,0,255): check index[hash(0,0,0,255)=53]. index[53]=(0,0,0,0)≠(0,0,0,255). Not a hit.
    // After encoding second pixel, index[53] = (0,0,0,255).
    // Third pixel (10,20,30,255): hash = (10*3+20*5+30*7+255*11)%64 = (30+100+210+2805)%64 = 3145%64 = 3145-49*64=3145-3136=9. index[9]=(10,20,30,255). Match! → QOI_OP_INDEX | 9
    // Find offset of third pixel in output: header(14) + pixel1(4=RGB) + pixel2(?) + pixel3
    // pixel2: (0,0,0,255) from prev (10,20,30,255). diff: dr=246,dg=236,db=226. Not small diff. Luma: dg=236, 236+%32 as u8: 236+32=268→12. 12<64 ok. dr_dg=246-%236=10. 10+%8=18≥16. No luma. da=0 → QOI_OP_RGB. 4 bytes.
    // So third pixel at offset 14+4+4 = 22.
    try std.testing.expectEqual(qoi.QOI_OP_INDEX | 9, result[22]);
}

test "encode output size is exact" {
    const allocator = std.testing.allocator;
    const pixels = [_]u8{ 0, 0, 0 };
    const result = try encode(allocator, &pixels, 1, 1, .rgb, .srgb);
    defer allocator.free(result);

    // header(14) + run_chunk(1) + end_marker(8) = 23
    try std.testing.expectEqual(@as(usize, 23), result.len);
}
