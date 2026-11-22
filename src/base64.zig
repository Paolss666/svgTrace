const std = @import("std");

// Base64 encoding and decoding functions

pub fn encode(alloc: std.mem.Allocator, text: []const u8) ![]u8 {
    const dec = std.base64.standard.decoderWithIgnore("\n\r\t ");
    const buf = try alloc.alloc(u8, dec.calcSizeUpperBound(text.len));

    errdefer alloc.free(buf);

    const len = try dec.decode(buf, text);
    return alloc.realloc(buf, len);
}

test "dec simple test" {
    const alloc = std.testing.allocator;
    const text = "SGVsbG8sIFdvcmxkIQ==";
    const encoded = try encode(alloc, text);
    defer alloc.free(encoded);

    try std.testing.expectEqualStrings("Hello, World!", encoded);
}

test "ignore whitespace" {
    const alloc = std.testing.allocator;
    const text = "SGVsbG8sIFdvcmxkIQ==\n\t\r";
    const decoded = try encode(alloc, text);
    defer alloc.free(decoded);

    try std.testing.expectEqualStrings("Hello, World!", decoded);
}

