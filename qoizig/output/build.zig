const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Library module exposing the QOI codec for programmatic use.
    const qoi_mod = b.addModule("qoizig", .{
        .root_source_file = b.path("src/qoi.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Executable target: the CLI tool.
    const exe = b.addExecutable(.{
        .name = "qoizig",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "qoizig", .module = qoi_mod },
            },
        }),
    });
    b.installArtifact(exe);

    // Run step — convenience for `zig build run -- <args>`.
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the qoizig CLI tool");
    run_step.dependOn(&run_cmd.step);

    // Unit tests for the codec library.
    const lib_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/qoi.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const run_lib_tests = b.addRunArtifact(lib_tests);

    // Unit tests for main / CLI.
    const main_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "qoizig", .module = qoi_mod },
            },
        }),
    });
    const run_main_tests = b.addRunArtifact(main_tests);

    // Unit tests for the codec (encoder + decoder integration tests).
    const codec_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/codec_test.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const run_codec_tests = b.addRunArtifact(codec_tests);

    // Unit tests for image I/O (PPM/PAM readers and writers).
    const image_io_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/image_io_test.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const run_image_io_tests = b.addRunArtifact(image_io_tests);

    // Integration tests (end-to-end pipeline).
    const integration_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/integration_test.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    const run_integration_tests = b.addRunArtifact(integration_tests);
    // Integration CLI tests depend on the exe being installed.
    run_integration_tests.step.dependOn(b.getInstallStep());

    const test_step = b.step("test", "Run all unit tests");
    test_step.dependOn(&run_lib_tests.step);
    test_step.dependOn(&run_main_tests.step);
    test_step.dependOn(&run_codec_tests.step);
    test_step.dependOn(&run_image_io_tests.step);
    test_step.dependOn(&run_integration_tests.step);
}
