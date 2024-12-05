const std = @import("std");

pub fn print(comptime format: []const u8, args: anytype) void {
    std.io.getStdOut().writer().print(format, args) catch undefined;
}

pub fn prints(comptime format: []const u8) void {
    std.io.getStdOut().writer().print(format, .{}) catch undefined;
}
