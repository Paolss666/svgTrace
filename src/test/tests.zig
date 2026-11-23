//! All unit tests of the project. Run with `zig build test`.
const std = @import("std");
const svg_trace = @import("svgTrace");
const base64 = svg_trace.base64;
const quantize = svg_trace.quantize;
const svg = svg_trace.svg;
const Image = svg_trace.image.Image;
const add = svg_trace.add;

// ---- root

test "basic add functionality" {
    try std.testing.expect(add(3, 7) == 10);
}

// ---- base64

test "dec simple test" {
    const alloc = std.testing.allocator;
    const text = "SGVsbG8sIFdvcmxkIQ==";
    const decoded = try base64.decode(alloc, text);
    defer alloc.free(decoded);

    try std.testing.expectEqualStrings("Hello, World!", decoded);
}

test "ignore whitespace" {
    const alloc = std.testing.allocator;
    const text = "SGVsbG8sIFdvcmxkIQ==\n\t\r";
    const decoded = try base64.decode(alloc, text);
    defer alloc.free(decoded);

    try std.testing.expectEqualStrings("Hello, World!", decoded);
}

test "index[0] of PNG image" {
    const alloc = std.testing.allocator;
    const text = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAAC0lEQVR42mP8z8BQDwAFgwJ/l9X5AAAAAElFTkSuQmCC";
    const decoded = try base64.decode(alloc, text);
    defer alloc.free(decoded);

    try std.testing.expectEqual(decoded[0], 0x89);
}

test "index[0] of JPEG image" {
    const alloc = std.testing.allocator;
    const text = "/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcU";
    const decoded = try base64.decode(alloc, text);
    defer alloc.free(decoded);

    try std.testing.expectEqual(decoded[0], 0xFF);
}

// ---- image

test "index good pos" {
    const alloc = std.testing.allocator;
    const img = try Image.init(alloc, 4, 2);
    defer img.deinit(alloc);

    try std.testing.expectEqual(@as(usize, 0), img.index(0,0));
    try std.testing.expectEqual(@as(usize, 18), img.index(2,1));
}

// ---- quantize

test "quantizeChannel maps each value to the centre of its bucket" {
    // 1 bit kept: two buckets, [0..127] and [128..255]
    try std.testing.expectEqual(@as(u8, 64), quantize.quantizeChannel(0, 7));
    try std.testing.expectEqual(@as(u8, 64), quantize.quantizeChannel(127, 7));
    try std.testing.expectEqual(@as(u8, 192), quantize.quantizeChannel(128, 7));
    try std.testing.expectEqual(@as(u8, 192), quantize.quantizeChannel(255, 7));
    // 2 bits kept: four buckets of size 64
    try std.testing.expectEqual(@as(u8, 32), quantize.quantizeChannel(63, 6));
    try std.testing.expectEqual(@as(u8, 96), quantize.quantizeChannel(64, 6));
    // nothing dropped: unchanged
    try std.testing.expectEqual(@as(u8, 77), quantize.quantizeChannel(77, 0));
}

test "reduceBits makes similar colors identical" {
    const alloc = std.testing.allocator;
    const img = try Image.init(alloc, 2, 1);
    defer img.deinit(alloc);

    img.setPixels(0, 0, .{ .r = 250, .g = 10, .b = 130 });
    img.setPixels(1, 0, .{ .r = 255, .g = 20, .b = 140 });
    quantize.reduceBits(img, 2);

    try std.testing.expectEqual(img.getPixels(0, 0), img.getPixels(1, 0));
}

test "reduceBits with 8 bits leaves the image unchanged" {
    const alloc = std.testing.allocator;
    const img = try Image.init(alloc, 1, 1);
    defer img.deinit(alloc);

    img.setPixels(0, 0, .{ .r = 1, .g = 128, .b = 255 });
    quantize.reduceBits(img, 8);

    try std.testing.expectEqual(@as(u8, 1), img.getPixels(0, 0).r);
    try std.testing.expectEqual(@as(u8, 128), img.getPixels(0, 0).g);
    try std.testing.expectEqual(@as(u8, 255), img.getPixels(0, 0).b);
}

// ---- svg

test "finds embedded images and skips external ones" {
    const doc =
        \\<svg xmlns="http://www.w3.org/2000/svg">
        \\  <rect x="0" y="0" width="10" height="10"/>
        \\  <image x="5" y="6" width="100" height="50" xlink:href="data:image/jpeg;base64,AAAA"/>
        \\  <image x="1" y="2" width="30" height="40" href="data:image/png;base64,BBBB"/>
        \\  <image x="0" y="0" href="photo.jpg"/>
        \\</svg>
    ;
    var it = svg.ImageIterator{ .svg = doc };

    const a = it.next().?;
    try std.testing.expectEqualStrings("image/jpeg", a.mime);
    try std.testing.expectEqualStrings("AAAA", a.base64);
    try std.testing.expectEqualStrings("100", svg.attr(a.text, "width").?);

    const b = it.next().?;
    try std.testing.expectEqualStrings("image/png", b.mime);
    try std.testing.expectEqualStrings("BBBB", b.base64);
    try std.testing.expectEqualStrings("30", svg.attr(b.text, "width").?);

    try std.testing.expect(it.next() == null);
}

