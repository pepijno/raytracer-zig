const std = @import("std");
const testing = std.testing;

pub const Vec3 = struct {
    x: f32 = 0.0,
    y: f32 = 0.0,
    z: f32 = 0.0,

    pub fn innerProduct(self: *const Vec3, other: Vec3) f32 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }

    pub fn outerProduct(self: *const Vec3, other: Vec3) Vec3 {
        return .{
            .x = self.y * other.z - self.z * other.y,
            .y = self.z * other.x - self.x * other.z,
            .z = self.x * other.y - self.y * other.x,
        };
    }

    pub fn add(self: *const Vec3, other: Vec3) Vec3 {
        return .{
            .x = self.x + other.x,
            .y = self.y + other.y,
            .z = self.z + other.z,
        };
    }

    pub fn subtract(self: *const Vec3, other: Vec3) Vec3 {
        return .{
            .x = self.x - other.x,
            .y = self.y - other.y,
            .z = self.z - other.z,
        };
    }

    pub fn lengthSquared(self: *const Vec3) f32 {
        return self.innerProduct(self.*);
    }

    pub fn multiply(self: *const Vec3, factor: f32) Vec3 {
        return .{ .x = self.x * factor, .y = self.y * factor, .z = self.z * factor };
    }

    pub fn divide(self: *const Vec3, factor: f32) Vec3 {
        return .{ .x = self.x / factor, .y = self.y / factor, .z = self.z / factor };
    }

    pub fn normalized(self: *const Vec3) Vec3 {
        return self.divide(@sqrt(self.lengthSquared()));
    }

    pub fn reflect(self: *const Vec3, normal: Vec3) Vec3 {
        return self.subtract(normal.multiply(2.0).multiply(self.innerProduct(normal)));
    }
};

test "Vec3 innerProduct should return the inner product" {
    const vec1: Vec3 = .{ .x = 1.0, .y = 2.0, .z = 3.0 };
    const vec2: Vec3 = .{ .x = 4.0, .y = 5.0, .z = 6.0 };
    testing.expectEqual(vec1.innerProduct(vec2), 32);
}

test "Vec3 outerProduct should return the outer product" {
    const vec1: Vec3 = .{ .x = 1.0, .y = 2.0, .z = 3.0 };
    const vec2: Vec3 = .{ .x = 4.0, .y = 5.0, .z = 6.0 };
    testing.expectEqual(vec1.outerProduct(vec2), .{ .x = -3.0, .y = 6.0, .z = -3.0 });
}

test "Vec3 lengthSquared should return the squared length" {
    const vec: Vec3 = .{ .x = 2.0, .y = 3.0, .z = 4.0 };
    testing.expectEqual(vec.lengthSquared(), 29.0);
}

test "Vec3 multiply should return correct scaled vector" {
    const vec: Vec3 = .{ .x = 2.0, .y = 3.0, .z = 4.0 };
    testing.expectEqual(vec.multiply(3.0), .{ .x = 6.0, .y = 9.0, .z = 12.0 });
}

test "Vec3 divide should return correct scaled vector" {
    const vec: Vec3 = .{ .x = 2.0, .y = 3.0, .z = 4.0 };
    testing.expectEqual(vec.divide(2.0), .{ .x = 1.0, .y = 1.5, .z = 2.0 });
}

test "Vec3 normalized should return the vector normalized" {
    const vec: Vec3 = .{ .x = 2.0, .y = 3.0, .z = 6.0 };
    testing.expectEqual(vec.normalized(), .{ .x = 2.0 / 7.0, .y = 3.0 / 7.0, .z = 6.0 / 7.0 });
}
