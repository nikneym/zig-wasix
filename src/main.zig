const std = @import("std");
const os = std.os;
const w = os.wasi;

pub const bool_t = u8;

pub const pointersize_t = u32;

pub const address_family_t = u8;

pub const ip_port_t = u16;

pub const sock_type_t = u8;

pub const sock_proto_t = u16;

pub const sock_option_t = u8;

pub const epoll_ctl_t = u32;

pub const CTL = enum(epoll_ctl_t) {
    ADD = 0,
    MOD = 1,
    DEL = 2,
};

pub const epoll_type_t = u32;

pub const EPOLL = enum(epoll_type_t) {
    IN = 1 << 0,
    OUT = 1 << 1,
    RDHUP = 1 << 2,
    PRI = 1 << 3,
    ERR = 1 << 4,
    HUP = 1 << 5,
    ET = 1 << 6,
    ONESHOT = 1 << 7,
};

// this is actually defined as union on Linux
pub const epoll_data_t = extern struct {
    ptr: pointersize_t,
    fd: w.fd_t,
    data1: u32,
    data2: u64,
};

pub const epoll_event_t = extern struct {
    events: epoll_type_t,
    data: epoll_data_t,
};

pub const http_handles_t = extern struct {
    request: w.fd_t,
    response: w.fd_t,
    headers: w.fd_t,
};

const option_timestamp_u_t = extern union {
    none: u8,
    some: w.timestamp_t,
};

const option_timestamp_t = extern struct {
    tag: enum(u8) {
        none = 0,
        some = 1,
    },
    u: option_timestamp_u_t,
};

// An IPv4 address is a 32-bit number that uniquely identifies a network interface on a machine.
const addr_ip4_t = extern struct {
    n0: u8,
    n1: u8,
    h0: u8,
    h1: u8,
};

// An IPv6 address is a 128-bit number that uniquely identifies a network interface on a machine.
const addr_ip6_t = extern struct {
    n0: u16,
    n1: u16,
    n2: u16,
    n3: u16,
    h0: u16,
    h1: u16,
    h2: u16,
    h3: u16,
    // flow_info1 contains the most significant two bytes, and comes first in keeping with all wasix syscalls being little endian
    flow_info1: u16,
    // flow_info0 contains the least significant two bytes
    flow_info0: u16,
    // Same as flow_info1 and flow_info0
    scope_id1: u16,
    scope_id0: u16,
};

pub const addr_unspec_t = extern struct {
    n0: u8,
};

pub const addr_unspec_port_t = extern struct {
    port: ip_port_t,
    addr: addr_unspec_t,
};

pub const addr_ip4_port_t = extern struct {
    port: ip_port_t,
    addr: addr_ip4_t,
};

pub const addr_ip6_port_t = extern struct {
    port: ip_port_t,
    addr: addr_ip6_t,
};

// Unix socket that is bound to no more than 107 bytes
pub const addr_unix_t = extern struct {
    b0: u8,
    b1: u8,
    b2: u8,
    b3: u8,
    b4: u8,
    b5: u8,
    b6: u8,
    b7: u8,
    b8: u8,
    b9: u8,
    b10: u8,
    b11: u8,
    b12: u8,
    b13: u8,
    b14: u8,
    b15: u8,
    b16: u8,
    b17: u8,
    b18: u8,
    b19: u8,
    b20: u8,
    b21: u8,
    b22: u8,
    b23: u8,
    b24: u8,
    b25: u8,
    b26: u8,
    b27: u8,
    b28: u8,
    b29: u8,
    b30: u8,
    b31: u8,
    b32: u8,
    b33: u8,
    b34: u8,
    b35: u8,
    b36: u8,
    b37: u8,
    b38: u8,
    b39: u8,
    b40: u8,
    b41: u8,
    b42: u8,
    b43: u8,
    b44: u8,
    b45: u8,
    b46: u8,
    b47: u8,
    b48: u8,
    b49: u8,
    b50: u8,
    b51: u8,
    b52: u8,
    b53: u8,
    b54: u8,
    b55: u8,
    b56: u8,
    b57: u8,
    b58: u8,
    b59: u8,
    b60: u8,
    b61: u8,
    b62: u8,
    b63: u8,
    b64: u8,
    b65: u8,
    b66: u8,
    b67: u8,
    b68: u8,
    b69: u8,
    b70: u8,
    b71: u8,
    b72: u8,
    b73: u8,
    b74: u8,
    b75: u8,
    b76: u8,
    b77: u8,
    b78: u8,
    b79: u8,
    b80: u8,
    b81: u8,
    b82: u8,
    b83: u8,
    b84: u8,
    b85: u8,
    b86: u8,
    b87: u8,
    b88: u8,
    b89: u8,
    b90: u8,
    b91: u8,
    b92: u8,
    b93: u8,
    b94: u8,
    b95: u8,
    b96: u8,
    b97: u8,
    b98: u8,
    b99: u8,
    b100: u8,
    b101: u8,
    b102: u8,
    b103: u8,
    b104: u8,
    b105: u8,
    b106: u8,
    b107: u8,
};

