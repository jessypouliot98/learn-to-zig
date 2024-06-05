const std = @import("std");
const expect = std.testing.expect;
const Allocator = std.mem.Allocator;

fn get_is_anagram(allocator: Allocator, string_a: []const u8, string_b: []const u8) !bool {
    // Quick exit
    if (string_a.len != string_b.len) return false;

    // Increment count with char_a, decrement count with char_b/
    // Expects map to be all 0, otherwise it's not an anagram.
    // This is preferred to comparing two maps after as it reduce memory footprint
    var map = std.AutoHashMap(u8, isize).init(allocator);
    defer map.deinit();

    for (string_a, string_b) |char_a, char_b| {
        {
            const current_count = try map.getOrPut(char_a);
            if (current_count.found_existing) {
                current_count.value_ptr.* += 1;
            } else {
                current_count.value_ptr.* = 1;
            }
        }
        {
            const current_count = try map.getOrPut(char_b);
            if (current_count.found_existing) {
                current_count.value_ptr.* -= 1;
            } else {
                current_count.value_ptr.* = -1;
            }
        }
    }

    var it = map.valueIterator();
    return while (it.next()) |value| {
        if (value.* != @as(isize, 0)) break false;
    } else true;
}

test "returns true when strings are anagrams" {
    const allocator = std.testing.allocator;
    try expect(try get_is_anagram(allocator, "abab", "baba"));
    try expect(try get_is_anagram(allocator, "abcdefg", "gfedabc"));
}

test "returns false when strings are not anagrams" {
    const allocator = std.testing.allocator;
    try expect(!try get_is_anagram(allocator, "a", "b"));
    try expect(!try get_is_anagram(allocator, "abc", "def"));
}
