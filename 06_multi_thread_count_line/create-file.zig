const std = @import("std");

pub fn main() !void {
    const lines_to_write = 1_000_000;

    const cwd: std.fs.Dir = std.fs.cwd();
    cwd.makeDir("output") catch |e| switch (e) {
        error.PathAlreadyExists => {},
        else => return e,
    };

    var output_dir: std.fs.Dir = try cwd.openDir("output", .{});
    defer output_dir.close();

    const file: std.fs.File = try output_dir.createFile("lines.txt", .{});
    defer file.close();

    const line_prefix = comptime "Line: ";
    for (0..lines_to_write) |i| {
        var buf: [line_prefix.len + 10]u8 = undefined;
        const line = try std.fmt.bufPrint(&buf, "{s}{d}\n", .{ line_prefix, i + 1 });
        _ = try file.write(line);
    }
}
