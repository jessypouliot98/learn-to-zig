const std = @import("std");

fn Matrix(comptime size: usize) type {
    return [size][size]bool;
}

const VisitedSet = std.AutoArrayHashMap(usize, void);

fn dfs(comptime size: usize, flight_matrix: *const Matrix(size), node: usize, visited: *VisitedSet) !void {
    try visited.*.put(node, {});
    for (flight_matrix.*[node], 0..) |connected, neighbour| {
        if (connected and !visited.*.contains(neighbour)) {
            try dfs(size, flight_matrix, neighbour, visited);
        }
    }
}

fn getMinConnections(comptime size: usize, flight_matrix: *const Matrix(size)) !usize {
    const allocator = std.heap.page_allocator;

    var visited = VisitedSet.init(allocator);
    defer visited.deinit();
    var components: usize = 0;

    for (0..size) |i| {
        if (!visited.contains(i)) {
            try dfs(size, flight_matrix, i, &visited);
            components += 1;
        }
    }

    return components - 1;
}

test "challenge case 1" {
    const flight_matrix = Matrix(5){
        .{ false, true, false, false, true },
        .{ true, false, false, false, false },
        .{ false, false, false, true, false },
        .{ false, false, true, false, false },
        .{ true, false, false, false, false },
    };
    const actual = try getMinConnections(5, &flight_matrix);
    try std.testing.expectEqual(1, actual);
}

test "challenge case 2" {
    const flight_matrix = Matrix(4){
        .{ false, false, false, false },
        .{ false, false, false, false },
        .{ false, false, false, false },
        .{ false, false, false, false },
    };
    const actual = try getMinConnections(4, &flight_matrix);
    try std.testing.expectEqual(3, actual);
}
