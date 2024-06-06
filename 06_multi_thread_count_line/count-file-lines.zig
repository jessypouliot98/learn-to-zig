const std = @import("std");

const thread_count = 2;

fn count_lines(file: *std.fs.File, min: u64, max: u64, total: *u64) !void {
    try file.*.seekTo(min);

    const reader = file.*.reader();
    const byte: ?u8 = reader.readByte() catch null;
    if (byte != null and byte.? == '\n') {
        total.* += 1;
    }

    while (true) {
        reader.skipUntilDelimiterOrEof('\n') catch undefined;
        const pos = file.*.getPos() catch max;
        if (pos >= max) break;
        total.* += 1;
    }
}

pub fn main() !void {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile("output/lines.txt", .{});
    const file_length = try file.getEndPos();
    file.close();

    const split: u64 = @divFloor(file_length, @as(u64, @intCast(thread_count)));
    var positions: [thread_count + 1]u64 = undefined;
    for (0..positions.len) |i| {
        positions[i] =
            if (i == 0) 0 else if (i == positions.len - 1) file_length else i * split;
    }

    std.debug.print("{any} {d}\n", .{ positions, file_length });

    var total: u64 = 1;

    var thread_files: [thread_count]std.fs.File = undefined;
    var threads: [thread_count]std.Thread = undefined;

    inline for (0..thread_count) |thread_index| {
        const min = positions[thread_index];
        var max = positions[thread_index + 1];
        if (thread_index + 1 < thread_count) {
            max += 1;
        }

        var thread_file = try cwd.openFile("output/lines.txt", .{});
        thread_files[thread_index] = thread_file;
        threads[thread_index] = try std.Thread.spawn(.{}, count_lines, .{ &thread_file, min, max, &total });
    }
    for (threads, thread_files) |thread, thread_file| {
        thread.join();
        thread_file.close();
    }

    std.debug.print("{d}\n", .{total});
}
