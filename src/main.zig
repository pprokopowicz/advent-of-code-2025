const std = @import("std");
const day02 = @import("day02");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    try day02.solve(allocator);
}
