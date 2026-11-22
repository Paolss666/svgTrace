const std = @import("std");

// Base64 encoding and decoding functions

pub fn decode(alloc: std.mem.Allocator, text: []const u8) ![]u8 {
    const dec = std.base64.standard.decoderWithIgnore("\n\r\t ");
    const buf = try alloc.alloc(u8, dec.calcSizeUpperBound(text.len));

    errdefer alloc.free(buf);

    const len = try dec.decode(buf, text);
    return alloc.realloc(buf, len);
}

test "dec simple test" {
    const alloc = std.testing.allocator;
    const text = "SGVsbG8sIFdvcmxkIQ==";
    const decoded = try decode(alloc, text);
    defer alloc.free(decoded);

    try std.testing.expectEqualStrings("Hello, World!", decoded);
}

test "ignore whitespace" {
    const alloc = std.testing.allocator;
    const text = "SGVsbG8sIFdvcmxkIQ==\n\t\r";
    const decoded = try decode(alloc, text);
    defer alloc.free(decoded);

    try std.testing.expectEqualStrings("Hello, World!", decoded);
}

test "index[0] of PNG image" {
    const alloc = std.testing.allocator;
    const text = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAAC0lEQVR42mP8z8BQDwAFgwJ/l9X5AAAAAElFTkSuQmCC";
    const decoded = try decode(alloc, text);
    defer alloc.free(decoded);

    try std.testing.expectEqual(decoded[0], 0x89);
}

test "index[0] of JPEG image" {
    const alloc = std.testing.allocator;
    const text = "/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcU";
    const decoded = try decode(alloc, text);
    defer alloc.free(decoded);

    try std.testing.expectEqual(decoded[0], 0xFF);
}
