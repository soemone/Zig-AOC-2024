const std = @import("std");
const utils = @import("utils.zig");

const print = utils.print;

pub fn run() !void {
    var file = try std.fs.cwd().openFile("./src/input_day8.txt", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    
    // Stores all the points of one type
    var hm = std.hash_map.AutoHashMap(u8, std.ArrayList([2]u16)).init(alloc);

    var reader = file.reader();
    var buffer: [128]u8 = undefined;

    var x: u16 = 0;
    var y: u16 = 0;

    var map: [512][512]u8 = undefined;

    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line_with_newline| {
        const line = line_with_newline[0 .. line_with_newline.len - 1];
        x = 0;
        for (line) |character| {
            if (character != '.') {
                const pt = .{ x, y };
                if (hm.contains(character)) {
                    const arr = hm.getPtr(character).?;
                    try arr.*.append(pt);
                } else {
                    var arr = std.ArrayList([2]u16).init(alloc);
                    try arr.append(pt);
                    try hm.put(character, arr);
                }
            }
            // Use a map to prevent counting repeats.
            map[y][x] = character;
            x += 1;
        }
        y += 1;
    }

    var iterator = hm.iterator();
    // Loop through sets of letters
    while (iterator.next()) |array| {
        const items = array.value_ptr.*.items;
        // Calculate for each pair
        for (0..items.len) |i| {
            const a = items[i];
            for ((i + 1)..items.len) |j| {
                const b = items[j];
                // Conversions
                var xa: i32 = @intCast(a[0]);
                var ya: i32 = @intCast(a[1]);
                var xb: i32 = @intCast(b[0]);
                var yb: i32 = @intCast(b[1]);
                // Slope calculation
                const dx: i32 = (xb - xa);
                const dy: i32 = (yb - ya);

                // Calculating distances
                // Replace the while with if to do part 1
                while (xa - dx >= 0 and ya - dy >= 0 and xa - dx < x and ya - dy < y) {
                    xa -= dx;
                    ya -= dy;
                    map[@abs(ya)][@abs(xa)] = '#';
                }

                while (xb + dx < x and yb + dy < y and xb + dx >= 0 and yb + dy >= 0) {
                    yb += dy;
                    xb += dx;
                    map[@abs(yb)][@abs(xb)] = '#';
                }
            }
        }
    }

    // Count unique instances on the map
    var count: u16 = 0;
    for (0..y) |i| {
        for (0..x) |j| {
            // Replace "!= '.'" with "== '#'" to do part 1
            if (map[i][j] != '.') count += 1;
        }
    }

    print("Total antinode count is: {d}\n", .{count});
    file.close();
}
