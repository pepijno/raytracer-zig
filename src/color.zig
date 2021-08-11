const std = @import("std");

pub const Color = struct {
    red: f32,
    green: f32,
    blue: f32,

    pub fn toBgra(self: *const Color) u32 {
        return 255 << 24 | @floatToInt(u32, 255.99 * self.red) << 16 | @floatToInt(u32, 255.99 * self.green) << 8 | @floatToInt(u32, 255.99 * self.blue);
    }

    pub fn black() Color {
        return .{
            .red = 0.0,
            .green = 0.0,
            .blue = 0.0,
        };
    }

    pub fn add(self: *const Color, other: Color) Color {
        return .{
            .red = self.red + other.red,
            .green = self.green + other.green,
            .blue = self.blue + other.blue,
        };
    }

    pub fn multiply(self: *const Color, factor: f32) Color {
        return .{
            .red = self.red * factor,
            .green = self.green * factor,
            .blue = self.blue * factor,
        };
    }
};
