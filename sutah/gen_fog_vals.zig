const std = @import("std");

const HORIZON_SCANLINE = 112;
const NUM_SNES_SCANLINES = 224;
const COLDATA_R: u8 = 0b001_00000;
const COLDATA_G: u8 = 0b010_00000;
const COLDATA_B: u8 = 0b100_00000;

pub fn main() !void {
    const r_file = try std.fs.cwd().createFile("bin/r_fog_vals.bin", .{});
    const g_file = try std.fs.cwd().createFile("bin/g_fog_vals.bin", .{});
    const b_file = try std.fs.cwd().createFile("bin/b_fog_vals.bin", .{});
    defer r_file.close();
    defer g_file.close();
    defer b_file.close();
    const r_writer = r_file.writer();
    const g_writer = g_file.writer();
    const b_writer = b_file.writer();

    // first two bytes; just HDMA 0 for the first HORIZON_SCANLINE-1 number of scanlines
    try r_writer.writeByte(HORIZON_SCANLINE);
    try g_writer.writeByte(HORIZON_SCANLINE);
    try b_writer.writeByte(HORIZON_SCANLINE);
    try r_writer.writeByte(0);
    try g_writer.writeByte(0);
    try b_writer.writeByte(0);

    // then the horizon starts
    try r_writer.writeByte(0x80 | NUM_SNES_SCANLINES - HORIZON_SCANLINE);
    try g_writer.writeByte(0x80 | NUM_SNES_SCANLINES - HORIZON_SCANLINE);
    try b_writer.writeByte(0x80 | NUM_SNES_SCANLINES - HORIZON_SCANLINE);

    // go from white and fade out
    var r: f64 = 4;
    var g: f64 = 6;
    var b: f64 = 12;
    var col_decreasing = COLDATA_R;
    for (NUM_SNES_SCANLINES - HORIZON_SCANLINE) |_| {
        const r_u5: u5 = @intFromFloat(r);
        const g_u5: u5 = @intFromFloat(g);
        const b_u5: u5 = @intFromFloat(b);
        try r_writer.writeByte(COLDATA_R | r_u5);
        try g_writer.writeByte(COLDATA_G | g_u5);
        try b_writer.writeByte(COLDATA_B | b_u5);

        switch (col_decreasing) {
            COLDATA_R => {
                r = if (r > 0) r * 0.8 else 0;
                col_decreasing = COLDATA_G;
            },
            COLDATA_G => {
                g = if (g > 0) g * 0.8 else 0;
                col_decreasing = COLDATA_B;
            },
            COLDATA_B => {
                b = if (b > 0) b * 0.8 else 0;
                col_decreasing = COLDATA_R;
            },
            else => {},
        }
    }
}