pub const addr_port_u_t = extern union {
    unspec: addr_unspec_port_t,
    inet4: addr_ip4_port_t,
    inet6: addr_ip6_port_t,
    unix: addr_unix_t,
};

pub const addr_port_t = extern struct {
    tag: enum(u8) {
        unspec = 0,
        inet4 = 1,
        inet6 = 2,
        unix = 3,
    },
    u: addr_port_u_t,
};

pub const addr_u_t = extern union {
    unspec: addr_unspec_port_t,
    inet4: addr_ip4_port_t,
    inet6: addr_ip6_port_t,
    unix: addr_unix_t,
};

pub const addr_t = extern struct {
    tag: enum(u8) {
        unspec = 0,
        inet4 = 1,
        inet6 = 2,
        unix = 3,
    },
    u: addr_u_t,
};

pub const tty_t = extern struct {
    height: u32,
    stdin_tty: bool_t,
    stdout_tty: bool_t,
    stderr_tty: bool_t,
    echo: bool_t,
    line_buffered: bool_t,
    line_feeds: bool_t,
};

pub const tid_t = i32;

pub const thread_start_t = extern struct {
    // address where the stack starts
    stack: pointersize_t,

    // Address where the TLS starts
    tls_base: pointersize_t,

    // Function that will be invoked when the thread starts
    start_funct: pointersize_t,

    // Arguments to pass the callback function
    start_args: pointersize_t,

    // Reserved for future WASI usage
    reserved0: pointersize_t,
    reserved1: pointersize_t,
    reserved2: pointersize_t,
    reserved3: pointersize_t,
    reserved4: pointersize_t,
    reserved5: pointersize_t,
    reserved6: pointersize_t,
    reserved7: pointersize_t,
    reserved8: pointersize_t,
    reserved9: pointersize_t,

    // The size of the stack
    stack_size: pointersize_t,

    // The size of the guards at the end of the stack
    guard_size: pointersize_t,
};

// clock
pub extern "wasix_32v1" fn clock_time_set(id: w.clockid_t, timestamp: w.timestamp_t) w.errno_t;

// file descriptor
pub extern "wasix_32v1" fn fd_dup(id: w.fd_t, ret_fd: *w.fd_t) w.errno_t;
pub extern "wasix_32v1" fn fd_event(initial_val: u64, flags: w.eventrwflags_t, ret_fd: *w.fd_t) w.errno_t;
pub extern "wasix_32v1" fn fd_pipe(fd1: w.fd_t, fd2: w.fd_t) w.errno_t;

// tty
pub extern "wasix_32v1" fn tty_get(state: *tty_t) w.errno_t;
pub extern "wasix_32v1" fn tty_set(state: *tty_t) w.errno_t;

// directory
pub extern "wasix_32v1" fn getcwd(buf: [*]u8, path_len: *pointersize_t) w.errno_t;
pub extern "wasix_32v1" fn chdir(path: [*:0]const u8, path_len: usize) w.errno_t;

// signal handling
pub extern "wasix_32v1" fn callback_signal(callback: [*:0]const u8, callback_len: usize) void;

