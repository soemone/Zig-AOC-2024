const std = @import("std");
const utils = @import("utils.zig");
const day1 = @import("day1.zig");
const day2 = @import("day2.zig");
const day3 = @import("day3.zig");
const day4 = @import("day4.zig");
const day5 = @import("day5.zig");
const day6 = @import("day6.zig");

pub fn main() !void {
    utils.prints("Day 1:\n");
    try day1.run();
    utils.prints("Day 2:\n");
    try day2.run();
    utils.prints("Day 3:\n");
    try day3.run();
    utils.prints("Day 4:\n");
    try day4.run();
    utils.prints("Day 5:\n");
    try day5.run();
    utils.prints("Day 6:\n");
    try day6.run();
}
