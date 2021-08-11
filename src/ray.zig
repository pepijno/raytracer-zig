const std = @import("std");
const Vec3 = @import("vector3.zig").Vec3;

pub const Ray = struct {
    origin: Vec3,
    direction: Vec3,
};
