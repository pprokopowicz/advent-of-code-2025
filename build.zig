const std = @import("std");
const Module = std.Build.Module;
const ResolvedTarget = std.Build.ResolvedTarget;
const OptimizeMode = std.builtin.OptimizeMode;
const Compile = std.Build.Step.Compile;

const FILE_READER_NAME = "file_reader";
const FILE_READER_PATH = "src/file-reader/file_reader.zig";

const day_names = [_][]const u8{
    "day01",
    "day02",
    "day03",
    "day04",
    "day05",
    "day06",
    "day07",
};

const day_paths = [_][]const u8{
    "src/day01/day01.zig",
    "src/day02/day02.zig",
    "src/day03/day03.zig",
    "src/day04/day04.zig",
    "src/day05/day05.zig",
    "src/day06/day06.zig",
    "src/day07/day07.zig",
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = executable_compile(b, target, optimize);

    create_day_modules(b, target, optimize, exe);

    b.installArtifact(exe);

    add_run_step(b, exe);
}

fn create_day_modules(b: *std.Build, target: (ResolvedTarget), optimize: OptimizeMode, exe: *Compile) void {
    const file_reader = create_module(b, target, optimize, FILE_READER_NAME, FILE_READER_PATH);

    for (day_names, day_paths) |name, path| {
        const module = create_module(b, target, optimize, name, path);
        module.addImport(FILE_READER_NAME, file_reader);
        exe.root_module.addImport(name, module);
    }
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
