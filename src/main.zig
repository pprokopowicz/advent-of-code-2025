const std = @import("std");
const day05 = @import("day05");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    try day05.solve(allocator);
}
