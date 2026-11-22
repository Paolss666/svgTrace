const std = @import("std");

pub const ImageTag = struct {
    text: []const u8,  // text content of the tag <img src="..." />
    mime: []const u8,  // mime type of the image (e.g., "image/png", "image/jpeg")
    base64: []const u8, // base64-encoded image data
};

// Iterator over <image> tags in an SVG file
pub const ImageIterator = struct {
    svg: []const u8,
    pos: usize = 0,

    pub fn next(self: *ImageIterator) ?ImageTag {

        while (std.mem.indexOfPos(u8, self.svg, self.pos, "<image")) |start| {
            
            const end = std.mem.indexOfPos(u8, self.svg, start, ">") orelse return null;
            
            self.pos = end + 1;
            
            const text = self.svg[start..end];
            
            const p = std.mem.indexOf(u8, text, "data:") orelse continue;
            const semi = std.mem.indexOfPos(u8, text,p, ";base64,") orelse continue;

            const mime = text[p + "data:".len .. semi];
            const data_start = semi + ";base64,".len;
            const data_end = std.mem.indexOfAnyPos(u8, text, data_start, "\"") orelse text.len;

            return .{
                .text = text,
                .mime = mime,
                .base64 = text[data_start .. data_end],
            };
        }
        return null;
    }

};

pub fn attr(text: []const u8, name: []const u8) ?[]const u8 {
    var pos: usize = 0;

    while (std.mem.indexOfPos(u8, text, pos, name)) |i|{
        pos = i + name.len;

        if (i == 0 or !std.ascii.isWhitespace(text[i - 1])) continue;
        if (!std.mem.startsWith(u8, text[pos..], "=\"")) continue;

        const start = pos + 2 ; // skip ="
        const end = std.mem.indexOfScalarPos(u8, text, start, '"') orelse return null;
        return text[start .. end];
    }
    return null;
}

test "finds embedded images and skips external ones" {
    const svg =
        \\<svg xmlns="http://www.w3.org/2000/svg">
        \\  <rect x="0" y="0" width="10" height="10"/>
        \\  <image x="5" y="6" width="100" height="50" xlink:href="data:image/jpeg;base64,AAAA"/>
        \\  <image x="1" y="2" width="30" height="40" href="data:image/png;base64,BBBB"/>
        \\  <image x="0" y="0" href="photo.jpg"/>
        \\</svg>
    ;
    var it = ImageIterator{ .svg = svg };

    const a = it.next().?;
    try std.testing.expectEqualStrings("image/jpeg", a.mime);
    try std.testing.expectEqualStrings("AAAA", a.base64);
    try std.testing.expectEqualStrings("100", attr(a.text, "width").?);

    const b = it.next().?;
    try std.testing.expectEqualStrings("image/png", b.mime);
    try std.testing.expectEqualStrings("BBBB", b.base64);
    try std.testing.expectEqualStrings("30", attr(b.text, "width").?);

    try std.testing.expect(it.next() == null);
}

