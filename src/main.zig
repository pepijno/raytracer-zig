const std = @import("std");
const Vec3 = @import("vector3.zig").Vec3;
const Camera = @import("camera.zig").Camera;
const Ray = @import("ray.zig").Ray;
const Scene = @import("scene.zig").Scene;
const Obj = @import("object.zig");
const Material = @import("color.zig").Material;
const Color = @import("color.zig").Color;
const Sphere = Obj.Sphere;
const Object = Obj.Object;

const c = @cImport({
    @cInclude("SDL.h");
});

const SDL_WINDOWPOS_UNDEFINED = @bitCast(c_int, c.SDL_WINDOWPOS_UNDEFINED_MASK);

const size: c_int = 200;
const aspectRatio = 2.0;
const windowHeight: c_int = 2 * size;
const windowWidth: c_int = @floatToInt(c_int, 2.0 * aspectRatio) * size;
const num_threads: i32 = 16;
const num_samples: i32 = 256;
const max_depth: i32 = 16;

// For some reason, this isn't parsed automatically. According to SDL docs, the
// surface pointer returned is optional!
extern fn SDL_GetWindowSurface(window: *c.SDL_Window) ?*c.SDL_Surface;
fn setPixel(surf: *c.SDL_Surface, x: c_int, y: c_int, pixel: u32) void {
    const target_pixel = @ptrToInt(surf.pixels) +
        @intCast(usize, y) * @intCast(usize, surf.pitch) +
        @intCast(usize, x) * 4;
    @intToPtr(*u32, target_pixel).* = pixel;
}

pub fn main() anyerror!void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    const window = c.SDL_CreateWindow("weekend raytracer", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, windowWidth, windowHeight, c.SDL_WINDOW_OPENGL) orelse {
        c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };

    const surface = SDL_GetWindowSurface(window) orelse {
        c.SDL_Log("Unable to get window surface: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };

    const origin: Vec3 = .{ .x = 0.0, .y = 1.0, .z = -6.0 };
    const lookAt: Vec3 = .{ .x = 0.0, .y = 1.0, .z = 0.0 };
    const vup: Vec3 = .{ .x = 0.0, .y = 1.0, .z = 0.0 };
    const focusDistance: f32 = @sqrt(origin.subtract(lookAt).lengthSquared());
    const fieldOfView: f32 = 90.0;
    const aperture: f32 = 0.8;
    const camera: Camera = Camera.new(origin, lookAt, vup, fieldOfView, aspectRatio, aperture, focusDistance);

    var scene: Scene = Scene.init();
    defer scene.deinit();

    const ivory = Material{
        .diffuseColor = .{ .red = 0.1, .green = 0.1, .blue = 0.15 },
        .reflectColor = .{ .red = 0.85, .green = 0.85, .blue = 0.85 },
        .specularExponent = 50.0,
    };

    const rubber = Material{
        .diffuseColor = .{ .red = 0.3, .green = 0.1, .blue = 0.1 },
        .reflectColor = Color.black(),
        .specularExponent = 1000000000000.0,
    };

    try scene.objects.append(Object{
        .sphere = .{
            .origin = .{
                .x = 0.0,
                .y = 1.0,
                .z = 0.0,
            },
            .radius = 2.0,
            .material = ivory,
        },
    });
    try scene.objects.append(Object{
        .sphere = .{
            .origin = .{
                .x = 4.0,
                .y = 1.0,
                .z = 2.0,
            },
            .radius = 2.0,
            .material = ivory,
        },
    });
    try scene.objects.append(Object{
        .plane = .{
            .position = .{
                .x = 0.0,
                .y = -1.0,
                .z = 0.0,
            },
            .normal = .{
                .x = 0.0,
                .y = 1.0,
                .z = 0.0,
            },
            .material = rubber,
        },
    });
    try scene.lights.append(.{
        .x = 5.0,
        .y = 2.0,
        .z = -3.0,
    });

    var y: i32 = 0;
    while (y < windowHeight) : (y += 1) {
        var x: i32 = 0;
        while (x < windowWidth) : (x += 1) {
            const a: f32 = @intToFloat(f32, x) / @intToFloat(f32, windowWidth);
            const b: f32 = @intToFloat(f32, y) / @intToFloat(f32, windowHeight);

            const ray = camera.createRay(a, b);

            const color = scene.traceRay(ray, 0);
            setPixel(surface, x, windowHeight - y - 1, color.toBgra());
        }
    }

    if (c.SDL_UpdateWindowSurface(window) != 0) {
        c.SDL_Log("Error updating window surface: %s", c.SDL_GetError());
        return error.SDLUpdateWindowFailed;
    }

    var running = true;
    while (running) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.@"type") {
                c.SDL_QUIT => {
                    running = false;
                },
                else => {},
            }
        }

        c.SDL_Delay(16);
    }

    // std.log.info("All your codebase are belong to us.", .{});
}
