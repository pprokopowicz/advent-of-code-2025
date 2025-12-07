const std = @import("std");
const Module = std.Build.Module;
const ResolvedTarget = std.Build.ResolvedTarget;
const OptimizeMode = std.builtin.OptimizeMode;
const Compile = std.Build.Step.Compile;

const FILE_READER_NAME = "file_reader";
const DAY01_NAME = "day01";
const DAY02_NAME = "day02";
const DAY03_NAME = "day03";
const DAY04_NAME = "day04";
const DAY05_NAME = "day05";
const DAY06_NAME = "day06";
const DAY07_NAME = "day07";

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const file_reader = create_module(b, target, optimize, FILE_READER_NAME, "src/file-reader/file_reader.zig");
    const day01 = create_module(b, target, optimize, DAY01_NAME, "src/day01/day01.zig");
    const day02 = create_module(b, target, optimize, DAY02_NAME, "src/day02/day02.zig");
    const day03 = create_module(b, target, optimize, DAY03_NAME, "src/day03/day03.zig");
    const day04 = create_module(b, target, optimize, DAY04_NAME, "src/day04/day04.zig");
    const day05 = create_module(b, target, optimize, DAY05_NAME, "src/day05/day05.zig");
    const day06 = create_module(b, target, optimize, DAY06_NAME, "src/day06/day06.zig");
    const day07 = create_module(b, target, optimize, DAY07_NAME, "src/day07/day07.zig");

    day01.addImport(FILE_READER_NAME, file_reader);
    day02.addImport(FILE_READER_NAME, file_reader);
    day03.addImport(FILE_READER_NAME, file_reader);
    day04.addImport(FILE_READER_NAME, file_reader);
    day05.addImport(FILE_READER_NAME, file_reader);
    day06.addImport(FILE_READER_NAME, file_reader);
    day07.addImport(FILE_READER_NAME, file_reader);

    const exe = executable_compile(b, target, optimize);

    exe.root_module.addImport(DAY01_NAME, day01);
    exe.root_module.addImport(DAY02_NAME, day02);
    exe.root_module.addImport(DAY03_NAME, day03);
    exe.root_module.addImport(DAY04_NAME, day04);
    exe.root_module.addImport(DAY05_NAME, day05);
    exe.root_module.addImport(DAY06_NAME, day06);
    exe.root_module.addImport(DAY07_NAME, day07);

    b.installArtifact(exe);

    add_run_step(b, exe);
}

fn create_module(
    b: *std.Build,
    target: ResolvedTarget,
    optimize: OptimizeMode,
    name: []const u8,
    path: []const u8,
) *Module {
    return b.addModule(name, .{
        .root_source_file = b.path(path),
        .target = target,
        .optimize = optimize,
    });
}

fn executable_compile(b: *std.Build, target: ResolvedTarget, optimize: OptimizeMode) *Compile {
    return b.addExecutable(.{
        .name = "AOC2025",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
}

fn add_run_step(b: *std.Build, exe: *Compile) void {
    const run_exe = b.addRunArtifact(exe);

    if (b.args) |args| {
        run_exe.addArgs(args);
    }

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}
