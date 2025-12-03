const std = @import("std");
const file_reader = @import("file_reader");

const Maximum = struct {
    value: u8,
    index: usize,
};

pub fn solve(allocator: std.mem.Allocator) !void {
    const file_name = "inputs/day03.input";

    const file_content = try file_reader.read_file(file_name, allocator);
    defer allocator.free(file_content);

    const list = try parse_content(file_content, allocator);
    defer {
        for (list) |item| {
            allocator.free(item);
        }
        allocator.free(list);
    }

    std.debug.print("Day 03:\n", .{});

    solve_part1(list);
    solve_part2(list);

    std.debug.print("\n", .{});
}

fn solve_part1(list: [][]u8) void {
    std.debug.print("\tPart 1: {}\n", .{maximum_joltages(list, 2)});
}

fn solve_part2(list: [][]u8) void {
    std.debug.print("\tPart 2: {}\n", .{maximum_joltages(list, 12)});
}

fn maximum_joltages(list: [][]u8, number_of_batteries: usize) usize {
    var sum: usize = 0;

    for (list) |bank| {
        var first_available_index: usize = 0;

        for (0..number_of_batteries) |i| {
            const last_available_index = bank.len - (number_of_batteries - i - 1);
            const max = maximum(bank[first_available_index..last_available_index]);

            first_available_index += max.index + 1;

            sum += max.value * std.math.pow(usize, 10, number_of_batteries - 1 - i);
        }
    }

    return sum;
}

fn maximum(list: []u8) Maximum {
    var max = list[0];
    var max_index: usize = 0;

    for (list[1..], 1..) |item, index| {
        if (item > max) {
            max = item;
            max_index = index;
        }
    }

    return Maximum{ .value = max, .index = max_index };
}

fn parse_content(content: []u8, allocator: std.mem.Allocator) ![][]u8 {
    var it = std.mem.splitSequence(u8, content, "\n");

    var list = std.ArrayList([]u8).empty;
    errdefer list.deinit(allocator);

    while (it.next()) |bank| {
        if (bank.len == 0) continue;

        var joltages = std.ArrayList(u8).empty;
        errdefer joltages.deinit(allocator);

        for (bank) |joltage| {
            const joltage_number = try std.fmt.parseInt(u8, &[_]u8{joltage}, 10);
            try joltages.append(allocator, joltage_number);
        }

        const slice = try joltages.toOwnedSlice(allocator);
        try list.append(allocator, slice);
    }

    return list.toOwnedSlice(allocator);
}
