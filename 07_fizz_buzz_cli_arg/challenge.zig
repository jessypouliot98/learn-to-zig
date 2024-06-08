const std = @import("std");

// zig run challenge.zig -- 30

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    defer allocator.free(args);
    const stdout = std.io.getStdOut().writer();

    if (args.len < 2) return error.ExpectedArgument;

    const count = try std.fmt.parseInt(u32, args[1], 10);

    for (1..count + 1) |value| {
        const binary_fizz = @as(u2, @intFromBool(value % 3 == 0)) << 1;
        const binary_buzz = @as(u2, @intFromBool(value % 5 == 0));
        switch (binary_fizz | binary_buzz) {
            0b00 => try stdout.print("{d}\n", .{value}),
            0b10 => try stdout.writeAll("Fizz\n"),
            0b01 => try stdout.writeAll("Buzz\n"),
            0b11 => try stdout.writeAll("FizzBuzz\n"),
        }
    }
}
