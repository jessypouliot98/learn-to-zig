// https://leetcode.com/problems/trapping-rain-water/?envType=study-plan-v2&envId=top-interview-150

const std = @import("std");

fn collectRainWater(elevations: []usize) usize {
    var water: usize = 0;
    var left: usize = 0;
    var left_max = elevations[left];
    var right: usize = elevations.len - 1;
    var right_max = elevations[right];

    while (left < right) {
        if (left_max < right_max) {
            left += 1;
            left_max = @max(left_max, elevations[left]);
            water += left_max - elevations[left];
        } else {
            right -= 1;
            right_max = @max(right_max, elevations[right]);
            water += right_max - elevations[right];
        }
    }

    return water;
}

test "challenge case 1" {
    var input = [_]usize{ 0, 1, 0, 2, 1, 0, 1, 3, 2, 1, 2, 1 };

    const result = collectRainWater(&input);
    try std.testing.expectEqual(6, result);
}

test "challenge case 2" {
    var input = [_]usize{ 4, 2, 0, 3, 2, 5 };

    const result = collectRainWater(&input);
    try std.testing.expectEqual(9, result);
}
