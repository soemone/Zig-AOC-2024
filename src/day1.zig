const std = @import("std");

pub fn run() !void {
    var file = try std.fs.cwd().openFile("./src/input_day1.txt", .{});

    var reader = file.reader();
    var buffer: [15]u8 = undefined;
    var array_1: [1000]u32 = undefined;
    var array_2: [1000]u32 = undefined;
    var i: u16 = 0;
    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        var split =
            std.mem.split(u8, line[0 .. line.len - 1], "   ");
        array_1[i] = try std.fmt.parseInt(u32, split.next().?, 10);
        array_2[i] = try std.fmt.parseInt(u32, split.next().?, 10);
        i += 1;
    }
    std.mem.sort(u32, &array_1, {}, std.sort.asc(u32));
    std.mem.sort(u32, &array_2, {}, std.sort.asc(u32));
    var sum: u64 = 0;
    for (0..i) |j| {
        if (array_1[j] > array_2[j])
            sum += array_1[j] - array_2[j]
        else
            sum += array_2[j] - array_1[j];
    }

    var similarity_score: u32 = 0;

    for (0..i) |j| {
        const item = array_1[j];
        for (0..i) |k| 
            similarity_score += item * @as(u32, @intFromBool(array_2[k] == array_1[j]));
    }

    try std.io.getStdOut().writer().print("Sum is: {d}\nSimilarity score is: {d}\n", .{ sum, similarity_score });
    file.close();
}