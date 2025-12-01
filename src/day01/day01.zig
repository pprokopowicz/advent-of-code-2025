const std = @import("std");
const file_reader = @import("file_reader");

pub fn solve(allocator: std.mem.Allocator) !void {
    const file_name = "inputs/day01.txt";

    const file_content = try file_reader.read_file(file_name, allocator);
    defer allocator.free(file_content);

    // const list = try parse_content(file_content, allocator);
    // defer allocator.free(list);

    std.debug.print("Day 01:\n", .{});

    std.debug.print("\n", .{});
}

// fn solve_part1(list: []usize) void {
//     std.debug.print("\tPart 1: {}\n", .{number_of_incs});
// }

// fn solve_part2(list: []usize) void {
//     std.debug.print("\tPart 2: {}\n", .{number_of_incs});
// }
