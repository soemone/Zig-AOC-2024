const std = @import("std");
const utils = @import("utils.zig");

// EW. Global variables
// I can't pass this to a function for some reason?
// fn(_: [][]const u8) does not work?????
var matrix: [2048][2048]u8 = undefined;

pub fn run() !void {
    var file = try std.fs.cwd().openFile("./src/input_day4.txt", .{});

    var reader = file.reader();
    var buffer: [2048]u8 = undefined;
    var i: usize = 0;
    var j: usize = 0;
    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line_with_newline| {
        const line = line_with_newline[0 .. line_with_newline.len - 1];
        j = 0;
        for (line) |character| {
            matrix[i][j] = character;
            j += 1;
        }
        i += 1;
    }

    utils.print("XMAS count is: {d}\nX-MAS count is: {d}", .{find_xmas(i, j), find_x_mas(i, j)});

    file.close();
}

// Col = j
// Row = i
fn find_x_mas(row: usize, col: usize) u32 {
    var count: u32 = 0;
    for (0..row) |i| {
        for (0..col) |j| {
            // M M
            //  A
            // S S
            const masmas_s = matrix[i][j] == 'M' and matrix[i + 1][j + 1] == 'A' and matrix[i + 2][j + 2] == 'S' and
                                   matrix[i][j + 2] == 'M'                             and matrix[i + 2][j] == 'S';
            // M S
            //  A
            // M S
            const masmas_d = matrix[i][j] == 'M' and matrix[i + 1][j + 1] == 'A' and matrix[i + 2][j + 2] == 'S' and
                                   matrix[i][j + 2] == 'S'                             and matrix[i + 2][j] == 'M';
            // S S
            //  A
            // M M
            const massam_s = matrix[i][j] == 'S' and matrix[i + 1][j + 1] == 'A' and matrix[i + 2][j + 2] == 'M' and
                                   matrix[i][j + 2] == 'S'                             and matrix[i + 2][j] == 'M';
            // S M
            //  A
            // S M
            const massam_d = matrix[i][j] == 'S' and matrix[i + 1][j + 1] == 'A' and matrix[i + 2][j + 2] == 'M' and
                                   matrix[i][j + 2] == 'M'                             and matrix[i + 2][j] == 'S';

            if (col > j + 2 and row > i + 2 and (masmas_d or masmas_s or massam_d or massam_s)) {
                count += 1;
            }
        }
    }
    return count;
}


fn find_xmas(row: usize, col: usize) u32 {
    var count: u32 = 0;
    for (0..row) |i| {
        for (0..col) |j| {
            // Horizontal forwards
            if (col > j + 3 and matrix[i][j] == 'X' and matrix[i][j + 1] == 'M' and matrix[i][j + 2] == 'A' and matrix[i][j + 3] == 'S') {
                count += 1;
            }
            // Horizontal backwards
            if (j >= 3 and matrix[i][j] == 'X' and matrix[i][j - 1] == 'M' and matrix[i][j - 2] == 'A' and matrix[i][j - 3] == 'S') {
                count += 1;
            }
            // Vertical Forwards
            if (row > i + 3 and matrix[i][j] == 'X' and matrix[i + 1][j] == 'M' and matrix[i + 2][j] == 'A' and matrix[i + 3][j] == 'S') {
                count += 1;
            }
            // Vertical Backwards
            if (i >= 3 and matrix[i][j] == 'X' and matrix[i - 1][j] == 'M' and matrix[i - 2][j] == 'A' and matrix[i - 3][j] == 'S') {
                count += 1;
            }
            // Diagonal forwards down
            if (row > i + 3 and col > j + 3 and matrix[i][j] == 'X' and matrix[i + 1][j + 1] == 'M' and matrix[i + 2][j + 2] == 'A' and matrix[i + 3][j + 3] == 'S') {
                count += 1;
            }
            // Diagonal backwards up
            if (i >= 3 and j >= 3 and matrix[i][j] == 'X' and matrix[i - 1][j - 1] == 'M' and matrix[i - 2][j - 2] == 'A' and matrix[i - 3][j - 3] == 'S') {
                count += 1;
            }
            // Diagonal forwards up
            if (row > i + 3 and j >= 3 and matrix[i][j] == 'X' and matrix[i + 1][j - 1] == 'M' and matrix[i + 2][j - 2] == 'A' and matrix[i + 3][j - 3] == 'S') {
                count += 1;
            }
            // Diagonal backwards down
            if (i >= 3 and col > j + 3 and matrix[i][j] == 'X' and matrix[i - 1][j + 1] == 'M' and matrix[i - 2][j + 2] == 'A' and matrix[i - 3][j + 3] == 'S') {
                count += 1;
            }
        }
    }
    return count;
}
