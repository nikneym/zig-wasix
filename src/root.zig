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

pub const CTL = struct {
    pub const ADD = 1;
    pub const MOD = 2;
    pub const DEL = 3;
};

pub const epoll_type_t = u32;

pub const EPOLL = struct {
    pub const IN = 0x001;
    pub const OUT = 0x004;
    pub const RDHUP = 1 << 2;
    pub const PRI = 1 << 3;
    pub const ERR = 0x008;
    pub const HUP = 0x010;
    pub const ET = (1 << 31);
    pub const ONESHOT = 1 << 7;
};

// this is actually defined as union on Linux
pub const epoll_data_t = extern struct {
    ptr: ?*anyopaque,
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
};

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

pub const addr_unix_port_t = extern struct {
    port: ip_port_t,
    addr: addr_unix_t,
};

pub const addr_port_u_t = extern union {
    unspec: addr_unspec_port_t,
    inet4: addr_ip4_port_t,
    inet6: addr_ip6_port_t,
    unix: addr_unix_port_t,
};

pub const addr_tag_t = enum(u8) {
    unspec,
    inet4,
    inet6,
    unix,

    pub fn name(tag: addr_tag_t) []const u8 {
        return switch (tag) {
            .unspec => "unspec",
            .inet4 => "inet4",
            .inet6 => "inet6",
            .unix => "unix",
        };
    }
};

pub const addr_port_t = extern struct {
    tag: addr_tag_t,
    u: addr_port_u_t,
};

pub const addr_u_t = extern union {
    unspec: addr_unspec_port_t,
    inet4: addr_ip4_port_t,
    inet6: addr_ip6_port_t,
    unix: addr_unix_port_t,
};

pub const addr_t = extern struct {
    tag: addr_tag_t,
    u: addr_u_t,
};

pub const AddressFamily = enum(address_family_t) {
    unspec,
    inet4,
    inet6,
    unix,
};

pub const SockType = enum(sock_type_t) {
    unused,
    stream,
    datagram,
    raw,
    seqpacket,
};

pub const SockProto = enum(sock_proto_t) {
    ip = 0,
    icmp = 1,
    igmp = 2,
    ipip = 4,
    tcp = 6,
    egp = 8,
    pup = 12,
    udp = 17,
    idp = 22,
    dccp = 33,
    ipv6 = 41,
    routing = 43,
    fragment = 44,
    rsvp = 46,
    gre = 47,
    esp = 50,
    ah = 51,
    icmpv6 = 58,
    none = 59,
    dstopts = 60,
    mtp = 92,
    beetph = 94,
    encap = 98,
    pim = 103,
    comp = 108,
    sctp = 132,
    mh = 135,
    udplite = 136,
    mpls = 137,
    ethernet = 143,
    raw = 255,
    mptcp = 262,
    max = 263,
    _,
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

pub const hash_t = extern struct {
    b0: u64,
    b1: u64,
};

pub const stack_snapshot_t = extern struct {
    user: u64,
    hash: hash_t,
};

pub const longsize_t = u64;

// clock
pub extern "wasix_32v1" fn clock_time_set(id: w.clockid_t, timestamp: w.timestamp_t) w.errno_t;

// file descriptor
pub extern "wasix_32v1" fn fd_dup(id: w.fd_t, ret_fd: *w.fd_t) w.errno_t;
pub extern "wasix_32v1" fn fd_event(initial_val: u64, flags: w.eventrwflags_t, ret_fd: *w.fd_t) w.errno_t;
pub extern "wasix_32v1" fn fd_pipe(fd1: w.fd_t, fd2: w.fd_t) w.errno_t;

// TTY
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

// NOTE: has bugs, disabled
//pub extern "wasix_32v1" fn stack_checkpoint(snapshot: *stack_snapshot_t, retptr: *longsize_t) w.errno_t;

// socket
pub extern "wasix_32v1" fn sock_open(af: AddressFamily, ty: SockType, pt: SockProto, ro_sock: *w.fd_t) w.errno_t;
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
pub extern "wasix_32v1" fn sock_bind(sock: w.fd_t, addr: *const addr_port_t) w.errno_t;
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
