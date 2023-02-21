const std = @import("std");

const allocator = std.heap.page_allocator;
pub fn main() !void {
    const args = (try std.process.argsAlloc(allocator))[1..];
    var dest: Mode = undefined;
    var target: u8 = undefined;
    if (args.len < 2) {
        std.debug.print("引数が足りません", .{});
        std.os.exit(0);
        unreachable;
    }

    for (args) |arg, i| {
        switch (i) {
            0 => {
                if (arg.len > 2) {
                    std.os.exit(1);
                    unreachable;
                }
                dest = switch (arg[1]) {
                    'b' => Mode.Bin,
                    'd' => Mode.Dec,
                    'x' => Mode.Hex,
                    else => {
                        std.debug.print("変換先指定が無効です", .{});
                        std.os.exit(0);
                        unreachable;
                    },
                };
            },
            1 => {
                target = stringToInt(arg);
            },
            else => {},
        }
    }

    const stdout = std.io.getStdOut();
    switch (dest) {
        Mode.Bin => {
            try std.fmt.format(stdout.writer(), "{b}", .{target});
        },
        Mode.Dec => {
            try std.fmt.format(stdout.writer(), "{d}", .{target});
        },
        Mode.Hex => {
            try std.fmt.format(stdout.writer(), "{X}", .{target});
        },
    }
}

const Mode = enum {
    Bin,
    Dec,
    Hex,
};

fn stringToInt(str: []const u8) u8 {
    var int: u8 = 0;
    for (str) |c, i| {
        int += (c - 0x30) * std.math.pow(u8, 10, @intCast(u8, i + 1));
    }
    return int;
}

test "string to numeric" {
    try std.testing.expect(stringToInt("10") == 10);
}
