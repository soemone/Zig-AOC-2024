const std = @import("std");
const utils = @import("utils.zig");
const print = utils.print;

// This is somehow wrong but I can't for the life of me figure out what's wrong with it
// This code (Python) I copied online gives me 1995 which is apparently the correct answer, but my code gives 2160.
// I have no idea what it does, though

// G = {i+j*1j: c for i,r in enumerate(open('./src/input_day6.txt'))
//                for j,c in enumerate(r.strip())}

// start = min(p for p in G if G[p] == '^')

// def walk(G):
//     pos, dir, seen = start, -1, set()
//     while pos in G and (pos,dir) not in seen:
//         seen |= {(pos,dir)}
//         if G.get(pos+dir) == "#":
//             dir *= -1j
//         else: pos += dir
//     return {p for p,_ in seen}, (pos,dir) in seen

// path = walk(G)[0]
// print(len(path),
//       sum(walk(G | {o: '#'})[1] for o in path))

const directions: [4][2]isize = .{ .{ 0, -1 }, .{ 0, 1 }, .{ -1, 0 }, .{ 1, 0 } };
const Dir = enum { Up, Down, Left, Right };
const Position = struct { x: isize, y: isize, d: Dir };
var map: [2048][2048]u32 = undefined;
var test_map: [2048][2048]u32 = undefined;
var i: usize = 0;
var j: usize = 0;
var viable_loops: usize = 0;
var steps: u32 = 0;

pub fn run() !void {
    var file = try std.fs.cwd().openFile("./src/input_day6.txt", .{});
    var reader = file.reader();
    var buffer: [2048]u8 = undefined;

    var pos = Position{ .x = 0, .y = 0, .d = Dir.Up };

    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line_with_newline| {
        const line = line_with_newline[0 .. line_with_newline.len - 1];
        j = 0;
        for (line) |character| {
            if (character == '#') {
                map[i][j] = 0;
            } else if (character == '^') {
                pos = Position{ .x = @intCast(j), .y = @intCast(i), .d = Dir.Up };
                map[i][j] = 3;
            } else {
                map[i][j] = 1;
            }
            j += 1;
        }
        i += 1;
    }
    @memcpy(&test_map, &map);

    while (move(&pos, &map, true)) {}

    for (0..i) |k| {
        for (0..j) |l| {
            if (map[k][l] > 1)
                steps += 1;
        }
    }

    print("The steps taken are: {d}\nThe total number of locations where an object can be placed for an infinite loop is: {d}\n", .{ steps, viable_loops });

    file.close();
}

fn recalc_dir(pos: *Position) void {
    const dir = pos.*.d;
    switch (dir) {
        Dir.Up => pos.*.d = Dir.Right,
        Dir.Right => pos.*.d = Dir.Down,
        Dir.Down => pos.*.d = Dir.Left,
        Dir.Left => pos.*.d = Dir.Up,
    }
}

fn move(pos: *Position, map_arr: *[2048][2048]u32, check: bool) bool {
    const deviation = directions[(@intFromEnum(pos.*.d))];
    const dx = deviation[0];
    const dy = deviation[1];

    // Move until you hit the end or an obstacle
    while (map_arr.*[@abs(pos.*.y + dy)][@abs(pos.*.x + dx)] != 0) {
        // Change position
        pos.*.x += dx;
        pos.*.y += dy;

        if (check and check_viability(pos)) {
            viable_loops += 1;
        }

        // Mark as visited on map
        if (check) map_arr.*[@abs(pos.*.y)][@abs(pos.*.x)] = 2;

        // Check outside map
        if (pos.*.y + dy < 0 or
            pos.*.x + dx < 0 or
            pos.*.y + dy + 1 > i or
            pos.*.x + dx + 1 > j)
        {
            return false;
        }
    }

    // Recalculate the direction after hitting an obstacle
    recalc_dir(pos);

    return true;
}

fn check_viability(test_pos: *Position) bool {
    var tmp_pos = test_pos.*;
    // const start_pos = tmp_pos;
    var location_to_insert: Position = undefined;
    if (get_next_pos(tmp_pos)) |item|
        location_to_insert = item
    else
        return false;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    var points = std.ArrayList(Position).init(alloc);

    const initial_map_value = test_map[@abs(location_to_insert.y)][@abs(location_to_insert.x)];
    test_map[@abs(location_to_insert.y)][@abs(location_to_insert.x)] = 0;

    // Move to next point
    while (move(&tmp_pos, &test_map, false)) {
        // Check if we've visited the point before
        for (points.items) |point| {
            if (point.x == tmp_pos.x and point.y == tmp_pos.y and point.d == tmp_pos.d) {
                test_map[@abs(location_to_insert.y)][@abs(location_to_insert.x)] = initial_map_value;
                return true;
            }
        }

        // Add points
        points.append(tmp_pos) catch return false;
    }

    points.clearAndFree();
    // Fix map
    test_map[@abs(location_to_insert.y)][@abs(location_to_insert.x)] = initial_map_value;

    return false;
}

fn get_next_pos(pos: Position) ?Position {
    var test_pos = pos;
    const deviation = directions[(@intFromEnum(pos.d))];
    const dx = deviation[0];
    const dy = deviation[1];

    // Out of map
    if (pos.y + dy < 0 or
        pos.x + dx < 0 or
        pos.y + dy + 1 > i or
        pos.x + dx + 1 > j)
    {
        return null;
    }

    test_pos.x += dx;
    test_pos.y += dy;

    return test_pos;
}
