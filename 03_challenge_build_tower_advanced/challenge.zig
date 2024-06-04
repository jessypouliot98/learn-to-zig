const std = @import("std");
const Allocator = std.mem.Allocator;

fn build_row(allocator: Allocator, width: usize, blocks: usize) ![]const u8 {
    const side_pad: usize = @divFloor(width - blocks, 2);
    const row = try allocator.alloc(u8, width);
    for (row, 0..) |_, i| {
        if (i < side_pad or i >= side_pad + blocks) {
            row[i] = ' ';
            continue;
        }
        row[i] = '*';
    }
    return row;
}

fn build_tour(allocator: Allocator, floors: usize, block_width: usize, block_height: usize) ![][]const u8 {
    const tour = try allocator.alloc([]const u8, floors * block_height);
    const tour_width: usize = floors * block_width * 2 - block_width;

    var i: usize = 0;
    while (i < floors) : (i += 1) {
        const block_count = (i + 1) * block_width * 2 - block_width;
        var j: usize = 0;
        while (j < block_height) : (j += 1) {
            const row: usize = i * (block_height) + j;
            tour[row] = try build_row(allocator, tour_width, block_count);
        }
    }

    return tour;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const result = try build_tour(allocator, 4, 4, 4);
    for (result) |row| {
        std.debug.print("[{s}]\n", .{row});
    }
}
