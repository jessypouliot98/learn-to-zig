const std = @import("std");
const testing = std.testing;

fn Matrix(comptime size: usize, T: type) type {
    return [size][size]T;
}

// TODO Make size & T Generic instead of hardcoding `3` & `u8`
fn rotate(matrix: *Matrix(3, u8)) void {
    for (0..matrix.len) |i| {
        var j: u8 = 0;
        while (j <= i) : (j += 1) {
            const temp = matrix[j][i];
            matrix[j][i] = matrix[i][j];
            matrix[i][j] = temp;
        }
    }
}

test "it rotates a matrix of size 3 as expected" {
    var matrix_to_rotate = Matrix(3, u8){
        .{ 1, 2, 3 },
        .{ 4, 5, 6 },
        .{ 7, 8, 9 },
    };
    rotate(&matrix_to_rotate);

    try testing.expectEqual(
        Matrix(3, u8){
            .{ 1, 4, 7 },
            .{ 2, 5, 8 },
            .{ 3, 6, 9 },
        },
        matrix_to_rotate,
    );
}

// TODO FIXME rotate only supports size 3 with values of u8
test "it rotates a matrix of size 2 as expected" {
    var matrix_to_rotate = Matrix(2, f16){
        .{ 0.1, 0.2 },
        .{ 0.3, 0.4 },
    };
    rotate(&matrix_to_rotate);

    try testing.expectEqual(
        Matrix(2, u8){
            .{ 0.1, 0.3 },
            .{ 0.2, 0.4 },
        },
        matrix_to_rotate,
    );
}
