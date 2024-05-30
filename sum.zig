const std = @import("std");

const SumError = error{
    NotSupported,
};

fn sum(comptime T: type, a: T, b: T) SumError!T {
    return switch (T) {
        isize, usize, i64, u64, i32, u32, i16, u16, i8, u8 => {
            if (b == 0) return a;
            return try sum(T, a ^ b, (a & b) << 1);
        },
        else => SumError.NotSupported,
    };
}

test "it sums u8 as expected" {
    var i: u8 = 0;
    while (i <= 100) : (i += 1) {
        try std.testing.expectEqual(
            i + i,
            sum(u8, i, i),
        );
    }
}

test "it sums i64 as expected" {
    var i: i64 = -100;
    while (i <= 100) : (i += 1) {
        try std.testing.expectEqual(
            i + i,
            sum(i64, i, i),
        );
    }
}

test "it doesn't support floats" {
    var i: f16 = 0;
    while (i <= 100) : (i += 1) {
        const maybeError = sum(f16, i, i);
        try std.testing.expectError(SumError.NotSupported, maybeError);
    }
}
