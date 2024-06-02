// adaptation to zig 0.12.0 from https://github.com/psywave-games/pong-zig/blob/master/src/main.zig

const std = @import("std");

const raylib = @cImport({
    @cInclude("raylib.h");
});

const Player = struct {
    width: i32 = 80,
    height: i32 = 10,
    x: f32 = Game.width / 2 - (80 / 2),
    y: f32 = Game.height,

    fn update(self: *Player) void {
        const left: i2 = @intFromBool(raylib.IsKeyDown(raylib.KEY_D));
        const right: i2 = @intFromBool(raylib.IsKeyDown(raylib.KEY_A));
        const speed: f32 = @as(f32, @floatFromInt(left - right)) * raylib.GetFrameTime() * Game.speed * 3;
        const offsetX: f32 = @floatFromInt(self.width);
        self.x = @min(@max(self.x + speed, 0), @as(f32, @floatFromInt(Game.width)) - offsetX);
    }

    fn draw(self: *Player) void {
        raylib.DrawRectangle(@intFromFloat(self.x), @as(i32, @intFromFloat(self.y)) - self.height, self.width, self.height * 2, raylib.WHITE);
    }
};

const Ball = struct {
    x: f32,
    y: f32,
    hspeed: f32,
    vspeed: f32,
    size: f32 = 8.0,

    fn create() Ball {
        return Ball{ .x = Game.width / 2, .y = Game.height / 2, .hspeed = 0, .vspeed = Game.speed };
    }

    fn update(self: *Ball, game: Game) void {
        self.x += raylib.GetFrameTime() * self.hspeed;
        self.y += raylib.GetFrameTime() * self.vspeed;

        const bound_top = self.y + self.size / 2;
        const bound_right = self.x + self.size / 2;
        const bound_bottom = self.y - self.size / 2;
        const bound_left = self.x - self.size / 2;

        if (bound_bottom > game.player.y - @as(f32, @floatFromInt(game.player.height))) {
            std.debug.print("{d} {d}\n", .{ game.player.y, self.y });
            self.vspeed = -self.vspeed;
            self.hspeed = -self.hspeed;
        } else if (bound_top < 0 or bound_left < 0 or bound_right > @as(f32, @floatFromInt(Game.width))) {
            self.vspeed = -self.vspeed;
            self.hspeed = -self.hspeed;
        }
    }

    fn draw(self: Ball) void {
        raylib.DrawCircle(@intFromFloat(self.x), @intFromFloat(self.y), self.size, raylib.WHITE);
    }
};

const Game = struct {
    pub const fps: u8 = 60;
    pub const width: u16 = 800;
    pub const height: u16 = 600;
    pub const speed: f32 = 200;

    player: *Player,
    ball: *Ball,

    pub fn app() void {
        raylib.InitWindow(Game.width, Game.height, "Pong Game");
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
