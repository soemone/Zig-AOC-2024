const std = @import("std");
const utils = @import("utils.zig");
const day1 = @import("day1.zig");
const day2 = @import("day2.zig");
const day3 = @import("day3.zig");
const day4 = @import("day4.zig");
const day5 = @import("day5.zig");
const day6 = @import("day6.zig");
const day7 = @import("day7.zig");
const day8 = @import("day8.zig");
const day9 = @import("day9.zig");

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
    utils.prints("Day 7:\n");
    try day7.run();
    utils.prints("Day 8:\n");
    try day8.run();
    utils.prints("Day 9:\n");
    try day9.run();
}
