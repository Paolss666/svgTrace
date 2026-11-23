const std = @import("std");
const Image = @import("image.zig").Image;

pub fn main(init: std.process.Init) !void {
    var it = init.minimal.args.iterate();

    defer it.deinit();

    _ = it.next();

    while (it.next()) |arg| {
        std.debug.print("arg = {s}\n", .{arg});
    }

    const number = [_]u8{ 10, 20, 30, 40 };
    const slice = number[1..4];

    std.debug.print("slice.len = {d}, slice[2] = {d} \n", .{ slice.len, slice[2] });

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    const img = try Image.init(alloc, 4, 2);

    defer img.deinit(alloc);

    img.setPixels(2, 1, .{ .r = 255, .g = 0, .b = 0 });
    img.print();

    std.debug.print("{any}\n", .{img.pixels});
}
