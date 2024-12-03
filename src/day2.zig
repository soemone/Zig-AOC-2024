const std = @import("std");
const utils = @import("utils.zig");

pub fn run() !void {
    var file = try std.fs.cwd().openFile("./src/input_day2.txt", .{});
    var reader = file.reader();
    var buffer: [25]u8 = undefined;

    var safe: u32 = 0;

    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        var split =
            std.mem.split(u8, line[0 .. line.len - 1], " ");
        var is_safe = true;
        var i: u32 = 0;
        var items: [8]i8 = undefined;

        while (split.next()) |item| {
            items[i] = try std.fmt.parseInt(i8, item, 10);
            i += 1;
        }

        is_safe = check_safe(&items, i);
        // Ew. So many loops. Could be more efficient indeed
        if (!is_safe) {
            for (0..i) |idx| {
                var new_items: [8]i8 = undefined;
                var j: u32 = 0;
                var k: u32 = 0;
                // Remove one element and check safety
                for (items[0..i]) |item| {
                    if (idx != j) {
                        new_items[k] = item;
                        k += 1;
                    }
                    j += 1;
                }
                if (check_safe(&new_items, k)) {
                    is_safe = true;
                    break;
                }
            }
        }
        if (is_safe) safe += 1;
    }

    utils.print("{d} Safe reactor levels found!\n", .{safe});
    file.close();
}

fn check_safe(items: []const i8, num: u32) bool {
    const first = items[0];
    var is_safe = true;
    var normal_sign: i8 = 0;
    var prev = first;

    for (items[1..num]) |item| {
        const integer = item;
        const difference = integer - prev;
        const abs_diff = @abs(difference);

        if (normal_sign == 0)
            normal_sign = std.math.sign(difference);

        const new_sign = std.math.sign(difference);

        if (new_sign != normal_sign or abs_diff > 3 or abs_diff < 1) {
            is_safe = false;
            break;
        }
        prev = integer;
    }
    return is_safe;
}
