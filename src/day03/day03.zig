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
    var sum: usize = 0;

    for (list) |bank| {
        const first_max = maximum(bank[0 .. bank.len - 1]);
        const second_max = maximum(bank[first_max.index + 1 ..]);
        sum += first_max.value * 10 + second_max.value;
    }

    std.debug.print("\tPart 1: {}\n", .{sum});
}

fn solve_part2(list: [][]u8) void {
    var sum: usize = 0;

    for (list) |bank| {
        var first_available_index: usize = 0;
        var inner_sum: usize = 0;

        for (0..12) |i| {
            const last_available_index = bank.len - (12 - i - 1);
            const max = maximum(bank[first_available_index..last_available_index]);

            first_available_index += max.index + 1;

            inner_sum += max.value * std.math.pow(usize, 10, 12 - 1 - i);
        }

        sum += inner_sum;
    }

    std.debug.print("\tPart 2: {}\n", .{sum});
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
