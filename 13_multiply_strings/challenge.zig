// https://leetcode.com/problems/multiply-strings/description/

const std = @import("std");
const Allocator = std.mem.Allocator;

fn digitToUint(digit: u8) !usize {
    return switch (digit) {
        '0'...'9' => digit - '0',
        else => error.InvalidCharacter,
    };
}

fn stringToUint(digits: []const u8) !usize {
    var value: usize = 0;

    for (digits, 0..) |digit, index| {
        const digit_pos = digits.len - 1 - index;
        const digitMultiplier: usize = if (digit_pos == 0) 1 else std.math.pow(usize, 10, digit_pos);
        const charValue: usize = (try digitToUint(digit)) * digitMultiplier;
        value = value + charValue;
    }

    return value;
}

fn multiply(allocator: Allocator, a: []const u8, b: []const u8) ![]u8 {
    const product: usize = (try stringToUint(a)) * (try stringToUint(b));
    return std.fmt.allocPrint(allocator, "{d}", .{product});
}

test "challenge case 1" {
    const allocator = std.testing.allocator;

    const result = try multiply(allocator, "2", "3");
    defer allocator.free(result);

    try std.testing.expectEqualSlices(
        u8,
        "6",
        result,
    );
}

test "challenge case 2" {
    const allocator = std.testing.allocator;

    const result = try multiply(allocator, "123", "456");
    defer allocator.free(result);

    try std.testing.expectEqualSlices(
        u8,
        "56088",
        result,
    );
}
