# Zig-WASIX
WASIX extensions for Zig ⚡. This module allows you to create programs with Wasmer & WASIX that can run on edge or be sandboxed.

**⚠️ It's still work-in-progress but it's in usable state. PRs are welcome!**

## Installation
Depend on this library in your project's `build.zig.zon`:
```ts
.{
    .name = "<your-project-name>",
    .version = "0.0.0",
    .dependencies = .{
        .wasix = .{
            .url = "https://github.com/nikneym/zig-wasix/archive/<latest-commit-hash>.tar.gz",
            .hash = "<commit-hash>",
        },
    },
}
```
In your `build` function at `build.zig`, make sure your build step and source files are aware of `zig-wasix`:
```zig
const wasix = b.dependency("wasix", .{
    .target = target,
    .optimize = optimize,
});

exe.addModule("wasix", wasix.module("wasix"));
```

## Building Projects
Now you can build your projects by targeting WASM + WASI and run on Wasmer, as the following:
```bash
zig build -Dtarget=wasm32-wasi
wasmer run zig-out/bin/<your-project>.wasm

# You may want to have networking and other stuff be enabled
wasmer run --enable-all --net zig-out/bin/<your-project>.wasm
```

## Documentation
You can refer to [wasix.org](https://wasix.org/) for documentation and further API reference.
