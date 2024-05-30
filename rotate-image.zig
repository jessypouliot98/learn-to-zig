const std = @import("std");
const testing = std.testing;

// TODO Make Matrix a fn with a size parameter... how ?
// fn Matrix(comptime size: usize) {
//     return ???
// }
const Matrix = struct {
    [3]u8,
    [3]u8,
    [3]u8,
};

// TODO Make Matrix with generic size... how ?
// fn rotate(matrix: *Matrix(usize)) void {
fn rotate(matrix: *Matrix) void {
    for (0..matrix.len) |i| {
        var j: u8 = 0;
        while (j <= i) : (j += 1) {
            // TODO FIXME, I want to swap the values without the compilation error and I want to do it allocating the least memory possible
            // error: unable to resolve comptime value
            // note: tuple field access index must be comptime-known
            const temp = matrix[j][i];
            matrix[j][i] = matrix[i][j];
            matrix[i][j] = temp;
        }
    }
}

test "it rotates a matrix as expected" {
    // var matrix_to_rotate = Matrix(3){
    var matrix_to_rotate = Matrix{
        .{ 1, 2, 3 },
        .{ 4, 5, 6 },
        .{ 7, 8, 9 },
    };
    rotate(&matrix_to_rotate);

    try testing.expectEqual(
        // Matrix(3){
        Matrix{
            .{ 7, 4, 1 },
            .{ 8, 5, 2 },
            .{ 9, 6, 3 },
        },
        matrix_to_rotate,
    );
}
