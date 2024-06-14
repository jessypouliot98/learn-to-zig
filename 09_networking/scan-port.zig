// TODO Revisit when async/await is back in zig
// TODO The process usually just hangs. How to I cancel a connection that never ends?

const std = @import("std");

fn scanPort(name: []const u8, port: u16) !bool {
    const address = try std.net.Address.resolveIp(name, port);
    const stream = try std.net.tcpConnectToAddress(address);
    defer stream.close();
    return true;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    defer allocator.free(args);
    const stdout = std.io.getStdOut().writer();

    if (args.len < 2) return error.ExpectedArgument;

    for (0..25566) |port| {
        const has_port = scanPort(args[1], @as(u16, @intCast(port))) catch false; // Weird syntax / return type

        if (has_port) {
            try stdout.print("{s}:{d} |{}|\n", .{ args[1], port, has_port });
        } else {
            try stdout.writeByte('.');
        }
    }
}
