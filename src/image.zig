const std = @import("std");

pub const Pixel = @Vector(3, u8); // len know at compile time, so we can use a vector type

pub const Image = struct {
    w: usize,
    h: usize,
    pixels: []u8,

    pub fn init(alloc: std.mem.Allocator, width: usize, height: usize) !Image {
        const pixs = try alloc.alloc(u8, width * height * 3);

        @memset(pixs, 0);

        return .{ .w = width, .h = height, .pixels = pixs };
    }

    pub fn deinit(self: Image, alloc: std.mem.Allocator) void {
        alloc.free(self.pixels);
    }

    // Index first byte of the pixel

    pub fn index(self: Image, x: usize, y: usize) usize {
        return (y * self.w + x) * 3;
    }

    pub fn setPixels(self: Image, x: usize, y: usize, p: Pixel) void {
        const i = self.index(x, y);

        self.pixels[i..][0..3].* = p; // most beautiful line of code ever written in Zig, I think. It is a slice of a slice, and then we dereference it to get the underlying array, which we can assign to. The compiler will check that the lengths match.
    }

    pub fn getPixels(self: Image, x: usize, y: usize) Pixel {
        const i = self.index(x, y);

        return self.pixels[i..][0..3].*;
    }

    pub fn print(self: Image) void {
        var y: usize = 0;

        while (y < self.h) : (y += 1) {
            var x: usize = 0;
            while (x < self.w) : (x += 1) {
                const p = self.getPixels(x, y);
                std.debug.print("({d}, {d}, {d})", .{ p[0], p[1], p[2] });
            }
            std.debug.print("\n", .{});
        }
    }
};