// threading
pub extern "wasix_32v1" fn thread_spawn_v2(start_ptr: *thread_start_t, ret_tid: *tid_t) w.errno_t;
pub extern "wasix_32v1" fn thread_sleep(duration: w.timestamp_t) w.errno_t;
pub extern "wasix_32v1" fn thread_id(ret_tid: *tid_t) w.errno_t;
pub extern "wasix_32v1" fn thread_join(tid: tid_t) w.errno_t;
pub extern "wasix_32v1" fn thread_parallelism(ret_parallelism: *usize) w.errno_t;
pub extern "wasix_32v1" fn thread_signal(tid: tid_t, signal: w.signal_t) w.errno_t;
// TODO: add futex functions here
pub extern "wasix_32v1" fn thread_exit(rval: w.exitcode_t) noreturn;
// TODO: add stack functions here

// socket
pub extern "wasix_32v1" fn sock_open(af: address_family_t, ty: sock_type_t, pt: sock_proto_t, ro_sock: *w.fd_t) w.errno_t;
pub extern "wasix_32v1" fn sock_set_opt_flag(sock: w.fd_t, opt: sock_option_t, flag: bool_t) w.errno_t;
pub extern "wasix_32v1" fn sock_get_opt_flag(sock: w.fd_t, opt: sock_option_t, ret_flag: *bool_t) w.errno_t;
pub extern "wasix_32v1" fn sock_set_opt_time(sock: w.fd_t, opt: sock_option_t, time: *const option_timestamp_t) w.errno_t;
pub extern "wasix_32v1" fn sock_get_opt_time(sock: w.fd_t, opt: sock_option_t, ret_time: *option_timestamp_t) w.errno_t;
pub extern "wasix_32v1" fn sock_set_opt_size(sock: w.fd_t, opt: sock_option_t, size: w.filesize_t) w.errno_t;
pub extern "wasix_32v1" fn sock_get_opt_size(sock: w.fd_t, opt: sock_option_t, ret_size: w.filesize_t) w.errno_t;
pub extern "wasix_32v1" fn sock_join_multicast_v4(sock: w.fd_t, multiaddr: *const addr_ip4_t, iface: *const addr_ip4_t) w.errno_t;
pub extern "wasix_32v1" fn sock_leave_multicast_v4(sock: w.fd_t, multiaddr: *const addr_ip4_t, iface: *const addr_ip4_t) w.errno_t;
pub extern "wasix_32v1" fn sock_join_multicast_v6(sock: w.fd_t, multiaddr: *const addr_ip6_t, iface: u32) w.errno_t;
pub extern "wasix_32v1" fn sock_leave_multicast_v6(sock: w.fd_t, multiaddr: *const addr_ip6_t, iface: u32) w.errno_t;
pub extern "wasix_32v1" fn sock_bind(sock: w.fd_t, addr: *addr_port_t) w.errno_t;
pub extern "wasix_32v1" fn sock_listen(sock: w.fd_t, backlog: usize) w.errno_t;
pub extern "wasix_32v1" fn sock_accept_v2(sock: w.fd_t, fd_flags: w.fdflags_t, ro_fd: *w.fd_t, ro_addr: *addr_port_t) w.errno_t;
pub extern "wasix_32v1" fn sock_connect(sock: w.fd_t, addr: *const addr_port_t) w.errno_t;
// TODO: implement more sock functions

// DNS resolution
pub extern "wasix_32v1" fn resolve(host: [*]const u8, host_len: usize, port: u16, addrs: [*]addr_t, naddrs: usize, ret_naddrs: *usize) w.errno_t;

// epoll
pub extern "wasix_32v1" fn epoll_create(ret_fd: *w.fd_t) w.errno_t;
pub extern "wasix_32v1" fn epoll_ctl(epfd: w.fd_t, op: epoll_ctl_t, fd: w.fd_t, event: *const epoll_event_t) w.errno_t;
pub extern "wasix_32v1" fn epoll_wait(epfd: w.fd_t, events: [*]epoll_event_t, maxevents: usize, timeout: w.timestamp_t, ret_size: *usize) w.errno_t;
