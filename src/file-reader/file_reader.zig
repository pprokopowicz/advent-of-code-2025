const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const log = std.log;

pub fn read_file(file_path: []const u8, allocator: mem.Allocator) ![]u8 {
    errdefer log.warn("Failed to load file data at path: {s}", .{file_path});

    var file = try fs.cwd().openFile(file_path, .{});
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);

    _ = try file.readAll(buffer);

    return buffer;
}
