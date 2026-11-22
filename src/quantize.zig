const std = @import("std");
const Image = @import("image.zig").Image;

/// Keeps the high bits of a channel and maps the value to the centre of its bucket.
/// `drop` is how many low bits are thrown away (0..7).
fn quantizeChannel(v: u8, drop: u3) u8 {
    if (drop == 0) return v;
    const mask: u8 = ~((@as(u8, 1) << drop) - 1);
    const half: u8 = @as(u8, 1) << (drop - 1);
    return (v & mask) | half;
}

/// Keeps only the `bits` most significant bits of every channel (1..8), in place.
pub fn reduceBits(img: Image, bits: u4) void {
    std.debug.assert(bits >= 1 and bits <= 8);
    const drop: u3 = @intCast(8 - bits);
    for (img.pixels) |*byte| {
        byte.* = quantizeChannel(byte.*, drop);
    }
}

test "quantizeChannel maps each value to the centre of its bucket" {
    // 1 bit kept: two buckets, [0..127] and [128..255]
    try std.testing.expectEqual(@as(u8, 64), quantizeChannel(0, 7));
    try std.testing.expectEqual(@as(u8, 64), quantizeChannel(127, 7));
    try std.testing.expectEqual(@as(u8, 192), quantizeChannel(128, 7));
    try std.testing.expectEqual(@as(u8, 192), quantizeChannel(255, 7));
    // 2 bits kept: four buckets of size 64
    try std.testing.expectEqual(@as(u8, 32), quantizeChannel(63, 6));
    try std.testing.expectEqual(@as(u8, 96), quantizeChannel(64, 6));
    // nothing dropped: unchanged
    try std.testing.expectEqual(@as(u8, 77), quantizeChannel(77, 0));
}

test "reduceBits makes similar colors identical" {
    const alloc = std.testing.allocator;
    const img = try Image.init(alloc, 2, 1);
    defer img.deinit(alloc);

    img.setPixels(0, 0, .{ .r = 250, .g = 10, .b = 130 });
    img.setPixels(1, 0, .{ .r = 255, .g = 20, .b = 140 });
    reduceBits(img, 2);

    try std.testing.expectEqual(img.getPixels(0, 0), img.getPixels(1, 0));
}

test "reduceBits with 8 bits leaves the image unchanged" {
    const alloc = std.testing.allocator;
    const img = try Image.init(alloc, 1, 1);
    defer img.deinit(alloc);

    img.setPixels(0, 0, .{ .r = 1, .g = 128, .b = 255 });
    reduceBits(img, 8);

    try std.testing.expectEqual(@as(u8, 1), img.getPixels(0, 0).r);
    try std.testing.expectEqual(@as(u8, 128), img.getPixels(0, 0).g);
    try std.testing.expectEqual(@as(u8, 255), img.getPixels(0, 0).b);
}
