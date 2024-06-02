// adaptation to zig 0.12.0 from https://github.com/psywave-games/pong-zig/blob/master/src/main.zig

const std = @import("std");

const raylib = @cImport({
    @cInclude("raylib.h");
});

const Bounds = struct {
    x1: f32,
    x2: f32,
    y1: f32,
    y2: f32,
};

const Box2D = struct {
    pub const Border = enum {
        top,
        right,
        bottom,
        left,
    };

    width: f32,
    height: f32,
    center_x: f32,
    center_y: f32,

    pub fn get_bounds(self: Box2D) Bounds {
        const half_width: f32 = (self.width / 2);
        const half_height: f32 = (self.height / 2);
        return Bounds{
            .x1 = self.center_x - half_width,
            .x2 = self.center_x + half_width,
            .y1 = self.center_y - half_height,
            .y2 = self.center_y + half_height,
        };
    }

    pub fn has_intersection(self: Box2D, other: Box2D) bool {
        const self_box = self.get_bounds();
        const other_box = other.get_bounds();
        return (self_box.x1 < other_box.x2 and
            self_box.x2 > other_box.x1 and
            self_box.y1 < other_box.y2 and
            self_box.y2 > other_box.y1);
    }

    // TODO Handle mutliple border intersection
    pub fn get_border_intersection(self: Box2D, other: Box2D) ?Box2D.Border {
        const self_box = self.get_bounds();
        const other_box = other.get_bounds();

        if (self_box.y1 < other_box.y1 and self_box.y2 > other_box.y1) {
            return Box2D.Border.top;
        } else if (self_box.x1 < other_box.x2 and self_box.x2 > other_box.x2) {
            return Box2D.Border.right;
        } else if (self_box.y1 < other_box.y2 and self_box.y2 > other_box.y2) {
            return Box2D.Border.bottom;
        } else if (self_box.x1 < other_box.x1 and self_box.x2 > other_box.x1) {
            return Box2D.Border.left;
        }
        return null;
    }
};

const Player = struct {
    const Width: f32 = 120;
    const Height: f32 = 15;

    width: f32 = Player.Width,
    height: f32 = Player.Height,
    x: f32 = Game.width / 2 - (Player.Width / 2) - 10,
    y: f32 = Game.height,

    pub fn get_box_2d(self: Player) Box2D {
        return Box2D{
            .center_x = self.x + self.width / 2,
            .center_y = self.y + self.height / 2,
            .width = self.width,
            .height = self.height,
        };
    }

    fn update(self: *Player) void {
        const left: i2 = @intFromBool(raylib.IsKeyDown(raylib.KEY_D));
        const right: i2 = @intFromBool(raylib.IsKeyDown(raylib.KEY_A));
        const speed: f32 = @as(f32, @floatFromInt(left - right)) * raylib.GetFrameTime() * Game.speed * 3;
        self.x = @min(@max(self.x + speed, 0), @as(f32, @floatFromInt(Game.width)) - self.width);
    }

    fn draw(self: *Player) void {
        raylib.DrawRectangle(
            @intFromFloat(self.x),
            @as(i32, @intFromFloat(self.y)) - @as(i32, @intFromFloat(self.height)),
            @as(i32, @intFromFloat(self.width)),
            @as(i32, @intFromFloat(self.height * 2)),
            raylib.WHITE,
        );
    }
};

