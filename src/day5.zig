const std = @import("std");
const utils = @import("utils.zig");
const print = utils.print;

const PageOrder = struct { start: u8, end: u8 };

pub fn run() !void {
    // Hashmap implementation
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    // Of the form `end: [start 1, start 2, start 3...]`
    var hm = std.hash_map.AutoHashMap(u8, std.ArrayList(u8)).init(alloc);

    var file = try std.fs.cwd().openFile("./src/input_day5.txt", .{});
    var reader = file.reader();
    var buffer: [128]u8 = undefined;

    var collecting = true;
    var page_orders: [1190]PageOrder = undefined;
    var i: u16 = 0;
    var sum: u16 = 0;
    var incorrect_sum: u16 = 0;

    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        if (line.len == 0 or line[0] == '\n') {
            collecting = false;
            continue;
        }

        if (collecting) {
            var split = std.mem.split(u8, line, "|");

            const start = try std.fmt.parseInt(u8, split.next().?, 10);
            const end = try std.fmt.parseInt(u8, split.next().?, 10);

            // Hashmap implementation
            if (hm.contains(end)) {
                const array = hm.getPtr(end).?;
                try array.*.append(start);
            } else {
                var array = std.ArrayList(u8).init(alloc);
                try array.append(start);
                try hm.put(end, array);
            }

            page_orders[i] = PageOrder{ .start = start, .end = end };
            i += 1;
        } else {
            var updates: [25]u8 = undefined;
            var split = std.mem.split(u8, line, ",");
            var j: u8 = 0;

            while (split.next()) |item| {
                updates[j] = try std.fmt.parseInt(u8, item, 10);
                j += 1;
            }

            // Replace this with `check_if_correct(&updates, hm, j, i)` to see how much faster the hash map implementation is
            if (check_if_correct_hm(&updates, hm, j))
                sum += updates[j / 2]
            else
                incorrect_sum += updates[j / 2];
        }
    }

    utils.print("Sum is: {d}\nSum of corrected updates is: {d}\n", .{ sum, incorrect_sum });

    file.close();
}

// A very slow method indeed
fn check_if_correct(updates: *[25]u8, page_orders: []PageOrder, j: u16, i: u16) bool {
    var include = true;
    for (0..j) |k| {
        const item = updates.*[k];
        // Looping through every. single. ordering rule. This slows down the program considerably
        for (0..i) |idx| {
            const order = page_orders[idx];
            for ((k + 1)..j) |u| {
                // This is an update that is invalidly ordered.
                if (updates.*[u] == order.start and order.end == item) {
                    include = false;
                    std.mem.swap(u8, &updates.*[u], &updates.*[k]);
                    _ = check_if_correct(updates, page_orders, j, i);
                    break;
                }
            }
            if (!include) break;
        }
        if (!include) break;
    }

    return include;
}

// A much much faster method using hashmaps
fn check_if_correct_hm(updates: *[25]u8, page_orders: std.hash_map.AutoHashMap(u8, std.ArrayList(u8)), j: u16) bool {
    var include = true;
    for (0..j) |k| {
        const item = updates.*[k];

        var orders: std.ArrayList(u8) = undefined;

        if (page_orders.get(item)) |valid_orders|
            orders = valid_orders
        else
            continue;

        // Significantly less elements to loop through
        for (orders.items) |order| {
            for ((k + 1)..j) |u| {
                // This is an update that is invalidly ordered.
                if (updates.*[u] == order) {
                    include = false;
                    // Swap to perform one correction
                    std.mem.swap(u8, &updates.*[u], &updates.*[k]);
                    // Many updates have many subsequent corrections that need to be made
                    _ = check_if_correct_hm(updates, page_orders, j);
                    break;
                }
            }
            if (!include) break;
        }
        if (!include) break; // Is this needed?
    }

    return include;
}
