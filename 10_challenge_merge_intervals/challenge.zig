const std = @import("std");
const Allocator = std.mem.Allocator;

fn mergeIntervals(allocator: Allocator, intervals: []const [2]u8) ![][2]u8 {
    var merged = try allocator.alloc([2]u8, intervals.len);

    var merged_index: usize = 0;
    var intervals_index: usize = 0;

    while (intervals_index < intervals.len) : (intervals_index += 1) {
        if (intervals_index == 0) {
            merged[merged_index] = intervals[intervals_index];
            continue;
        }

        const prev = &merged[merged_index];
        const current = &intervals[intervals_index];
        if (prev.*[1] >= current.*[0]) {
            prev.*[1] = current.*[1];
            continue;
        }

        merged_index += 1;
        merged[merged_index] = intervals[intervals_index];
    }

    return try allocator.realloc(merged, merged_index + 1);
}

test "challenge" {
    const allocator = std.testing.allocator;

    const input: []const [2]u8 = &.{
        .{ 1, 3 },
        .{ 2, 6 },
        .{ 8, 10 },
        .{ 15, 18 },
    };
    const expected: []const [2]u8 = &.{
        .{ 1, 6 },
        .{ 8, 10 },
        .{ 15, 18 },
    };

    const result = try mergeIntervals(allocator, input);
    defer allocator.free(result);

    try std.testing.expectEqualSlices([2]u8, expected, result);
}
