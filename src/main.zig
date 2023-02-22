const std = @import("std");

const allocator = std.heap.page_allocator;

pub fn main() !void {
    const stdout = std.io.getStdOut();
    const stderr = std.io.getStdErr();
    const args = (try std.process.argsAlloc(allocator))[1..];
    var dest: Mode = undefined;
    var target: u8 = undefined;
    if (args.len < 2) {
        _ = try stderr.write("引数が足りません");
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
                        _ = try stderr.write("変換先指定が無効です");
                        std.os.exit(0);
                        unreachable;
                    },
                };
            },
            1 => {
                target = stringToInt(arg) catch {
                    _ = try stderr.write("10進数で入力してください");
                    std.os.exit(0);
                    unreachable;
                };
            },
            else => {},
        }
    }

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

const Error = error{
    InputError,
};

fn stringToInt(str: []const u8) !u8 {
    var int: u8 = 0;
    for (str) |c, i| {
        if (c < 0x30 or 0x39 < c) {
            return Error.InputError;
        }
        int += (c - 0x30) * std.math.pow(u8, 10, @intCast(u8, i + 1));
    }
    return int;
}

test "string to numeric" {
    try std.testing.expect(stringToInt("10") == 10);
}
