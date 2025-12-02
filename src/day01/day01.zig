const std = @import("std");
const file_reader = @import("file_reader");

const Rotation = union(enum) {
    left: isize,
    right: isize,
};

const Day01ParseError = error{
    InvalidRotation,
};

const start_position: isize = 50;

pub fn solve(allocator: std.mem.Allocator) !void {
    const file_name = "inputs/day01.input";

    const file_content = try file_reader.read_file(file_name, allocator);
    defer allocator.free(file_content);

    const list = try parse_content(file_content, allocator);
    defer allocator.free(list);

    std.debug.print("Day 01:\n", .{});

    solve_part1(list);
    solve_part2(list);

    std.debug.print("\n", .{});
}

fn solve_part1(list: []Rotation) void {
    var position = start_position;
    var number_of_zeros: usize = 0;

    for (list) |rotation| {
        switch (rotation) {
            .left => |value| {
                position -= @rem(value, 100);
            },
            .right => |value| {
                position += @rem(value, 100);
            },
        }

        if (position < 0) {
            position += 100;
        }

        if (position > 100) {
            position -= 100;
        }

        if (position == 100) {
            position = 0;
        }

        if (position == 0) {
            number_of_zeros += 1;
        }
    }

    std.debug.print("\tPart 1: {}\n", .{number_of_zeros});
}

fn solve_part2(list: []Rotation) void {
    var position = start_position;
    var number_of_zeros: isize = 0;

    for (list) |rotation| {
        const loop_start_position = position;

        switch (rotation) {
            .left => |value| {
                number_of_zeros += @divFloor(value, 100);
                position -= @rem(value, 100);
            },
            .right => |value| {
                number_of_zeros += @divFloor(value, 100);
                position += @rem(value, 100);
            },
        }

        if (position < 0) {
            if (loop_start_position != 0) {
                number_of_zeros += 1;
            }

            position += 100;
        }

        if (position > 100) {
            if (loop_start_position != 0) {
                number_of_zeros += 1;
            }

            position -= 100;
        }

        if (position == 100) {
            position = 0;
        }

        if (position == 0) {
            number_of_zeros += 1;
        }
    }

    std.debug.print("\tPart 2: {}\n", .{number_of_zeros});
}

fn parse_content(content: []u8, allocator: std.mem.Allocator) ![]Rotation {
    var it = std.mem.splitSequence(u8, content, "\n");
    var list = std.ArrayList(Rotation).empty;
    errdefer list.deinit(allocator);

    while (it.next()) |line| {
        if (line.len == 0) continue;

        const direction = line[0];
        const value = try std.fmt.parseInt(isize, line[1..], 10);

        switch (direction) {
            'L' => try list.append(allocator, Rotation{ .left = value }),
            'R' => try list.append(allocator, Rotation{ .right = value }),
            else => return Day01ParseError.InvalidRotation,
        }
    }

    return list.toOwnedSlice(allocator);
}
