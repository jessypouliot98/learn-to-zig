const std = @import("std");
const raylib = @cImport({
    @cInclude("raylib.h");
});
const print = std.debug.print;

const BLACK = raylib.Color{ .r = 0x0, .g = 0x0, .b = 0x0, .a = 0xFF };
const WHITE = raylib.Color{ .r = 0xFF, .g = 0xFF, .b = 0xFF, .a = 0xFF };
const RED = raylib.Color{ .r = 0xFF, .g = 0x0, .b = 0x0, .a = 0xFF };

const Position = struct {
    x: i32,
    y: i32,
};

const Player = struct {
    pub const WIDTH = 100;
    pub const HEIGHT = 20;

    position: Position = Position{
        .x = 0,
        .y = 0,
    },

    pub fn update(self: *Player) void {
        const speed = 10;
        if (raylib.IsKeyDown(raylib.KEY_S)) {
            self.position.y = @min(600 - Player.HEIGHT, self.position.y + speed);
        }
        if (raylib.IsKeyDown(raylib.KEY_W)) {
            self.position.y = @max(0, self.position.y - speed);
        }
        if (raylib.IsKeyDown(raylib.KEY_D)) {
            self.position.x = @min(800 - Player.WIDTH, self.position.x + speed);
        }
        if (raylib.IsKeyDown(raylib.KEY_A)) {
            self.position.x = @max(0, self.position.x - speed);
        }
    }

    pub fn draw(self: Player) void {
        raylib.DrawRectangle(@intCast(self.position.x), @intCast(self.position.y), Player.WIDTH, Player.HEIGHT, RED);
        print("x: {d}; y: {d};\n", .{ self.position.x, self.position.y });
    }
};

const Brick = struct {
    pub const WIDTH = 100;
    pub const HEIGHT = 20;

    position: Position = Position{
        .x = 0,
        .y = 0,
    },
};

const Game = struct {
    width: u32,
    height: u32,
    target_fps: u8 = 60,
    player: *Player,
    brick: *Brick,

    pub fn init(width: u32, height: u32) Game {
        var player = Player{
            .position = Position{
                .x = @intCast(width / 2),
                .y = @intCast(height / 2),
            },
        };

        var brick = Brick{};

        const game = Game{
            .width = width,
            .height = height,
            .player = &player,
            .brick = &brick,
        };
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
    var game = Game.init(800, 600);
    game.run();
}
