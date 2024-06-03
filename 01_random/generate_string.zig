const std = @import("std");
const Allocator = std.mem.Allocator;

fn generate_string(allocator: Allocator, fill: u8, length: usize) ![]const u8 {
    const string = try allocator.alloc(u8, length);
    var i: usize = 0;
    while (i < length) : (i += 1) {
        string[i] = fill;
    }
    return string;
}

test "it fills a string" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    try std.testing.expectEqualStrings("***", try generate_string(allocator, '*', 3));
    try std.testing.expectEqualStrings("AAAAA", try generate_string(allocator, 'A', 5));
}
