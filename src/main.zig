const std = @import("std");
const utils = @import("utils.zig");
const day1 = @import("day1.zig");
const day2 = @import("day2.zig");
const day3 = @import("day3.zig");
pub fn main() !void {
    utils.print("Day 1:\n", .{});
    try day1.run();
    utils.print("Day 2:\n", .{});
    try day2.run();
    utils.print("Day 3:\n", .{});
    try day3.run();
}
