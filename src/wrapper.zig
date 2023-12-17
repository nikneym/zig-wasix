const std = @import("std");
const os = std.os;
const w = std.os.wasi;
const wx = @import("main.zig");

/// High level wrappers for WASIX socket utilities.
pub const Socket = enum(w.fd_t) {
    _,

    /// Creates a new socket descriptor.
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

    /// Closes the socket descriptor.
    pub fn close(socket: Socket) void {
        return os.close(@intFromEnum(socket));
    }

    /// Binds the underlying socket to a local address.
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

    /// Sets the socket to listen mode, can accept incoming connections.
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

    /// Connects the socket to given address.
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

    /// Returns the number of bytes that were read, which can be less than
    /// buf.len. If 0 bytes were read, that means EOF.
    /// If socket is opened in non blocking mode, the function will return error.WouldBlock
    /// when EAGAIN is received.
    pub fn read(socket: Socket, buf: []u8) os.ReadError!usize {
        return os.read(@intFromEnum(socket), buf);
    }

    /// Writes to a socket.
    /// Retries when interrupted by a signal.
    /// Returns the number of bytes written. If nonzero bytes were supplied, this will be nonzero.
    pub fn write(socket: Socket, bytes: []const u8) os.WriteError!usize {
        return os.write(@intFromEnum(socket), bytes);
    }

    /// Reads from the socket to the given vectors.
    /// This is useful if read sizes are known beforehand.
    /// Returns the number of bytes that were read, which can be less than
    /// buf.len. If 0 bytes were read, that means EOF.
    /// If socket is opened in non blocking mode, the function will return error.WouldBlock
    /// when EAGAIN is received.
    pub fn readv(socket: Socket, iov: []const os.iovec) os.ReadError!usize {
        return os.readv(@intFromEnum(socket), iov);
    }

    /// Writes to a socket in the order of given vectors.
    /// This is useful since less `write` syscalls are used with vectored I/O.
    /// Retries when interrupted by a signal.
    /// Returns the number of bytes written. If nonzero bytes were supplied, this will be nonzero.
    pub fn writev(socket: Socket, iov: []const os.iovec_const) os.WriteError!usize {
        return os.writev(@intFromEnum(socket), iov);
    }

    // TODO: implement recv
    // TODO: implement send
};

pub const Dns = struct {
    pub fn resolve(host: []const u8, port: u16, addrs: []wx.addr_t) !usize {
        var naddrs: usize = 0;
        const e = wx.resolve(host.ptr, host.len, port, addrs.ptr, addrs.len, &naddrs);

        return switch (e) {
            .SUCCESS => naddrs,
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
};
