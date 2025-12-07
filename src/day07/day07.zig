const std = @import("std");
const file_reader = @import("file_reader");

const Location = enum {
    empty,
    splitter,
};

const Coordinates = struct {
    x: usize,
    y: usize,
};

const Manifold = struct {
    diagram: [][]Location,
    start: Coordinates,
};

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
    solve_part2();

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

fn solve_part2() void {
    // std.debug.print("\tPart 2: {}\n", .{sum});
}

fn parse_content(content: []u8, allocator: std.mem.Allocator) !Manifold {
    var it = std.mem.splitSequence(u8, content, "\n");

    var diagram = std.ArrayList([]Location).empty;
    errdefer diagram.deinit(allocator);

    var start_coordinates = Coordinates{ .x = 0, .y = 0 };

    var current_y: usize = 0;

    while (it.next()) |line| : (current_y += 1) {
        if (line.len == 0) continue;

        var locations = std.ArrayList(Location).empty;
        errdefer locations.deinit(allocator);

        for (line, 0..) |char, x| {
            if (char == '.') {
                try locations.append(allocator, Location.empty);
            } else if (char == '^') {
                try locations.append(allocator, Location.splitter);
            } else if (char == 'S') {
                start_coordinates = Coordinates{ .x = x, .y = current_y };
            }
        }

        const slice = try locations.toOwnedSlice(allocator);
        try diagram.append(allocator, slice);
    }

    return Manifold{
        .diagram = try diagram.toOwnedSlice(allocator),
        .start = start_coordinates,
    };
}
