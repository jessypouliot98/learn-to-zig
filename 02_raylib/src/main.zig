// adaptation to zig 0.12.0 from https://github.com/psywave-games/pong-zig/blob/master/src/main.zig

const raylib = @cImport({
    @cInclude("raylib.h");
});

const Game = struct {
    const fps: u8 = 60;
    const width: u16 = 800;
    const height: u16 = 600;
    const min_spd: f32 = 200;
    const max_spd: f32 = 800;

    const Player = struct {
        x: f32 = 0.0,
        y: f32 = Game.height / 2,
        width: i32 = 10,
        height: i32 = 80,

        fn update(self: *Player) void {
            const down: i2 = @intFromBool(raylib.IsKeyDown(raylib.KEY_DOWN));
            const up: i2 = @intFromBool(raylib.IsKeyDown(raylib.KEY_UP));
            const speed: f32 = @as(f32, @floatFromInt(down - up)) * raylib.GetFrameTime() * Game.min_spd * 3;
            self.y = @min(@max(self.y + speed, 0), Game.height);
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
            return Ball{ .x = Game.width / 2, .y = Game.height / 2, .hspeed = -Game.min_spd, .vspeed = 0 };
        }

        fn update(self: *Ball) void {
            self.x += raylib.GetFrameTime() * self.hspeed;
            self.y += raylib.GetFrameTime() * self.vspeed;
        }

        fn draw(self: Ball) void {
            raylib.DrawCircle(@intFromFloat(self.x), @intFromFloat(self.y), self.size, raylib.WHITE);
        }
    };

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
        self.ball.update();
    }

    fn draw(self: Game) void {
        raylib.BeginDrawing();

        raylib.ClearBackground(raylib.BLACK);
        self.player.draw();
        self.ball.draw();

        raylib.EndDrawing();
    }

    player: *Player,
    ball: *Ball,
};

pub fn main() anyerror!void {
    Game.app();
}
