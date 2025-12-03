const std = @import("std");
const day03 = @import("day03");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    try day03.solve(allocator);
}
