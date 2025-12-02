const std = @import("std");
const Module = std.Build.Module;
const ResolvedTarget = std.Build.ResolvedTarget;
const OptimizeMode = std.builtin.OptimizeMode;
const Compile = std.Build.Step.Compile;

const FILE_READER_NAME = "file_reader";
const DAY01_NAME = "day01";
const DAY02_NAME = "day02";

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const file_reader = create_module(b, target, optimize, FILE_READER_NAME, "src/file-reader/file_reader.zig");
    const day01 = create_module(b, target, optimize, DAY01_NAME, "src/day01/day01.zig");
    const day02 = create_module(b, target, optimize, DAY02_NAME, "src/day02/day02.zig");

    day01.addImport(FILE_READER_NAME, file_reader);
    day02.addImport(FILE_READER_NAME, file_reader);

    const exe = executable_compile(b, target, optimize);

    exe.root_module.addImport(DAY01_NAME, day01);
    exe.root_module.addImport(DAY02_NAME, day02);

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
