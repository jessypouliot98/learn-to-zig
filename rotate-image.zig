const std = @import("std");
const testing = std.testing;

fn Matrix(size: comptime_int, T: type) type {
    return [size][size]T;
}

// TODO Make Matrix with generic size... how ?
// fn rotate(matrix: *Matrix(usize)) void {
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

test "it rotates a matrix as expected" {
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
