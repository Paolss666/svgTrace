const std = @import("std");

// Base64 encoding and decoding functions

pub fn decode(alloc: std.mem.Allocator, text: []const u8) ![]u8 {
    const dec = std.base64.standard.decoderWithIgnore(" \r\n\t");
    const buf = try alloc.alloc(u8, dec.calcSizeUpperBound(text.len));

    errdefer alloc.free(buf);

    const len = try dec.decode(buf, text);
    return alloc.realloc(buf, len);
}