const Ball = struct {
    x: f32,
    y: f32,
    hspeed: f32,
    vspeed: f32,
    size: f32 = 8.0,

    pub fn create() Ball {
        const angle_deg: f32 = 190;
        const angle_rad: f32 = std.math.degreesToRadians(angle_deg);
        std.debug.print("start a: {d}\n", .{angle_deg});
        return Ball{
            .x = Game.width / 2,
            .y = Game.height / 2,
            .hspeed = std.math.cos(angle_rad) * Game.speed,
            .vspeed = std.math.sin(angle_rad) * Game.speed,
        };
    }

    pub fn get_box_2d(self: *Ball) Box2D {
        return Box2D{
            .center_x = self.x,
            .center_y = self.y,
            .width = self.size,
            .height = self.size,
        };
    }

    fn get_angle_rad(self: Ball) f32 {
        return std.math.asin(self.vspeed / Game.speed);
    }

    fn apply_speed_from_angle(self: *Ball, angle_rad: f32) void {
        self.vspeed = std.math.sin(angle_rad) * Game.speed;
        self.hspeed = std.math.cos(angle_rad) * Game.speed;
    }

    pub fn update(self: *Ball, game: Game) void {
        self.x += raylib.GetFrameTime() * self.hspeed;
        self.y += raylib.GetFrameTime() * self.vspeed;

        const box = self.get_box_2d();
        const game_box = game.get_box_2d();
        const player_box = game.player.get_box_2d();

        const game_border_intersection = box.get_border_intersection(game_box);
        if (game_border_intersection != null) {
            const angle = self.get_angle_rad();
            switch (game_border_intersection.?) {
                .top => {
                    const adjustment_angle: f32 = -std.math.pi * 0.5;
                    const i_angle: f32 = angle + adjustment_angle;
                    const r_angle: f32 = (std.math.pi * 0.5) - i_angle;
                    std.debug.print("[top] i: {d}; r: {d}\n", .{ std.math.radiansToDegrees(i_angle), std.math.radiansToDegrees(r_angle) });
                    self.apply_speed_from_angle(r_angle + adjustment_angle);
                },
                .left => {
                    const adjustment_angle: f32 = -std.math.pi;
                    const i_angle: f32 = angle + adjustment_angle;
                    const r_angle: f32 = (-std.math.pi * 0.5) - i_angle;
                    std.debug.print("[left] i: {d}; r: {d}\n", .{ std.math.radiansToDegrees(i_angle), std.math.radiansToDegrees(r_angle) });
                    self.apply_speed_from_angle(r_angle + adjustment_angle);
                },
                .right => {
                    const adjustment_angle: f32 = -std.math.pi;
                    const i_angle: f32 = angle + adjustment_angle;
                    const r_angle: f32 = (-std.math.pi * 0.5) - i_angle;
                    std.debug.print("[right] i: {d}; r: {d}\n", .{ std.math.radiansToDegrees(i_angle), std.math.radiansToDegrees(r_angle) });
                    self.apply_speed_from_angle(r_angle + adjustment_angle);
                },
                else => {},
            }
        } else if (box.has_intersection(player_box)) {
            const angle: f32 = std.math.atan2(box.center_y - player_box.center_y - 30, box.center_x - player_box.center_x);
            self.apply_speed_from_angle(angle);
        }
    }

    fn draw(self: Ball) void {
        raylib.DrawCircle(@intFromFloat(self.x), @intFromFloat(self.y), self.size, raylib.WHITE);
    }
};

const Game = struct {
    pub const fps: u16 = 60;
    pub const width: u16 = 800;
    pub const height: u16 = 600;
    pub const speed: f32 = 300;

    pub const Error = error{
        GameOver,
    };

    player: *Player,
    ball: *Ball,

    pub fn app() void {
        raylib.InitWindow(Game.width, Game.height, "Block Breaker");
        raylib.SetTargetFPS(Game.fps);

        var player = Player{};
        var ball = Ball.create();

        var application = Game{ .player = &player, .ball = &ball };

        while (!raylib.WindowShouldClose()) {
            application.update();
            application.draw();
        }

        raylib.CloseWindow();
    }

    pub fn get_box_2d(self: Game) Box2D {
        _ = self;
        return Box2D{
            .center_x = @floatFromInt(Game.width / 2),
            .center_y = @floatFromInt(Game.height / 2),
            .width = @floatFromInt(Game.width),
            .height = @floatFromInt(Game.height),
        };
    }

    fn update(self: Game) void {
        self.player.update();
        self.ball.update(self);
    }

    fn draw(self: Game) void {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.BLACK);
        self.player.draw();
        self.ball.draw();
    }
};

pub fn main() anyerror!void {
    Game.app();
}
