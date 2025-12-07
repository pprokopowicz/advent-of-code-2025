const std = @import("std");
const model = @import("model.zig");
const Manifold = model.Manifold;
const Location = model.Location;
const Coordinates = model.Coordinates;

pub fn parse_content(content: []u8, allocator: std.mem.Allocator) !Manifold {
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
