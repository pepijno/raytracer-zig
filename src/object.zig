const std = @import("std");
const Vec3 = @import("vector3.zig").Vec3;
const Ray = @import("ray.zig").Ray;
const Color = @import("color.zig").Color;

pub const Material = struct {
    color: Color,
};

pub const Intersection = struct {
    t: f32,
    hitPoint: Vec3,
    hitNormal: Vec3,
    material: Material,
};

pub const Sphere = struct {
    origin: Vec3,
    radius: f32,
    material: Material,

    pub fn intersect(self: *const Sphere, ray: Ray) ?Intersection {
        const v = self.origin.subtract(ray.origin);
        const tca = v.innerProduct(ray.direction);
        if (tca < 0.0) {
            return null;
        }

        const d2 = v.lengthSquared() - tca * tca;
        if (d2 > self.radius * self.radius) {
            return null;
        }

        const thc = @sqrt(self.radius * self.radius - d2);
        const t = if (tca < thc) tca + thc else tca - thc;
        const hitPoint = ray.origin.add(ray.direction.multiply(t));
        const normal = hitPoint.subtract(self.origin).normalized();

        return Intersection{
            .t = t,
            .hitPoint = hitPoint,
            .hitNormal = normal,
            .material = self.material,
        };
    }
};
