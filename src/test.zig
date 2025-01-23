const std = @import("std");
const os = std.os;
const w = std.os.wasi;
const wx = @import("root.zig");

pub fn main() !void {
    // setup epoll fd
    var epfd: w.fd_t = -1;
    var err = wx.epoll_create(&epfd);
    if (err != w.errno_t.SUCCESS) {
        std.debug.print("{}\n", .{err});
        return;
    }
    defer _ = w.fd_close(epfd);

    // setup socket
    var sockfd: w.fd_t = -1;
    err = wx.sock_open(.inet4, .stream, .tcp, &sockfd);
    if (err != w.errno_t.SUCCESS) {
        std.debug.print("{}\n", .{err});
        return;
    }
    defer _ = w.fd_close(sockfd);
    std.debug.print("{}\n", .{err});

    // bind
    err = wx.sock_bind(sockfd, &.{
        .tag = .inet4,
        .u = .{
            .inet4 = .{
                .port = 8081,
                .addr = .{
                    .n0 = 127,
                    .n1 = 0,
                    .h0 = 0,
                    .h1 = 1,
                },
            },
        },
    });

    // listen
    err = wx.sock_listen(sockfd, 128);
    if (err != w.errno_t.SUCCESS) {
        std.debug.print("{}\n", .{err});
        return;
    }
    std.debug.print("{}\n", .{err});

    err = wx.epoll_ctl(epfd, wx.CTL.ADD, sockfd, &.{
        .data = .{ .ptr = null, .fd = sockfd, .data1 = 0, .data2 = 0 },
        .events = wx.EPOLL.IN,
    });
    if (err != w.errno_t.SUCCESS) {
        std.debug.print("{}\n", .{err});
        return;
    }
    std.debug.print("epoll_ctl: {}\n", .{err});

    var events: [128]wx.epoll_event_t = undefined;
    var count: usize = 0;

    while (true) {
        err = wx.epoll_wait(epfd, &events, events.len, 0, &count);
        if (err != w.errno_t.SUCCESS) {
            //std.debug.print("{}\n", .{err});
        }

        for (events[0..count]) |event| {
            if (event.events & wx.EPOLL.IN != 0) {
                if (event.data.fd == sockfd) {
                    std.debug.print("got connection\n", .{});

                    var client_fd: w.fd_t = -1;
                    _ = w.sock_accept(sockfd, .{ .NONBLOCK = true }, &client_fd);

                    std.debug.print("{}\n", .{client_fd});
                    err = wx.epoll_ctl(epfd, wx.CTL.ADD, client_fd, &.{
                        .data = .{ .ptr = null, .fd = client_fd, .data1 = 0, .data2 = 0 },
                        .events = wx.EPOLL.IN | wx.EPOLL.OUT,
                    });
                    if (err != w.errno_t.SUCCESS) {
                        std.debug.print("{}\n", .{err});
                        return;
                    }
                    std.debug.print("epoll_ctl: {}\n", .{err});
                } else {
                    // client
                    var buf: [1024]u8 = undefined;
                    var vec = w.iovec_t{ .base = &buf, .len = buf.len };
                    var ro_datalen: usize = 0;
                    var ro_flags: u16 = 0;

                    var so_datalen: usize = 0;

                    _ = w.sock_recv(event.data.fd, @ptrCast(&vec), 1, 0, &ro_datalen, &ro_flags);
                    _ = w.sock_send(event.data.fd, @ptrCast(&vec), 1, 0, &so_datalen);
                }
            }
        }
    }
}
