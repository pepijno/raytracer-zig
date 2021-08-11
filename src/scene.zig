const std = @import("std");
const ArrayList = std.ArrayList;
const Sphere = @import("object.zig").Sphere;
const Object = @import("object.zig").Object;
const Intersection = @import("object.zig").Intersection;
const Color = @import("color.zig").Color;
const Ray = @import("ray.zig").Ray;
const Vec3 = @import("vector3.zig").Vec3;

fn max(comptime T: type, a: T, b: T) T {
    return if (a > b) a else b;
}

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

    fn directIllumination(self: *const Scene, originalRayDirection: Vec3, intersection: Intersection) Color {
        var totalDiffuseColor = Color.black();
        var totalSpecularColor = Color.black();

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

            var normalFactor = max(f32, 0.0, intersection.hitNormal.innerProduct(lightDirection));
            totalDiffuseColor = totalDiffuseColor.add(intersection.material.diffuseColor.multiply(normalFactor));

            var specularComponent = max(f32, 0.0, -1.0 * (lightDirection.multiply(-1.0).reflect(intersection.hitNormal).innerProduct(originalRayDirection)));
            specularComponent = @exp(intersection.material.specularExponent * @log(specularComponent));
            totalSpecularColor = totalSpecularColor.add(Color.white().multiply(specularComponent));
        }

        return totalDiffuseColor.add(totalSpecularColor);
    }

    pub fn traceRay(self: *const Scene, ray: Ray, depth: u8) Color {
        if (self.intersectAny(ray)) |intersection| {
            return self.directIllumination(ray.direction, intersection);
        } else {
            return Color.black();
        }
    }
};
