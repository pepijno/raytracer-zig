const std = @import("std");
const Vec3 = @import("vector3.zig").Vec3;

const bias: f32 = 1e-4;

pub const Ray = struct {
    origin: Vec3,
    direction: Vec3,

    pub fn new(origin: Vec3, direction: Vec3) Ray {
        return .{
            .origin = origin.add(direction.multiply(bias)),
            .direction = direction,
        };
    }

    pub fn reflect(self: *const Ray, point: Vec3, normal: Vec3) Ray {
        const direction = self.direction.reflect(normal).normalized();
        return new(self.origin, direction);
    }
};
