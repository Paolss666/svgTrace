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
