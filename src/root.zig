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

pub const option_timestamp_u_t = extern union {
    none: u8,
    some: w.timestamp_t,
};

pub const option_timestamp_t = extern struct {
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
// flow_info1 holds the high two bytes of the flow info, flow_info0 the low
// two; scope_id1/scope_id0 split the scope ID the same way. All wasix
// syscalls are little-endian, hence the high half coming first.
const addr_ip6_t = extern struct {
    n0: u16,
    n1: u16,
    n2: u16,
    n3: u16,
    h0: u16,
    h1: u16,
    h2: u16,
    h3: u16,
    flow_info1: u16,
    flow_info0: u16,
    scope_id1: u16,
    scope_id0: u16,
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

pub extern "wasix_32v1" fn clock_time_set(id: w.clockid_t, timestamp: w.timestamp_t) w.errno_t;

pub extern "wasix_32v1" fn fd_dup(id: w.fd_t, ret_fd: *w.fd_t) w.errno_t;
pub extern "wasix_32v1" fn fd_event(initial_val: u64, flags: w.eventrwflags_t, ret_fd: *w.fd_t) w.errno_t;
pub extern "wasix_32v1" fn fd_pipe(fd1: w.fd_t, fd2: w.fd_t) w.errno_t;

pub extern "wasix_32v1" fn tty_get(state: *tty_t) w.errno_t;
pub extern "wasix_32v1" fn tty_set(state: *tty_t) w.errno_t;

pub extern "wasix_32v1" fn getcwd(buf: [*]u8, path_len: *pointersize_t) w.errno_t;
pub extern "wasix_32v1" fn chdir(path: [*:0]const u8, path_len: usize) w.errno_t;

pub extern "wasix_32v1" fn callback_signal(callback: [*:0]const u8, callback_len: usize) void;

pub extern "wasix_32v1" fn thread_spawn_v2(start_ptr: *thread_start_t, ret_tid: *tid_t) w.errno_t;
pub extern "wasix_32v1" fn thread_sleep(duration: w.timestamp_t) w.errno_t;
pub extern "wasix_32v1" fn thread_id(ret_tid: *tid_t) w.errno_t;
pub extern "wasix_32v1" fn thread_join(tid: tid_t) w.errno_t;
pub extern "wasix_32v1" fn thread_parallelism(ret_parallelism: *usize) w.errno_t;
pub extern "wasix_32v1" fn thread_signal(tid: tid_t, signal: w.signal_t) w.errno_t;
pub extern "wasix_32v1" fn thread_exit(rval: w.exitcode_t) noreturn;

pub extern "wasix_32v1" fn stack_checkpoint(snapshot: *stack_snapshot_t, retptr: *longsize_t) w.errno_t;

pub const context_id_t = u64;

// Identifier of the main context of the current context-switching environment.
// In the current Wasmer/wasix-libc implementation this is always 0.
pub const context_main: context_id_t = 0;

// `entrypoint` is the index of a `() -> ()` function in the indirect function
// table. Pass `@intFromPtr(&fn_with_callconv_c)` to get one.
pub extern "wasix_32v1" fn context_create(ret_id: *context_id_t, entrypoint: pointersize_t) w.errno_t;
pub extern "wasix_32v1" fn context_switch(target_id: context_id_t) w.errno_t;
pub extern "wasix_32v1" fn context_destroy(id: context_id_t) w.errno_t;

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

pub extern "wasix_32v1" fn resolve(host: [*]const u8, host_len: usize, port: u16, addrs: [*]addr_t, naddrs: usize, ret_naddrs: *usize) w.errno_t;

pub extern "wasix_32v1" fn epoll_create(ret_fd: *w.fd_t) w.errno_t;
pub extern "wasix_32v1" fn epoll_ctl(epfd: w.fd_t, op: epoll_ctl_t, fd: w.fd_t, event: *const epoll_event_t) w.errno_t;
pub extern "wasix_32v1" fn epoll_wait(epfd: w.fd_t, events: [*]epoll_event_t, maxevents: usize, timeout: w.timestamp_t, ret_size: *usize) w.errno_t;

pub const pid_t = i32;
pub const fdflagsext_t = u16;
pub const dl_handle_t = u32;
pub const dl_flags_t = u32;
pub const function_pointer_t = u32;
pub const wasm_value_type_t = u8;
pub const join_flags_t = u32;
pub const stdio_mode_t = u8;
pub const stream_security_t = u8;
pub const sock_status_t = u8;
pub const disposition_t = u8;
pub const proc_spawn_fd_op_name_t = u8;

pub const option_pid_u_t = extern union {
    none: u8,
    some: pid_t,
};
pub const option_pid_t = extern struct {
    tag: u8,
    u: option_pid_u_t,
};

pub const option_fd_u_t = extern union {
    none: u8,
    some: w.fd_t,
};
pub const option_fd_t = extern struct {
    tag: u8,
    u: option_fd_u_t,
};

pub const errno_signal_t = extern struct {
    exit_code: w.errno_t,
    signal: w.signal_t,
};

pub const join_status_u_t = extern union {
    nothing: u8,
    exit_normal: w.errno_t,
    exit_signal: errno_signal_t,
    stopped: w.signal_t,
};
pub const join_status_t = extern struct {
    tag: u8,
    u: join_status_u_t,
};

pub const hardware_address_t = extern struct {
    n0: u8,
    n1: u8,
    n2: u8,
    h0: u8,
    h1: u8,
    h2: u8,
};

pub const reflection_result_t = extern struct {
    cacheable: bool_t,
    arguments: u16,
    results: u16,
};

pub const process_handles_t = extern struct {
    pid: pid_t,
    stdin: option_fd_t,
    stdout: option_fd_t,
    stderr: option_fd_t,
};

pub const signal_disposition_t = extern struct {
    sig: w.signal_t,
    disp: disposition_t,
};

pub const proc_spawn_fd_op_t = extern struct {
    cmd: proc_spawn_fd_op_name_t,
    fd: w.fd_t,
    src_fd: w.fd_t,
    path: [*]u8,
    path_len: pointersize_t,
    dirflags: w.lookupflags_t,
    oflags: w.oflags_t,
    fs_rights_base: w.rights_t,
    fs_rights_inheriting: w.rights_t,
    fdflags: w.fdflags_t,
    fdflagsext: fdflagsext_t,
};

// IPv6 address without flow info / scope id (8 bytes); used inside addr_ip_t.
pub const addr_ip6_bare_t = extern struct {
    n0: u16,
    n1: u16,
    n2: u16,
    n3: u16,
};

pub const addr_ip_u_t = extern union {
    unspec: addr_unspec_t,
    inet4: addr_ip4_t,
    inet6: addr_ip6_bare_t,
};
pub const addr_ip_t = extern struct {
    tag: u8,
    u: addr_ip_u_t,
};

pub const addr_unspec_cidr_t = extern struct {
    addr: addr_unspec_t,
    prefix: u8,
};
pub const addr_ip4_cidr_t = extern struct {
    addr: addr_ip4_t,
    prefix: u8,
};
pub const addr_ip6_cidr_t = extern struct {
    addr: addr_ip6_t,
    prefix: u8,
};
pub const addr_unix_cidr_t = extern struct {
    unused: u8,
};

pub const addr_cidr_u_t = extern union {
    unspec: addr_unspec_cidr_t,
    inet4: addr_ip4_cidr_t,
    inet6: addr_ip6_cidr_t,
    unix: addr_unix_cidr_t,
};
pub const addr_cidr_t = extern struct {
    tag: u8,
    u: addr_cidr_u_t,
};

pub const route_t = extern struct {
    cidr: addr_cidr_t,
    via_router: addr_t,
    preferred_until: option_timestamp_t,
    expires_at: option_timestamp_t,
};

pub extern "wasix_32v1" fn fd_dup2(fd: w.fd_t, min_result_fd: w.fd_t, cloexec: bool_t, ret_fd: *w.fd_t) w.errno_t;
pub extern "wasix_32v1" fn fd_fdflags_get(fd: w.fd_t, ret_flags: *fdflagsext_t) w.errno_t;
pub extern "wasix_32v1" fn fd_fdflags_set(fd: w.fd_t, flags: fdflagsext_t) w.errno_t;

pub extern "wasix_32v1" fn path_open2(
    fd: w.fd_t,
    dirflags: w.lookupflags_t,
    path: [*]const u8,
    path_len: usize,
    oflags: w.oflags_t,
    fs_rights_base: w.rights_t,
    fs_rights_inheriting: w.rights_t,
    fdflags: w.fdflags_t,
    fdflagsext: fdflagsext_t,
    ret_fd: *w.fd_t,
) w.errno_t;

pub extern "wasix_32v1" fn futex_wait(futex: *u32, expected: u32, timeout: *const option_timestamp_t, ret_woken: *bool_t) w.errno_t;
pub extern "wasix_32v1" fn futex_wake(futex: *u32, ret_woken: *bool_t) w.errno_t;
pub extern "wasix_32v1" fn futex_wake_all(futex: *u32, ret_woken: *bool_t) w.errno_t;

pub extern "wasix_32v1" fn stack_restore(snapshot: *const stack_snapshot_t, val: longsize_t) noreturn;

pub extern "wasix_32v1" fn proc_id(ret_pid: *pid_t) w.errno_t;
pub extern "wasix_32v1" fn proc_parent(pid: pid_t, ret_parent: *pid_t) w.errno_t;
pub extern "wasix_32v1" fn proc_exit2(rval: w.exitcode_t) void;
pub extern "wasix_32v1" fn proc_signal(pid: pid_t, signal: w.signal_t) w.errno_t;
pub extern "wasix_32v1" fn proc_raise_interval(sig: w.signal_t, interval: w.timestamp_t, repeat: bool_t) w.errno_t;
pub extern "wasix_32v1" fn proc_signals_get(buf: [*]u8) w.errno_t;
pub extern "wasix_32v1" fn proc_signals_sizes_get(ret_size: *usize) w.errno_t;
pub extern "wasix_32v1" fn proc_snapshot() w.errno_t;
pub extern "wasix_32v1" fn proc_fork(copy_memory: bool_t, ret_pid: *pid_t) w.errno_t;
pub extern "wasix_32v1" fn proc_fork_env(ret_pid: *pid_t) w.errno_t;
pub extern "wasix_32v1" fn proc_join(pid: *option_pid_t, flags: join_flags_t, ret_status: *join_status_t) w.errno_t;
pub extern "wasix_32v1" fn proc_exec(name: [*]const u8, name_len: usize, args: [*]const u8, args_len: usize) noreturn;
pub extern "wasix_32v1" fn proc_exec2(
    name: [*]const u8,
    name_len: usize,
    args: [*]const u8,
    args_len: usize,
    envs: [*]const u8,
    envs_len: usize,
) noreturn;
pub extern "wasix_32v1" fn proc_exec3(
    name: [*]const u8,
    name_len: usize,
    args: [*]const u8,
    args_len: usize,
    envs: [*]const u8,
    envs_len: usize,
    search_path: bool_t,
    path: [*]const u8,
    path_len: usize,
) w.errno_t;
pub extern "wasix_32v1" fn proc_spawn(
    name: [*]const u8,
    name_len: usize,
    chroot: bool_t,
    args: [*]const u8,
    args_len: usize,
    preopen: [*]const u8,
    preopen_len: usize,
    stdin_mode: stdio_mode_t,
    stdout_mode: stdio_mode_t,
    stderr_mode: stdio_mode_t,
    working_dir: [*]const u8,
    working_dir_len: usize,
    ret_handles: *process_handles_t,
) w.errno_t;
pub extern "wasix_32v1" fn proc_spawn2(
    name: [*]const u8,
    name_len: usize,
    args: [*]const u8,
    args_len: usize,
    envs: [*]const u8,
    envs_len: usize,
    fd_ops: [*]const proc_spawn_fd_op_t,
    fd_ops_len: usize,
    signal_dispositions: [*]const signal_disposition_t,
    signal_dispositions_len: usize,
    search_path: bool_t,
    path: [*]const u8,
    path_len: usize,
    ret_pid: *pid_t,
) w.errno_t;

// socket additions
pub extern "wasix_32v1" fn sock_status(fd: w.fd_t, ret_status: *sock_status_t) w.errno_t;
pub extern "wasix_32v1" fn sock_addr_local(fd: w.fd_t, ret_addr: *addr_port_t) w.errno_t;
pub extern "wasix_32v1" fn sock_addr_peer(fd: w.fd_t, ret_addr: *addr_port_t) w.errno_t;
pub extern "wasix_32v1" fn sock_pair(af: AddressFamily, ty: SockType, pt: SockProto, ret_fd0: *w.fd_t, ret_fd1: *w.fd_t) w.errno_t;
pub extern "wasix_32v1" fn sock_recv_from(
    fd: w.fd_t,
    ri_data: [*]const w.iovec_t,
    ri_data_len: usize,
    ri_flags: w.riflags_t,
    ret_size: *usize,
    ret_oflags: *w.roflags_t,
    ret_addr: *addr_port_t,
) w.errno_t;
pub extern "wasix_32v1" fn sock_send_to(
    fd: w.fd_t,
    si_data: [*]const w.ciovec_t,
    si_data_len: usize,
    si_flags: w.siflags_t,
    addr: *const addr_port_t,
    ret_size: *usize,
) w.errno_t;
pub extern "wasix_32v1" fn sock_send_file(
    out_fd: w.fd_t,
    in_fd: w.fd_t,
    offset: w.filesize_t,
    count: w.filesize_t,
    ret_size: *w.filesize_t,
) w.errno_t;

// port / network configuration
pub extern "wasix_32v1" fn port_bridge(network: [*]const u8, network_len: usize, token: [*]const u8, token_len: usize, security: stream_security_t) w.errno_t;
pub extern "wasix_32v1" fn port_unbridge() w.errno_t;
pub extern "wasix_32v1" fn port_dhcp_acquire() w.errno_t;
pub extern "wasix_32v1" fn port_addr_add(addr: *const addr_cidr_t) w.errno_t;
pub extern "wasix_32v1" fn port_addr_remove(addr: *const addr_t) w.errno_t;
pub extern "wasix_32v1" fn port_addr_clear() w.errno_t;
pub extern "wasix_32v1" fn port_mac(ret_addr: *hardware_address_t) w.errno_t;
pub extern "wasix_32v1" fn port_addr_list(addrs: [*]addr_cidr_t, naddrs: *usize) w.errno_t;
pub extern "wasix_32v1" fn port_gateway_set(addr: *const addr_t) w.errno_t;
pub extern "wasix_32v1" fn port_route_add(
    cidr: *const addr_cidr_t,
    via_router: *const addr_t,
    preferred_until: *const option_timestamp_t,
    expires_at: *const option_timestamp_t,
) w.errno_t;
pub extern "wasix_32v1" fn port_route_remove(cidr: *const addr_t) w.errno_t;
pub extern "wasix_32v1" fn port_route_clear() w.errno_t;
pub extern "wasix_32v1" fn port_route_list(routes: [*]route_t, nroutes: *usize) w.errno_t;

pub extern "wasix_32v1" fn dl_invalid_handle(handle: dl_handle_t) w.errno_t;
pub extern "wasix_32v1" fn dlopen(
    path: [*]const u8,
    path_len: usize,
    flags: dl_flags_t,
    err_buf: [*]u8,
    err_buf_len: usize,
    ld_library_path: [*]const u8,
    ld_library_path_len: usize,
    ret_handle: *dl_handle_t,
) w.errno_t;
pub extern "wasix_32v1" fn dlsym(
    handle: dl_handle_t,
    symbol: [*]const u8,
    symbol_len: usize,
    err_buf: [*]u8,
    err_buf_len: usize,
    ret_size: *usize,
) w.errno_t;

// dynamic call / closures / reflection
pub extern "wasix_32v1" fn call_dynamic(
    function_id: function_pointer_t,
    values: [*]const u8,
    values_len: usize,
    results: [*]u8,
    results_len: pointersize_t,
    strict: bool_t,
) w.errno_t;
pub extern "wasix_32v1" fn closure_allocate(ret_id: *function_pointer_t) w.errno_t;
pub extern "wasix_32v1" fn closure_free(closure_id: function_pointer_t) w.errno_t;
pub extern "wasix_32v1" fn closure_prepare(
    backing_function_id: function_pointer_t,
    closure_id: function_pointer_t,
    argument_types: [*]const wasm_value_type_t,
    argument_types_len: usize,
    result_types: [*]const wasm_value_type_t,
    result_types_len: usize,
    user_data_ptr: [*]u8,
) w.errno_t;
pub extern "wasix_32v1" fn reflect_signature(
    function_id: function_pointer_t,
    argument_types: [*]wasm_value_type_t,
    argument_types_len: u16,
    result_types: [*]wasm_value_type_t,
    result_types_len: u16,
    ret_result: *reflection_result_t,
) w.errno_t;
