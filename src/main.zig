const std = @import("std");
const day04 = @import("day04");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    try day04.solve(allocator);
}
