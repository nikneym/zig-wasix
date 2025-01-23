const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    // Expose zig-wasix as a module.
    _ = b.addModule("wasix", .{
        .root_source_file = b.path("src/root.zig"),
        .imports = &.{},
    });

    // In order to test, we output a .wasm file that can be run with wasmer.
    // zig build -Dtarget=wasm32-wasi
    const main_tests = b.addExecutable(.{
        .name = "wasix-test",
        .root_source_file = b.path("src/test.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(main_tests);
}
