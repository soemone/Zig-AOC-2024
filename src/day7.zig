const std = @import("std");
const utils = @import("utils.zig");

pub fn run() !void {
    var file = try std.fs.cwd().openFile("./src/input_day7.txt", .{});

    var reader = file.reader();
    var buffer: [128]u8 = undefined;
    var sum: usize = 0;

    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line_with_newline| {
        const line = line_with_newline[0 .. line_with_newline.len - 1];
        var start_end = std.mem.split(u8, line, ": ");
        const start = try std.fmt.parseInt(usize, start_end.next().?, 10);
        var items = std.mem.split(u8, start_end.next().?, " ");

        var len: u8 = 0;
        var numbers: [15]usize = undefined;
        while (items.next()) |item| {
            numbers[len] = try std.fmt.parseInt(usize, item, 10);
            len += 1;
        }

        if (count(&numbers, len, start)) {
            sum += start;
        }
    }

    utils.print("The caliberation sum is: {d}\n", .{sum});

    file.close();
}

// Some bullshit lol
fn count_(values: []const usize, len: u8, requested: usize) bool {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    var items = std.ArrayList([12]u8).init(alloc);

    items.append(([_]u8{0} ** 12)) catch undefined;

    var k: usize = 0;
    for (0..(len - 1)) |i| {
        _ = i;
        const initial_len = items.items.len;

        for (0..(2 * initial_len)) |j| {
            var new_items: [12]u8 = undefined;
            @memcpy(&new_items, &items.items[j]);
            items.append(new_items) catch undefined;
        }

        for (0..initial_len) |j| {
            items.items[j][k] = 1;
        }

        for (initial_len..(2 * initial_len)) |j| {
            items.items[j][k] = 0;
        }

        for ((2 * initial_len)..(3 * initial_len)) |j| {
            items.items[j][k] = 2;
        }

        k += 1;
    }

    for (items.items) |item| {
        var res = values[0];
        for (0..(len - 1)) |j| {
            if (item[j] == 0)
                res *= values[j + 1]
            else if (item[j] == 1)
                res += values[j + 1]
            else
                res = res * std.math.pow(usize, 10, (std.math.log10(values[j + 1]) + 1)) + values[j + 1];
        }
        if (requested == res) return true;
    }
    return false;
}

// This does the same thing as the above
fn count(values: []const usize, len: u8, requested: usize) bool {
    const n = 3;
    const iterations = std.math.pow(usize, n, (len - 1));
    for (0..iterations) |i| {
        var num = i;
        var res: usize = values[0];
        for (0..(len - 1)) |j| {
            const digit = num % n;

            if (digit == 0)
                res *= values[j + 1]
            else if (digit == 1)
                res += values[j + 1]
            else
                res = res * std.math.pow(usize, 10, (std.math.log10(values[j + 1]) + 1)) + values[j + 1];

            num /= n;

            if (res > requested) break;
        }
        if (res == requested) return true;
    }
    return false;
}
