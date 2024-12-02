const std = @import("std");

pub fn print(comptime format: []const u8, args: anytype) void {
    std.io.getStdOut().writer().print(format, args) catch undefined;
}
