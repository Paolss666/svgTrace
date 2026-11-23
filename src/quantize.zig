const std = @import("std");
const Image = @import("image.zig").Image;

/// Keeps the high bits of a channel and maps the value to the centre of its bucket.
/// `drop` is how many low bits are thrown away (0..7).
/// v & mask = (v/bucket) * bucket + bucket / 2
pub fn quantizeChannel(v: u8, drop: u3) u8 {
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
