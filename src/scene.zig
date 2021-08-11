const std = @import("std");
const ArrayList = std.ArrayList;
const Sphere = @import("object.zig").Sphere;
const Object = @import("object.zig").Object;
const Intersection = @import("object.zig").Intersection;
const Color = @import("color.zig").Color;
const Ray = @import("ray.zig").Ray;
const Vec3 = @import("vector3.zig").Vec3;

pub const Scene = struct {
    objects: ArrayList(Object),
    lights: ArrayList(Vec3),

    pub fn init() Scene {
        return .{
            .objects = ArrayList(Object).init(std.testing.allocator),
            .lights = ArrayList(Vec3).init(std.testing.allocator),
        };
    }

    pub fn deinit(self: *Scene) void {
        self.objects.deinit();
        self.lights.deinit();
    }

    fn intersectAny(self: *const Scene, ray: Ray) ?Intersection {
        var inter: ?Intersection = null;
        var closest: f32 = 10000000000.0;

        for (self.objects.items) |object| {
            if (object.intersect(ray)) |intersection| {
                if (intersection.t < closest) {
                    closest = intersection.t;
                    inter = intersection;
                }
            }
        }

        return inter;
    }

    fn directIllumination(self: *const Scene, intersection: Intersection) Color {
        var totalDiffuseColor: Color = Color.black();

        for (self.lights.items) |light| {
            const lightDirection = light.subtract(intersection.hitPoint).normalized();
            const ray = Ray{
                .origin = intersection.hitPoint.add(lightDirection.multiply(1e-4)),
                .direction = lightDirection,
            };

            if (self.intersectAny(ray)) |newIntersection| {
                if (newIntersection.hitPoint.subtract(intersection.hitPoint).lengthSquared() < light.subtract(intersection.hitPoint).lengthSquared()) {
                    continue;
                }
            }

            var normalFactor = intersection.hitNormal.innerProduct(lightDirection);
            normalFactor = if (normalFactor > 0.0) normalFactor else 0.0;
            totalDiffuseColor = totalDiffuseColor.add(intersection.material.color.multiply(normalFactor));
        }

        return totalDiffuseColor;
    }

    pub fn traceRay(self: *const Scene, ray: Ray, depth: u8) Color {
        if (self.intersectAny(ray)) |intersection| {
            return self.directIllumination(intersection);
        } else {
            return Color.black();
        }
    }
};
