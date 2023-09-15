const std = @import("std");
const w = std.os.wasi;
const wx = @import("main.zig");

pub fn main() !void {
    var fd: w.fd_t = -1;
    var e = wx.sock_open(2, 1, 6, &fd);
    if (e != .SUCCESS)
        @panic("failed!");

    e = wx.sock_bind(fd, &.{
        .tag = .inet4,
        .u = .{
            .inet4 = .{
                .addr = .{ .n0 = 127, .n1 = 0, .h0 = 0, .h1 = 1 },
                .port = 8080,
            },
        },
    });

    if (e != .SUCCESS)
        std.debug.panic("error: {}\n", .{e});
}
