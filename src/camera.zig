const std = @import("std");
const math = std.math;
const Vec3 = @import("vector3.zig").Vec3;
const Ray = @import("ray.zig").Ray;

pub const Camera = struct {
    origin: Vec3,
    screenDL: Vec3,
    horizontal: Vec3,
    vertical: Vec3,
    u: Vec3,
    v: Vec3,
    lensRadius: f32,

    pub fn new(lookFrom: Vec3, lookAt: Vec3, vup: Vec3, fieldOfView: f32, aspectRatio: f32, aperture: f32, focusDistance: f32) Camera {
        const theta = fieldOfView * math.pi / 180.0;
        const halfHeight = math.tan(theta / 2.0);
        const halfWidth = aspectRatio * halfHeight;
        const w = lookFrom.subtract(lookAt).normalized();
        const u = vup.outerProduct(w).normalized();
        const v = w.outerProduct(u);
        std.log.debug("{} {} {}", .{ w, halfHeight, halfWidth });

        return .{
            .origin = lookFrom,
            .screenDL = lookFrom.subtract(u.multiply(halfWidth * focusDistance)).subtract(v.multiply(halfHeight * focusDistance)).subtract(w.multiply(focusDistance)),
            .horizontal = u.multiply(2.0 * halfWidth * focusDistance),
            .vertical = v.multiply(2.0 * halfHeight * focusDistance),
            .u = u,
            .v = v,
            .lensRadius = aperture / 2.0,
        };
    }

    pub fn createRay(self: *const Camera, x: f32, y: f32) Ray {
        // std.log.debug("{}", .{self.screenDL.add(self.horizontal.multiply(x)).add(self.vertical.multiply(y))});
        const direction = self.screenDL.add(self.horizontal.multiply(x)).add(self.vertical.multiply(y)).subtract(self.origin).normalized();
        return .{ .origin = self.origin, .direction = direction };
    }
};
