const std = @import("std");

pub const Color = struct {
    red: f32,
    green: f32,
    blue: f32,

    pub fn toBgra(self: *const Color) u32 {
        return 255 << 24 | @floatToInt(u32, 255.99 * self.red) << 16 | @floatToInt(u32, 255.99 * self.green) << 8 | @floatToInt(u32, 255.99 * self.blue);
    }
};
