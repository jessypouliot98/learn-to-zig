const std = @import("std");

fn sum(a: usize, b: usize) usize {
  if (b == 0) return a;
  return sum(a ^ b, (a & b) << 1);
}

test "it sums as expected" {
  var i: usize = 0;
  while (i <= 100) : (i += 1) {
    try std.testing.expectEqual(
      i + i,
      sum(i, i),
    );
  }
}