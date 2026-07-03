const builtin = @import("builtin");

comptime {
    if (builtin.os.tag == .macos) {
        _ = MacStubs;
    }
}

const MacStubs = struct {
    export fn abort() callconv(.c) noreturn {
        while (true) {}
    }

    export fn exit(code: c_int) callconv(.c) noreturn {
        _ = code;
        while (true) {}
    }

    export fn bzero(s: [*]u8, n: usize) callconv(.c) void {
        var i: usize = 0;
        while (i < n) : (i += 1) {
            s[i] = 0;
        }
    }

    const timespec = extern struct {
        tv_sec: isize,
        tv_nsec: isize,
    };

    export fn clock_gettime(clk_id: c_int, tp: *timespec) callconv(.c) c_int {
        _ = clk_id;
        tp.tv_sec = 0;
        tp.tv_nsec = 0;
        return 0;
    }

    export fn fcopyfile(from: c_int, to: c_int, state: ?*anyopaque, flags: u32) callconv(.c) c_int {
        _ = from;
        _ = to;
        _ = state;
        _ = flags;
        return -1;
    }

    export fn free(ptr: ?*anyopaque) callconv(.c) void {
        _ = ptr;
    }

    export fn malloc_size(ptr: ?*const anyopaque) callconv(.c) usize {
        _ = ptr;
        return 0;
    }

    export fn posix_memalign(memptr: **anyopaque, alignment: usize, size: usize) callconv(.c) c_int {
        _ = memptr;
        _ = alignment;
        _ = size;
        return 12; // ENOMEM
    }

    export fn getenv(name: [*]const u8) callconv(.c) ?[*]u8 {
        _ = name;
        return null;
    }

    export fn isatty(fd: c_int) callconv(.c) c_int {
        _ = fd;
        return 0;
    }

    export fn sigaction(sig: c_int, act: ?*const anyopaque, oact: ?*anyopaque) callconv(.c) c_int {
        _ = sig;
        _ = act;
        _ = oact;
        return 0;
    }

    export fn sigemptyset(set: ?*anyopaque) callconv(.c) c_int {
        _ = set;
        return 0;
    }

    export fn __availability_version_check(count: c_int, versions: [*]const u32) callconv(.c) c_int {
        _ = count;
        _ = versions;
        return 1;
    }

    export fn _availability_version_check(count: c_int, versions: [*]const u32) callconv(.c) c_int {
        _ = count;
        _ = versions;
        return 1;
    }
};
