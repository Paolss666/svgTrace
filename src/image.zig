const std = @import("std");



pub const Pixel = struct {
    r: u8,
    g: u8,
    b: u8,
};

pub const Image = struct{
    w: usize,
    h: usize,
    pixels: []u8,

    pub fn init(alloc: std.mem.Allocator, width: usize, height: usize) !Image {
        const pixs = try alloc.alloc(u8, width * height * 3);

        @memset(pixs, 0);

        return .{.w = width, .h  = height, .pixels = pixs};
    }

    pub fn deinit(self: Image, alloc: std.mem.Allocator) void {
        alloc.free(self.pixels);
    }

    // Index first byte of the pixel

    pub fn index(self: Image, x: usize, y:usize) usize{
        return (y * self.w + x) * 3;
    }



    pub fn setPixels(self: Image, x: usize, y: usize, p: Pixel) void {
        const i = self.index(x, y);

        self.pixels[i]  = p.r;
        self.pixels[i+1] = p.g;
        self.pixels[i+2] = p.b;
    }


    pub fn getPixels(self: Image, x: usize, y: usize) Pixel {

        const i = self.index(x, y);

        return . {.r = self.pixels[i], .g = self.pixels[i + 1], .b = self.pixels[i + 2]};
    }

    pub fn print(self: Image) void {
        var y: usize = 0;

        while ( y < self.h) : ( y += 1) {
            var x : usize = 0;
            while ( x < self.w) : (x += 1) {
                const p = self.getPixels(x, y);
                std.debug.print("({d}, {d}, {d})", .{p.r, p.g, p.b});
            }
            std.debug.print("\n", .{});
        }
    }
};
