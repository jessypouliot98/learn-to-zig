const std = @import("std");

fn fib(n: usize) usize {
  if (n < 1) return 0;
  if (n < 2) return 1;
  return fib(n - 1) + fib(n - 2);
}

test "runs fibonacci as expected" {
  try std.testing.expectEqual(
    832040,
    fib(30),
  );
}