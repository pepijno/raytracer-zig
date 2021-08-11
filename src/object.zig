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

pub const Object = union(enum) {
    sphere: Sphere,
    plane: Plane,

    pub fn intersect(self: Object, ray: Ray) ?Intersection {
        return switch (self) {
            Object.sphere => |sphere| sphere.intersect(ray),
            Object.plane => |plane| plane.intersect(ray),
        };
    }
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

pub const Plane = struct {
    position: Vec3,
    normal: Vec3,
    material: Material,

    pub fn intersect(self: *const Plane, ray: Ray) ?Intersection {
        const denominator = self.normal.innerProduct(ray.direction);
        if (@fabs(denominator) < 1e-4) {
            return null;
        }

        const plane = self.position.subtract(ray.origin);
        const t = plane.innerProduct(self.normal) / denominator;

        if (t < 0.0) {
            return null;
        }

        const hitPoint = ray.origin.add(ray.direction.multiply(t));
        const normal = if (denominator < 0.0) self.normal else self.normal.multiply(-1.0);

        return Intersection{
            .t = t,
            .hitPoint = hitPoint,
            .hitNormal = normal,
            .material = self.material,
        };
    }
};
