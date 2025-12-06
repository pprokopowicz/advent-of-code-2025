const std = @import("std");
const model = @import("model.zig");
const Operation = model.Operation;
const Homework = model.Homework;

pub fn part1(content: []u8, allocator: std.mem.Allocator) !Homework {
    var indexes = try whitespace_indexes(content, allocator);
    defer indexes.deinit();

    var it = std.mem.splitSequence(u8, content, "\n");

    var numbers = std.ArrayList([]usize).empty;
    errdefer numbers.deinit(allocator);

    var operations = std.ArrayList(Operation).empty;
    errdefer operations.deinit(allocator);

    while (it.next()) |line| {
        if (line.len == 0) continue;

        var current_number = std.ArrayList(u8).empty;
        var numbers_line = std.ArrayList(usize).empty;

        for (line, 0..) |char, index| {
            if (char == '+') {
                try operations.append(allocator, Operation.add);
                continue;
            } else if (char == '*') {
                try operations.append(allocator, Operation.multiply);
                continue;
            }

            if (indexes.contains(index) and current_number.items.len > 0) {
                const number_string = try current_number.toOwnedSlice(allocator);
                const number = try std.fmt.parseInt(usize, number_string, 10);

                allocator.free(number_string);

                try numbers_line.append(allocator, number);

                continue;
            }

            if (index == line.len - 1) {
                if (char != ' ') {
                    try current_number.append(allocator, char);
                }

                const number_string = try current_number.toOwnedSlice(allocator);
                const number = try std.fmt.parseInt(usize, number_string, 10);

                allocator.free(number_string);

                try numbers_line.append(allocator, number);

                continue;
            }

            if (char != ' ') {
                try current_number.append(allocator, char);
            }
        }

        if (numbers_line.items.len > 0) {
            try numbers.append(allocator, try numbers_line.toOwnedSlice(allocator));
        }
    }

    return Homework{
        .numbers = try numbers.toOwnedSlice(allocator),
        .operations = try operations.toOwnedSlice(allocator),
    };
}

fn whitespace_indexes(content: []u8, allocator: std.mem.Allocator) !std.AutoHashMap(usize, void) {
    var it = std.mem.splitSequence(u8, content, "\n");

    var indexes = std.AutoHashMap(usize, void).init(allocator);
    errdefer indexes.deinit();

    var removed_indexes = std.AutoHashMap(usize, void).init(allocator);
    defer removed_indexes.deinit();

    while (it.next()) |line| {
        if (line.len == 0) continue;

        for (line, 0..) |char, index| {
            if (char == ' ' and !removed_indexes.contains(index)) {
                try indexes.put(index, {});
            } else {
                try removed_indexes.put(index, {});
                _ = indexes.remove(index);
            }
        }
    }

    return indexes;
}

pub fn part2(content: []u8, allocator: std.mem.Allocator) !Homework {
    const lines = try number_lines(content, allocator);
    defer allocator.free(lines);
    const max_length = max_line_length(lines);

    var numbers = std.ArrayList([]usize).empty;
    errdefer numbers.deinit(allocator);

    var operations = std.ArrayList(Operation).empty;
    errdefer operations.deinit(allocator);

    var numbers_line = std.ArrayList(usize).empty;

    for (0..max_length) |index| {
        var current_number = std.ArrayList(u8).empty;

        for (lines) |line| {
            if (line.len > index) {
                const char = line[index];

                if (char == ' ') {
                    continue;
                } else if (char == '*') {
                    try operations.append(allocator, Operation.multiply);
                } else if (char == '+') {
                    try operations.append(allocator, Operation.add);
                } else {
                    try current_number.append(allocator, char);
                }
            }
        }

        if (current_number.items.len > 0) {
            const number_string = try current_number.toOwnedSlice(allocator);
            const number = try std.fmt.parseInt(usize, number_string, 10);

            allocator.free(number_string);

            try numbers_line.append(allocator, number);
        } else {
            try numbers.append(allocator, try numbers_line.toOwnedSlice(allocator));
        }
    }

    try numbers.append(allocator, try numbers_line.toOwnedSlice(allocator));

    return Homework{
        .numbers = try numbers.toOwnedSlice(allocator),
        .operations = try operations.toOwnedSlice(allocator),
    };
}

fn number_lines(content: []u8, allocator: std.mem.Allocator) ![][]const u8 {
    var lines = std.ArrayList([]const u8).empty;
    errdefer lines.deinit(allocator);

    var it = std.mem.splitSequence(u8, content, "\n");
    while (it.next()) |line| {
        if (line.len == 0) continue;

        try lines.append(allocator, line);
    }

    return lines.toOwnedSlice(allocator);
}

fn max_line_length(numbers: [][]const u8) usize {
    var max_length: usize = 0;
    for (numbers) |number| {
        if (number.len > max_length) {
            max_length = number.len;
        }
    }
    return max_length;
}
