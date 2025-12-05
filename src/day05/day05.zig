const std = @import("std");
const file_reader = @import("file_reader");

const Database = struct {
    id_ranges: []Range,
    available_ids: []usize,
};

const Range = struct {
    lower_bound: usize,
    upper_bound: usize,
};

const Day05Error = error{
    NoLowerBound,
    NoUpperBound,
};

pub fn solve(allocator: std.mem.Allocator) !void {
    const file_name = "inputs/day05.input";

    const file_content = try file_reader.read_file(file_name, allocator);
    defer allocator.free(file_content);

    const database = try parse_content(file_content, allocator);
    defer {
        allocator.free(database.available_ids);
        allocator.free(database.id_ranges);
    }

    std.debug.print("Day 05:\n", .{});

    solve_part1(database);
    try solve_part2(database, allocator);

    std.debug.print("\n", .{});
}

fn solve_part1(database: Database) void {
    var number_of_available_ids: usize = 0;

    for (database.available_ids) |id| {
        for (database.id_ranges) |range| {
            if (contains(id, range)) {
                number_of_available_ids += 1;
                break;
            }
        }
    }

    std.debug.print("\tPart 1: {}\n", .{number_of_available_ids});
}

fn solve_part2(database: Database, allocator: std.mem.Allocator) !void {
    var number_of_available_ids: usize = 0;

    var modified_ranges = std.ArrayList(Range).empty;
    defer modified_ranges.deinit(allocator);

    for (database.id_ranges, 0..) |range, index| {
        var modified_range: Range = Range{
            .lower_bound = range.lower_bound,
            .upper_bound = range.upper_bound,
        };
        var append: bool = true;

        for (database.id_ranges[index + 1 ..]) |inner_range| {
            if (contains(modified_range.lower_bound, inner_range) and contains(modified_range.upper_bound, inner_range)) {
                append = false;
                break;
            } else if (contains(modified_range.lower_bound, inner_range) and modified_range.upper_bound > inner_range.upper_bound) {
                modified_range.lower_bound = inner_range.upper_bound + 1;
            } else if (contains(modified_range.upper_bound, inner_range) and modified_range.lower_bound < inner_range.lower_bound) {
                modified_range.upper_bound = inner_range.lower_bound - 1;
            }
        }

        if (append) {
            for (modified_ranges.items) |inner_range| {
                if (contains(modified_range.lower_bound, inner_range) and contains(modified_range.upper_bound, inner_range)) {
                    append = false;
                    break;
                }
            }
        }

        if (append) {
            try modified_ranges.append(allocator, modified_range);
        }
    }

    for (modified_ranges.items) |range| {
        number_of_available_ids += range.upper_bound - range.lower_bound + 1;
    }

    std.debug.print("\tPart 2: {}\n", .{number_of_available_ids});
}

fn contains(number: usize, range: Range) bool {
    return number >= range.lower_bound and number <= range.upper_bound;
}

fn parse_content(content: []u8, allocator: std.mem.Allocator) !Database {
    var it = std.mem.splitSequence(u8, content, "\n");

    var ranges = std.ArrayList(Range).empty;
    errdefer ranges.deinit(allocator);

    var available_ids = std.ArrayList(usize).empty;
    errdefer available_ids.deinit(allocator);

    while (it.next()) |line| {
        if (line.len == 0) continue;

        const index = std.mem.indexOf(u8, line, "-");

        if (index) |_| {
            const range = try parse_range(line);
            try ranges.append(allocator, range);
        } else {
            const id = try parse_id(line);
            try available_ids.append(allocator, id);
        }
    }

    const database = Database{
        .id_ranges = try ranges.toOwnedSlice(allocator),
        .available_ids = try available_ids.toOwnedSlice(allocator),
    };

    return database;
}

fn parse_range(range: []const u8) !Range {
    var parts = std.mem.splitSequence(u8, range, "-");

    const lower_bound_text = parts.next() orelse return Day05Error.NoLowerBound;
    const upper_bound_text = parts.next() orelse return Day05Error.NoUpperBound;

    const lower_bound = try std.fmt.parseInt(usize, lower_bound_text, 10);
    const upper_bound = try std.fmt.parseInt(usize, upper_bound_text, 10);

    return Range{
        .lower_bound = lower_bound,
        .upper_bound = upper_bound,
    };
}

fn parse_id(id: []const u8) !usize {
    const value = try std.fmt.parseInt(usize, id, 10);

    return value;
}
