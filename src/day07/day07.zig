const std = @import("std");
const file_reader = @import("file_reader");
const parse_content = @import("parse.zig").parse_content;
const model = @import("model.zig");
const Manifold = model.Manifold;
const Coordinates = model.Coordinates;

pub fn solve(allocator: std.mem.Allocator) !void {
    const file_name = "inputs/day07.input";

    const file_content = try file_reader.read_file(file_name, allocator);
    defer allocator.free(file_content);

    const manifold = try parse_content(file_content, allocator);
    defer {
        for (manifold.diagram) |item| {
            allocator.free(item);
        }
        allocator.free(manifold.diagram);
    }

    std.debug.print("Day 07:\n", .{});

    try solve_part1(manifold, allocator);
    try solve_part2(manifold, allocator);

    std.debug.print("\n", .{});
}

fn solve_part1(manifold: Manifold, allocator: std.mem.Allocator) !void {
    var sum: usize = 0;

    var beam_coordinates = std.AutoHashMap(Coordinates, void).init(allocator);
    defer beam_coordinates.deinit();

    try beam_coordinates.put(manifold.start, {});

    for (manifold.diagram, 0..) |locations, y| {
        var next_beam_coordinates = std.AutoHashMap(Coordinates, void).init(allocator);
        var it = beam_coordinates.keyIterator();

        while (it.next()) |coordinate| {
            const x = coordinate.x;
            const next_position = locations[x];

            switch (next_position) {
                .empty => {
                    const next = Coordinates{ .x = x, .y = y };
                    try next_beam_coordinates.put(next, {});
                },
                .splitter => {
                    const left = Coordinates{ .x = x - 1, .y = y };
                    const right = Coordinates{ .x = x + 1, .y = y };

                    try next_beam_coordinates.put(left, {});
                    try next_beam_coordinates.put(right, {});

                    sum += 1;
                },
            }
        }

        beam_coordinates.deinit();
        beam_coordinates = next_beam_coordinates;
    }

    std.debug.print("\tPart 1: {}\n", .{sum});
}

fn solve_part2(manifold: Manifold, allocator: std.mem.Allocator) !void {
    var beam_coordinates = std.AutoHashMap(Coordinates, usize).init(allocator);
    defer beam_coordinates.deinit();

    try beam_coordinates.put(manifold.start, 1);

    for (manifold.diagram, 0..) |locations, y| {
        var next_beam_coordinates = std.AutoHashMap(Coordinates, usize).init(allocator);
        var it = beam_coordinates.keyIterator();

        while (it.next()) |coordinate| {
            const x = coordinate.x;
            const next_position = locations[x];
            const current_amount = beam_coordinates.get(coordinate.*).?;

            switch (next_position) {
                .empty => {
                    const next = Coordinates{ .x = x, .y = y };

                    if (next_beam_coordinates.contains(next)) {
                        const next_amount = next_beam_coordinates.get(next).?;
                        try next_beam_coordinates.put(next, current_amount + next_amount);
                    } else {
                        try next_beam_coordinates.put(next, current_amount);
                    }
                },
                .splitter => {
                    const left = Coordinates{ .x = x - 1, .y = y };
                    const right = Coordinates{ .x = x + 1, .y = y };

                    if (next_beam_coordinates.contains(left)) {
                        const left_amount = next_beam_coordinates.get(left).?;

                        try next_beam_coordinates.put(left, current_amount + left_amount);
                    } else {
                        try next_beam_coordinates.put(left, current_amount);
                    }

                    if (next_beam_coordinates.contains(right)) {
                        const right_amount = next_beam_coordinates.get(right).?;

                        try next_beam_coordinates.put(right, current_amount + right_amount);
                    } else {
                        try next_beam_coordinates.put(right, current_amount);
                    }
                },
            }
        }

        beam_coordinates.deinit();
        beam_coordinates = next_beam_coordinates;
    }

    var sum: usize = 0;

    var it = beam_coordinates.valueIterator();
    while (it.next()) |value| {
        sum += value.*;
    }

    std.debug.print("\tPart 2: {}\n", .{sum});
}
