const std = @import("std");
const utils = @import("utils.zig");

// I spent way too long trying to figure out where I went wrong in part 2
// I had made 2 mistakes that were not apparent in the test case, I tried correcting both
// But, unfortunately I tried one fix before reverting and trying the other, which led to no success
// Anyway, what I failed to see was:
// Even with what I thought was correct code, some files are moved twice (I don't know how this happens, but it does)
// So I used a min item check to make sure I was only moving the ones that needed to be moved - I tried using a hashmap for this
// but saw no noticable performance difference so I just settled on a method that does not use it
// Another mistake was < vs <= in line 111, when trying to find an open region
// It definitly works now, though albeit slowly

const print = utils.print;

// A number bigger than what can be produced by the input
const spacer = 50000;

pub fn run() !void {
    var file = try std.fs.cwd().openFile("./src/input_day9.txt", .{});

    var reader = file.reader();
    var buffer: [20000]u8 = undefined;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    var disk_p1 = std.ArrayList(usize).init(alloc);
    var disk_p2 = std.ArrayList(usize).init(alloc);

    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        var i: usize = 0;
        var id: usize = 0;
        while (i < line.len) {
            const file_size = line[i] - '0';
            var free_space: u8 = 0;
            if (line.len > i + 1) free_space = line[i + 1] - '0';
            for (0..file_size) |_| try disk_p1.append(id);
            for (0..free_space) |_| try disk_p1.append(spacer);
            i += 2;
            id += 1;
        }
    }
    // Copy contents of disk p1 to disk p2
    try disk_p2.appendSlice(disk_p1.items);

    // Part 1
    var i: usize = 0;
    while (i < disk_p1.items.len) {
        const item = disk_p1.items[i];
        if (item == spacer and i < disk_p1.items.len) {
            const idx = get_next_item(disk_p1);
            disk_p1.items[i] = disk_p1.items[idx];
            var j: usize = disk_p1.items.len - 1;
            while (j >= idx) {
                _ = disk_p1.swapRemove(j);
                j -= 1;
            }
        }
        i += 1;
    }

    var j: usize = 0;
    var sum: usize = 0;
    while (j < disk_p1.items.len) {
        sum += disk_p1.items[j] * j;
        j += 1;
    }
    //
    print("Checksum of part 1 is: {}\n", .{sum});

    // Part 2
    rearrange_disk(disk_p2);

    j = 0;
    sum = 0;
    while (j < disk_p2.items.len) {
        if (disk_p2.items[j] != spacer)
            sum += disk_p2.items[j] * j;
        j += 1;
    }

    print("Checksum of part 2 is: {}\n", .{sum});
    file.close();
}

fn get_next_item(disk: std.ArrayList(usize)) usize {
    var i: usize = disk.items.len - 1;
    while (i >= 0) {
        if (disk.items[i] != spacer) return i;
        i -= 1;
    }
    // This should never occur
    return 0;
}

fn rearrange_disk(disk: std.ArrayList(usize)) void {
    var i: usize = disk.items.len - 1;
    var prev: usize = disk.items[i];
    var size: usize = 0;
    var min_item: usize = spacer + 1;
    while (i > 0) {
        const curr = disk.items[i];
        // Previous item is current item, so we are still in the same file
        if (curr == prev) size += 1
        // Previous item is different from current item, so new file / spacer started
        // If it is a spacer that was cataloged, don't do this
        else if (min_item > prev and prev != spacer) {
            // mark item as seen
            min_item = prev;
            var start: usize = 0;
            var dot_size: usize = 0;
            var prev_replace: usize = disk.items[0];
            var j: usize = 0;
            // Iterate through the items, from start to end to find a suitable range of spacers
            while (j <= i) {
                if (disk.items[j] == spacer) {
                    if (prev_replace != spacer) start = j;
                    dot_size += 1;
                } else {
                    dot_size = 0;
                }
                // This location can host the file block
                if (dot_size == size) {
                    // Fill in the block
                    for (0..size) |k| {
                        disk.items[start + k] = prev;
                        // Replace elements with a spacer
                        disk.items[i + k + 1] = spacer;
                    }
                    break;
                }
                prev_replace = disk.items[j];
                j += 1;
            }
            size = 1;
        } else {
            size = 1;
        }
        i -= 1;
        prev = curr;
    }
}
