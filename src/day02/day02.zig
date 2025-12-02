const std = @import("std");
const file_reader = @import("file_reader");

const Range = struct {
    lower_bound: usize,
    upper_bound: usize,
};

const Day02Error = error{
    NoLowerBound,
    NoUpperBound,
};

pub fn solve(allocator: std.mem.Allocator) !void {
    const file_name = "inputs/day02.input";

    const file_content = try file_reader.read_file(file_name, allocator);
    defer allocator.free(file_content);

    const list = try parse_content(file_content, allocator);
    defer allocator.free(list);

    std.debug.print("Day 02:\n", .{});

    solve_part1(list);
    solve_part2(list);

    std.debug.print("\n", .{});
}

fn solve_part1(list: []Range) void {
    var sum: usize = 0;

    for (list) |range| {
        const upper_bound = range.upper_bound + 1;
        for (range.lower_bound..upper_bound) |number| {
            if (is_invalid_part1(number)) {
                sum += number;
            }
        }
    }

    std.debug.print("\tPart 1: {}\n", .{sum});
}

fn is_invalid_part1(number: usize) bool {
    const log = std.math.log10(number);
    return switch (1 + log) {
        1 => false,
        2 => @mod(number, 11) == 0,
        3 => false,
        4 => @mod(number, 101) == 0,
        5 => false,
        6 => @mod(number, 1001) == 0,
        7 => false,
        8 => @mod(number, 10001) == 0,
        9 => false,
        10 => @mod(number, 100001) == 0,
        else => unreachable,
    };
}

fn solve_part2(list: []Range) void {
    var sum: usize = 0;

    for (list) |range| {
        const upper_bound = range.upper_bound + 1;
        for (range.lower_bound..upper_bound) |number| {
            if (is_invalid_part2(number)) {
                sum += number;
            }
        }
    }

    std.debug.print("\tPart 2: {}\n", .{sum});
}

fn is_invalid_part2(number: usize) bool {
    const log = std.math.log10(number);
    return switch (1 + log) {
        1 => false,
        2 => @mod(number, 11) == 0,
        3 => @mod(number, 111) == 0,
        4 => @mod(number, 101) == 0,
        5 => @mod(number, 11111) == 0,
        6 => @mod(number, 1001) == 0 or @mod(number, 10101) == 0,
        7 => @mod(number, 1111111) == 0,
        8 => @mod(number, 1010101) == 0 or @mod(number, 10001) == 0,
        9 => @mod(number, 1001001) == 0,
        10 => @mod(number, 101010101) == 0 or @mod(number, 100001) == 0,
        else => unreachable,
    };
}

fn parse_content(content: []u8, allocator: std.mem.Allocator) ![]Range {
    var it = std.mem.splitSequence(u8, content, ",");
    var list = std.ArrayList(Range).empty;
    errdefer list.deinit(allocator);

    while (it.next()) |range| {
        if (range.len == 0) continue;

        var parts = std.mem.splitSequence(u8, range, "-");

        const lower_bound_text = parts.next() orelse return Day02Error.NoLowerBound;
        const upper_bound_text = parts.next() orelse return Day02Error.NoUpperBound;

        const lower_bound = try std.fmt.parseInt(usize, lower_bound_text, 10);
        const upper_bound = try std.fmt.parseInt(usize, upper_bound_text, 10);

        try list.append(allocator, Range{
            .lower_bound = lower_bound,
            .upper_bound = upper_bound,
        });
    }

    return list.toOwnedSlice(allocator);
}
