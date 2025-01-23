// we can't use test blocks since the tests are going to be run by wasmer executable
const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;
const os = std.os;
const w = std.os.wasi;
const wx = @import("root.zig");

// TODO: add more tests
pub fn main() !void {
    try testSocketsAndEpoll();
    try testDnsResolver();
}

fn testSocketsAndEpoll() !void {
    // Create an epoll instance
    var epfd: w.fd_t = -1;
    var err = wx.epoll_create(&epfd);
    assert(err == .SUCCESS);
    defer {
        err = w.fd_close(epfd);
        assert(err == .SUCCESS);
    }

    // Create a listener socket
    var server_fd: w.fd_t = -1;
    err = wx.sock_open(.inet4, .stream, .tcp, &server_fd);
    assert(err == .SUCCESS);
    defer {
        err = w.fd_close(server_fd);
        assert(err == .SUCCESS);
    }

    // Bind the server socket
    const server_addr_port = &wx.addr_port_t{
        .tag = .inet4,
        .u = .{
            .inet4 = .{
                .port = 6666,
                .addr = .{
                    .n0 = 127,
                    .n1 = 0,
                    .h0 = 0,
                    .h1 = 1,
                },
            },
        },
    };

    err = wx.sock_bind(server_fd, server_addr_port);
    assert(err == .SUCCESS);

    // Listen for incoming connections
    err = wx.sock_listen(server_fd, 128);
    assert(err == .SUCCESS);

    // Register the server fd to epoll
    err = wx.epoll_ctl(epfd, wx.CTL.ADD, server_fd, &.{
        .data = .{ .ptr = null, .fd = server_fd, .data1 = 0, .data2 = 0 },
        // Only watch for read events
        .events = wx.EPOLL.IN,
    });
    assert(err == .SUCCESS);

    // Create a client socket
    var client_fd: w.fd_t = -1;
    err = wx.sock_open(.inet4, .stream, .tcp, &client_fd);
    assert(err == .SUCCESS);
    defer {
        err = w.fd_close(client_fd);
        assert(err == .SUCCESS);
    }

    // Connect to server
    const client_addr_port = &wx.addr_port_t{
        .tag = .inet4,
        .u = .{
            .inet4 = .{
                .port = 6666,
                .addr = .{
                    .n0 = 127,
                    .n1 = 0,
                    .h0 = 0,
                    .h1 = 1,
                },
            },
        },
    };

    err = wx.sock_connect(client_fd, client_addr_port);
    assert(err == .SUCCESS);

    // We should get a single notification from epoll right now
    {
        var events: [1]wx.epoll_event_t = undefined;
        var ret_events: usize = 0;

        err = wx.epoll_wait(epfd, @ptrCast(&events), events.len, 0, &ret_events);
        assert(err == .SUCCESS);
        try testing.expectEqual(1, ret_events);

        const event = events[0];

        // We should only get an EPOLLIN event
        try testing.expectEqual(true, event.events & wx.EPOLL.IN == wx.EPOLL.IN);

        // Accept the incoming connection, set the SOCK_NONBLOCK flag
        var incoming_fd: w.fd_t = -1;
        err = w.sock_accept(server_fd, .{ .NONBLOCK = true }, &incoming_fd);
        assert(err == .SUCCESS);

        try testing.expect(incoming_fd != -1);

        // Add the accepted socket to epoll watch list
        err = wx.epoll_ctl(epfd, wx.CTL.ADD, incoming_fd, &.{
            .data = .{ .ptr = null, .fd = incoming_fd, .data1 = 0, .data2 = 0 },
            // Watch for read and write events
            .events = wx.EPOLL.IN,
        });
        assert(err == .SUCCESS);
    }

    // Send a message from client to server
    {
        const buf = "hello";
        const iovec = &w.iovec_t{ .base = @ptrCast(@constCast(buf.ptr)), .len = buf.len };
        var sent_len: usize = 0;

        err = w.sock_send(client_fd, @ptrCast(iovec), 1, 0, &sent_len);
        assert(err == .SUCCESS);

        try testing.expectEqual(buf.len, sent_len);
    }
}

fn testDnsResolver() !void {
    // Do a DNS resolution
    const host = "www.google.com";
    var results: [1]wx.addr_t = undefined;
    var results_len: usize = 0;

    const err = wx.resolve(host.ptr, host.len, 80, @ptrCast(&results), 1, &results_len);
    assert(err == .SUCCESS);
}
