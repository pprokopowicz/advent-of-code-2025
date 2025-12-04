const std = @import("std");
const file_reader = @import("file_reader");

const Location = enum {
    empty,
    paper,
};

const Day04Error = error{
    InvalidLocation,
};

pub fn solve(allocator: std.mem.Allocator) !void {
    const file_name = "inputs/day04.input";

    const file_content = try file_reader.read_file(file_name, allocator);
    defer allocator.free(file_content);

    const list = try parse_content(file_content, allocator);
    defer {
        for (list) |item| {
            allocator.free(item);
        }
        allocator.free(list);
    }

    std.debug.print("Day 04:\n", .{});

    solve_part1(list);
    solve_part2(list);

    std.debug.print("\n", .{});
}

fn solve_part1(list: [][]Location) void {
    var sum: usize = 0;
    const max_y: usize = list.len - 1;
    const max_x = list[0].len - 1;

    for (list, 0..) |line, y| {
        for (line, 0..) |location, x| {
            switch (location) {
                Location.empty => continue,
                Location.paper => {
                    if (is_location_accessible(list, x, y, max_x, max_y)) {
                        sum += 1;
                    }
                },
            }
        }
    }

    std.debug.print("\tPart 1: {}\n", .{sum});
}

fn solve_part2(list: [][]Location) void {
    var modified_list = list;
    var removed_paper: bool = true;
    var sum: usize = 0;

    const max_y: usize = list.len - 1;
    const max_x = list[0].len - 1;

    while (removed_paper) {
        removed_paper = false;

        for (modified_list, 0..) |line, y| {
            for (line, 0..) |location, x| {
                switch (location) {
                    Location.empty => continue,
                    Location.paper => {
                        if (is_location_accessible(modified_list, x, y, max_x, max_y)) {
                            modified_list[y][x] = Location.empty;
                            removed_paper = true;
                            sum += 1;
                        }
                    },
                }
            }
        }
    }

    std.debug.print("\tPart 2: {}\n", .{sum});
}

fn is_location_accessible(list: [][]Location, x: usize, y: usize, max_x: usize, max_y: usize) bool {
    var number_of_papers: usize = 0;

    if (y > 0) {
        if (list[y - 1][x] == Location.paper) {
            number_of_papers += 1;
        }

        if (x > 0) {
            if (list[y - 1][x - 1] == Location.paper) {
                number_of_papers += 1;
            }
        }

        if (x + 1 <= max_x) {
            if (list[y - 1][x + 1] == Location.paper) {
                number_of_papers += 1;
            }
        }
    }

    if (x > 0) {
        if (list[y][x - 1] == Location.paper) {
            number_of_papers += 1;
        }
    }

    if (x + 1 <= max_x) {
        if (list[y][x + 1] == Location.paper) {
            number_of_papers += 1;
        }
    }

    if (y + 1 <= max_y) {
        if (list[y + 1][x] == Location.paper) {
            number_of_papers += 1;
        }

        if (x > 0) {
            if (list[y + 1][x - 1] == Location.paper) {
                number_of_papers += 1;
            }
        }

        if (x + 1 <= max_x) {
            if (list[y + 1][x + 1] == Location.paper) {
                number_of_papers += 1;
            }
        }
    }

    return number_of_papers < 4;
}

fn parse_content(content: []u8, allocator: std.mem.Allocator) ![][]Location {
    var it = std.mem.splitSequence(u8, content, "\n");

    var list = std.ArrayList([]Location).empty;
    errdefer list.deinit(allocator);

    while (it.next()) |line| {
        if (line.len == 0) continue;

        var locations = std.ArrayList(Location).empty;
        errdefer locations.deinit(allocator);

        for (line) |location| {
            if (location == '.') {
                try locations.append(allocator, Location.empty);
            } else if (location == '@') {
                try locations.append(allocator, Location.paper);
            } else {
                return Day04Error.InvalidLocation;
            }
        }

        const slice = try locations.toOwnedSlice(allocator);
        try list.append(allocator, slice);
    }

    return list.toOwnedSlice(allocator);
}
