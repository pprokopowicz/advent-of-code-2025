const std = @import("std");
const file_reader = @import("file_reader");
const parse_content = @import("parse.zig");
const model = @import("model.zig");
const Homework = model.Homework;

pub fn solve(allocator: std.mem.Allocator) !void {
    const file_name = "inputs/day06.input";

    const file_content = try file_reader.read_file(file_name, allocator);
    defer allocator.free(file_content);

    const homework = try parse_content.part1(file_content, allocator);
    defer {
        for (homework.numbers) |number_line| {
            allocator.free(number_line);
        }
        allocator.free(homework.numbers);
        allocator.free(homework.operations);
    }

    const homework2 = try parse_content.part2(file_content, allocator);
    defer {
        for (homework2.numbers) |number_line| {
            allocator.free(number_line);
        }
        allocator.free(homework2.numbers);
        allocator.free(homework2.operations);
    }

    std.debug.print("Day 06:\n", .{});

    solve_part1(homework);
    solve_part2(homework2);

    std.debug.print("\n", .{});
}

fn solve_part1(homework: Homework) void {
    var sum: usize = 0;

    for (0..homework.operations.len) |x_index| {
        const operation = homework.operations[x_index];
        var result: usize = switch (operation) {
            .add => 0,
            .multiply => 1,
        };

        for (0..homework.numbers.len) |y_index| {
            switch (operation) {
                .add => result += homework.numbers[y_index][x_index],
                .multiply => result *= homework.numbers[y_index][x_index],
            }
        }

        sum += result;
    }

    std.debug.print("\tPart 1: {}\n", .{sum});
}

fn solve_part2(homework: Homework) void {
    var sum: usize = 0;

    for (0..homework.numbers.len) |index| {
        const numbers = homework.numbers[index];
        const operation = homework.operations[index];
        var result: usize = switch (operation) {
            .add => 0,
            .multiply => 1,
        };

        for (numbers) |number| {
            switch (operation) {
                .add => result += number,
                .multiply => result *= number,
            }
        }

        sum += result;
    }

    std.debug.print("\tPart 2: {}\n", .{sum});
}
