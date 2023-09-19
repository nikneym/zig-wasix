const std = @import("std");
const os = std.os;
const w = std.os.wasi;
const wx = @import("main.zig");

pub const Socket = enum(w.fd_t) {
    _,

    pub fn open(af: wx.AddressFamily, ty: wx.SockType, pt: wx.SockProto) os.SocketError!Socket {
        var fd: w.fd_t = -1;
        const e = wx.sock_open(af, ty, pt, &fd);

        return switch (e) {
            .SUCCESS => @enumFromInt(fd),
            .ACCES => error.PermissionDenied,
            .AFNOSUPPORT => error.AddressFamilyNotSupported,
            .INVAL => error.ProtocolFamilyNotAvailable,
            .MFILE => error.ProcessFdQuotaExceeded,
            .NFILE => error.SystemFdQuotaExceeded,
            .NOBUFS => error.SystemResources,
            .NOMEM => error.SystemResources,
            .PROTONOSUPPORT => error.ProtocolNotSupported,
            .PROTOTYPE => error.SocketTypeNotSupported,
            else => os.unexpectedErrno(e),
        };
    }

    pub fn close(socket: Socket) void {
        return os.close(@intFromEnum(socket));
    }

    pub fn bind(socket: Socket, addr: *const wx.addr_port_t) os.BindError!void {
        const e = wx.sock_bind(@intFromEnum(socket), addr);
        return switch (e) {
            .SUCCESS => {},
            .ACCES, .PERM => error.AccessDenied,
            .ADDRINUSE => error.AddressInUse,
            .BADF => unreachable, // always a race condition if this error is returned
            .INVAL => unreachable, // invalid parameters
            .NOTSOCK => unreachable, // invalid `sockfd`
            .AFNOSUPPORT => error.AddressFamilyNotSupported,
            .ADDRNOTAVAIL => error.AddressNotAvailable,
            .FAULT => unreachable, // invalid `addr` pointer
            .LOOP => error.SymLinkLoop,
            .NAMETOOLONG => error.NameTooLong,
            .NOENT => error.FileNotFound,
            .NOMEM => error.SystemResources,
            .NOTDIR => error.NotDir,
            .ROFS => error.ReadOnlyFileSystem,
            else => os.unexpectedErrno(e),
        };
    }

    pub fn listen(socket: Socket, backlog: usize) os.ListenError!void {
        const e = wx.sock_listen(@intFromEnum(socket), backlog);
        return switch (e) {
            .SUCCESS => {},
            .ADDRINUSE => error.AddressInUse,
            .BADF => unreachable,
            .NOTSOCK => error.FileDescriptorNotASocket,
            .OPNOTSUPP => error.OperationNotSupported,
            else => os.unexpectedErrno(e),
        };
    }

    pub const ConnectError = os.ConnectError || error{Interrupted};

    pub fn connect(socket: Socket, addr: *const wx.addr_port_t) ConnectError!void {
        const e = wx.sock_connect(@intFromEnum(socket), addr);

        return switch (e) {
            .SUCCESS => {},
            .ACCES => error.PermissionDenied,
            .PERM => error.PermissionDenied,
            .ADDRINUSE => error.AddressInUse,
            .ADDRNOTAVAIL => error.AddressNotAvailable,
            .AFNOSUPPORT => error.AddressFamilyNotSupported,
            .AGAIN, .INPROGRESS => error.WouldBlock,
            .ALREADY => error.ConnectionPending,
            .BADF => unreachable, // sockfd is not a valid open file descriptor.
            .CONNREFUSED => error.ConnectionRefused,
            .CONNRESET => error.ConnectionResetByPeer,
            .FAULT => unreachable, // The socket structure address is outside the user's address space.
            .INTR => error.Interrupted,
            .ISCONN => unreachable, // The socket is already connected.
            .HOSTUNREACH => error.NetworkUnreachable,
            .NETUNREACH => error.NetworkUnreachable,
            .NOTSOCK => unreachable, // The file descriptor sockfd does not refer to a socket.
            .PROTOTYPE => unreachable, // The socket type does not support the requested communications protocol.
            .TIMEDOUT => error.ConnectionTimedOut,
            .NOENT => error.FileNotFound, // Returned when socket is AF.UNIX and the given path does not exist.
            .CONNABORTED => unreachable, // Tried to reuse socket that previously received error.ConnectionRefused.
            else => os.unexpectedErrno(e),
        };
    }

    pub fn read(socket: Socket, buf: []u8) os.ReadError!usize {
        return os.read(@intFromEnum(socket), buf);
    }

    pub fn write(socket: Socket, bytes: []const u8) os.WriteError!usize {
        return os.write(@intFromEnum(socket), bytes);
    }

    pub fn readv(socket: Socket, iov: []const os.iovec) os.ReadError!usize {
        return os.readv(@intFromEnum(socket), iov);
    }

    pub fn writev(socket: Socket, iov: []const os.iovec_const) os.WriteError!usize {
        return os.writev(@intFromEnum(socket), iov);
    }

    // TODO: implement recv
    // TODO: implement send
};
