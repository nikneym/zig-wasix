# Zig-WASIX
WASIX extensions for Zig ⚡. This module let's you to create programs with Wasmer & WASIX that can run on edge or be sandboxed.

## Installation
Install via Zig package manager (Copy the full SHA of latest commit hash from GitHub):
```sh
zig fetch --save https://github.com/nikneym/zig-wasix/archive/<latest-commit-hash>.tar.gz
```
In your `build` function at `build.zig`, make sure your build step and source files are aware of the module:
```zig
const dep_opts = .{ .target = target, .optimize = optimize };

const wasix_dep = b.dependency("wasix", dep_opts);
const wasix_module = wasix_dep.module("wasix");

exe_mod.addImport("wasix", wasix_module);
```

## Building Projects
Now you can build your projects by targeting WASM & WASI and run on Wasmer, as the following:
```sh
zig build -Dtarget=wasm32-wasi
wasmer run zig-out/bin/<your-project>.wasm

# You may want to have networking and other stuff be enabled
wasmer run --enable-all --net zig-out/bin/<your-project>.wasm
```

## Documentation
You can refer to [wasix.org](https://wasix.org/) for documentation and further API reference.
