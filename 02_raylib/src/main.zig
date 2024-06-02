const std = @import("std");
const raylib = @cImport({
    @cInclude("raylib.h");
});
const print = std.debug.print;

const BLACK = raylib.Color{ .r = 0x0, .g = 0x0, .b = 0x0, .a = 0xFF };
const WHITE = raylib.Color{ .r = 0xFF, .g = 0xFF, .b = 0xFF, .a = 0xFF };
const RED = raylib.Color{ .r = 0xFF, .g = 0x0, .b = 0x0, .a = 0xFF };

const Ball = struct {};

const Player = struct {
    pub const WIDTH = 100;
    pub const HEIGHT = 20;
    position_x: i32 = 0,
    position_y: i32 = 0,

    pub fn update(self: *Player) void {
        const speed = 10;
        if (raylib.IsKeyDown(raylib.KEY_S)) {
            self.position_y = @min(600 - Player.HEIGHT, self.position_y + speed);
        }
        if (raylib.IsKeyDown(raylib.KEY_W)) {
            self.position_y = @max(0, self.position_y - speed);
        }
        if (raylib.IsKeyDown(raylib.KEY_D)) {
            self.position_x = @min(800 - Player.WIDTH, self.position_x + speed);
        }
        if (raylib.IsKeyDown(raylib.KEY_A)) {
            self.position_x = @max(0, self.position_x - speed);
        }
    }

    pub fn draw(self: Player) void {
        raylib.DrawRectangle(@intCast(self.position_x), @intCast(self.position_y), Player.WIDTH, Player.HEIGHT, RED);
        print("x: {d}; y: {d};\n", .{ self.position_x, self.position_y });
    }
};

const Game = struct {
    width: u32 = 800,
    height: u32 = 600,
    target_fps: u8 = 60,
    player: *Player,
    ball: *Ball,

    pub fn init() Game {
        var player = Player{};
        var ball = Ball{};
        const game = Game{
            .player = &player,
            .ball = &ball,
        };
        game.player.*.position_x = @intCast(game.width / 2);
        game.player.*.position_y = @intCast(game.height / 2);
        return game;
    }

    pub fn run(self: Game) void {
        raylib.InitWindow(@intCast(self.width), @intCast(self.height), "Game");
        raylib.SetTargetFPS(@intCast(self.target_fps));
        while (!raylib.WindowShouldClose()) {
            self.update();
            self.draw();
        }
    }

    pub fn update(self: Game) void {
        self.player.update();
    }

    pub fn draw(self: Game) void {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(BLACK);
        self.player.draw();
    }
};

pub fn main() !void {
    var game = Game.init();
    game.run();
}
