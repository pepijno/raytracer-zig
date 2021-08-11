const std = @import("std");

fn clamp(comptime T: type, a: T, min: T, max: T) T {
    if (a < min) {
        return min;
    }
    if (a > max) {
        return max;
    }
    return a;
}

pub const Color = struct {
    red: f32,
    green: f32,
    blue: f32,

    pub fn toBgra(self: *const Color) u32 {
        const r = @floatToInt(u32, clamp(f32, 255.0 * self.red, 0.0, 255.0));
        const g = @floatToInt(u32, clamp(f32, 255.0 * self.green, 0.0, 255.0));
        const b = @floatToInt(u32, clamp(f32, 255.0 * self.blue, 0.0, 255.0));
        return 255 << 24 | r << 16 | g << 8 | b;
    }

    pub fn black() Color {
        return .{
            .red = 0.0,
            .green = 0.0,
            .blue = 0.0,
        };
    }

    pub fn white() Color {
        return .{
            .red = 1.0,
            .green = 1.0,
            .blue = 1.0,
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

pub const Material = struct {
    diffuseColor: Color,
    reflectColor: Color,
    specularExponent: f32,
};
