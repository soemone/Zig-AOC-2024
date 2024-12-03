const std = @import("std");
const utils = @import("utils.zig");

pub fn run() !void {
    var file = try std.fs.cwd().openFile("./src/input_day3.txt", .{});

    var reader = file.reader();
    var buffer: [8192]u8 = undefined;

    var sum: usize = 0;
    var enabled = true;

    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line_with_newline| {
        const line = line_with_newline[0 .. line_with_newline.len - 1];
        var i: usize = 0;
        while (true) {
            const start = i;
            const do = take_chars("do()", line, &i);
            i = start;
            const dont = take_chars("don't()", line, &i);
            // So this is how you do bitwise operations?
            // WHERE IS XOR?!?!
            enabled = (enabled or do) and !dont;

            const is_mul = take_chars("mul(", line, &i);

            if (is_mul and enabled) {
                var is_valid = true;
                const first = take_while_is_num(line, &i);

                if (line[i] != ',') is_valid = false;
                i += 1;

                const second = take_while_is_num(line, &i);

                if (line[i] != ')') is_valid = false;
                if (is_valid) sum += first * second;
            }

            i += 1;

            if (i >= line.len) break;
        }
    }
    utils.print("The sum produced by the instructions is: {d}\n", .{sum});
    file.close();
}

fn take_while_is_num(array: []const u8, index: *usize) usize {
    var number: usize = 0;
    while (true) {
        const char = array[index.*];
        if (char <= '9' and char >= '0') {
            number = number * 10 + char - '0';
        } else break;
        index.* += 1;
    }
    return number;
}

fn take_chars(find: []const u8, array: []const u8, index: *usize) bool {
    var found = true;
    while (true) {
        const char = array[index.*];
        if (char == find[0]) {
            index.* += 1;
            for (1..find.len) |j| {
                if (find[j] != array[index.*]) {
                    found = false;
                    break;
                }
                index.* += 1;
            }
            return found;
        } else return false;
    }
}
