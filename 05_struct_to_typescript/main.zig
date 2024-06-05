const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

const Error = error{
    MissingImplementation,
};

fn to_typescript_declaration(allocator: Allocator, T: type) ![]const u8 {
    _ = allocator;
    return switch (@typeInfo(T)) {
        .Int, .Float, .ComptimeInt, .ComptimeFloat => "number",
        .Pointer => |info| {
            if (info.is_const and info.child == u8) {
                return "string";
            }
            return Error.MissingImplementation;
        },
        .Enum => {
            return "Unable to make it work :(";
        },
        else => |info| {
            std.debug.print("\n\n{}\n\n", .{info});
            return Error.MissingImplementation;
        },
    };
}

test "converts zig number types to typescript number declaration" {
    const number_types = .{
        i1,  i2,  i4, i8, i16, i32, isize,
        u1,  u2,  u4, u8, u16, u32, usize,
        f16, f32,
    };
    inline for (number_types) |number_type| {
        try testing.expectEqualStrings("number", try to_typescript_declaration(testing.allocator, number_type));
    }
}

test "converts zig string type to typescript string declaration" {
    try testing.expectEqualStrings("string", try to_typescript_declaration(testing.allocator, []const u8));
}

test "converts zig enum field type to typescript const string declaration" {
    const a3 = [_][]const u8{ "Hello", "Foo", "Bar" };
    std.debug.print("{s}\n", .{a3});
    const TestEnum = enum {
        Foo,
        Bar,
        Baz,
    };
    try testing.expectEqualStrings(
        \\"Foo" | "Bar" | "Baz"
    ,
        try to_typescript_declaration(
            testing.allocator,
            TestEnum,
        ),
    );
}
