const std = @import("std");
const raylib = @cImport({
    @cInclude("raylib.h");
});
const print = std.debug.print;

const BLACK = raylib.Color{ .r = 0x0, .g = 0x0, .b = 0x0, .a = 0x0 };
const RED = raylib.Color{ .r = 0xFF, .g = 0x0, .b = 0x0, .a = 0x0 };

const Player = struct {
    position: u32 = 0,

    pub fn draw(self: Player) void {
        raylib.DrawRectangle(20, @intCast(self.position), 20, 100, BLACK);
    }
};

const Game = struct {
    width: u32 = 800,
    height: u32 = 600,
    target_fps: u8 = 30,
    player: Player,

    pub fn init() Game {
        var game = Game{ .player = Player{} };
        game.player.position = game.height / 2;
        return game;
    }

    pub fn run(self: Game) void {
        raylib.InitWindow(@intCast(self.width), @intCast(self.height), "Game");
        raylib.SetTargetFPS(@intCast(self.target_fps));
        while (!raylib.WindowShouldClose()) {
            raylib.BeginDrawing();
            defer raylib.EndDrawing();
            raylib.ClearBackground(RED);
            self.player.draw();
            print("{}\n", .{self.player.position});
        }
    }
};

pub fn main() !void {
    const game = Game.init();
    game.run();
}
