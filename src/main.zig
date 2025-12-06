const std = @import("std");
const day06 = @import("day06");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    try day06.solve(allocator);
}
