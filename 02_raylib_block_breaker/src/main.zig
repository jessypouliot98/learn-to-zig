// adaptation to zig 0.12.0, then converted to a brick breaker game from https://github.com/psywave-games/pong-zig/blob/master/src/main.zig

const std = @import("std");

const raylib = @cImport({
    @cInclude("raylib.h");
});

const HALF_PI: f32 = std.math.pi / 2.0;

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

const Brick = struct {
    const Width: f32 = Game.width / Game.brick_cols;
    const Height: f32 = Game.height / Game.brick_rows;

    width: f32 = Brick.Width,
    height: f32 = Brick.Height,
    x: f32,
    y: f32,

    pub fn get_box_2d(self: Brick) Box2D {
        return Box2D{
            .center_x = self.x + self.width / 2,
            .center_y = self.y + self.height / 2,
            .width = self.width,
            .height = self.height,
        };
    }

    fn draw(self: Brick) void {
        raylib.DrawRectangle(@intFromFloat(self.x), @intFromFloat(self.y), @intFromFloat(self.width), @intFromFloat(self.height), raylib.WHITE);
        raylib.DrawRectangleLines(@intFromFloat(self.x), @intFromFloat(self.y), @intFromFloat(self.width), @intFromFloat(self.height), raylib.BLACK);
    }
};

const Ball = struct {
    x: f32,
    y: f32,
    hspeed: f32,
    vspeed: f32,
    size: f32 = 8.0,
    is_colliding: bool = false,

    pub fn create() Ball {
        const angle_deg: f32 = 270;
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
        var angle: f32 = std.math.acos(self.hspeed / Game.speed);
        while (angle < 0) angle += std.math.pi * 2;
        while (angle > std.math.pi * 2) angle -= std.math.pi * 2;
        return angle;
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

        if (self.is_colliding) {
            self.is_colliding = box.has_intersection(player_box) or box.get_border_intersection(game_box) != null;
            return;
        }

        if (box.has_intersection(player_box)) {
            self.is_colliding = true;
            const angle: f32 = std.math.atan2(box.center_y - player_box.center_y - 30, box.center_x - player_box.center_x);
            std.debug.print("player: {d}\n", .{std.math.radiansToDegrees(angle)});
            self.apply_speed_from_angle(angle);
            return;
        }

        for (game.bricks.items, 0..) |brick, i| {
            if (box.has_intersection(brick.get_box_2d())) {
                _ = game.bricks.orderedRemove(i);
                const angle = self.get_angle_rad();
                const i_angle: f32 = HALF_PI - angle;
                const r_angle: f32 = HALF_PI - i_angle;
                std.debug.print("[brick] i: {d}; r: {d}\n", .{ std.math.radiansToDegrees(i_angle), std.math.radiansToDegrees(r_angle) });
                self.apply_speed_from_angle(r_angle);
            }
        }

        const game_border_intersection = box.get_border_intersection(game_box);
        if (game_border_intersection != null) {
            self.is_colliding = true;
            const angle = self.get_angle_rad();
            switch (game_border_intersection.?) {
                .top => {
                    const i_angle: f32 = HALF_PI - angle;
                    const r_angle: f32 = HALF_PI - i_angle;
                    std.debug.print("[top] i: {d}; r: {d}\n", .{ std.math.radiansToDegrees(i_angle), std.math.radiansToDegrees(r_angle) });
                    self.apply_speed_from_angle(r_angle);
                },
                .left => {
                    const i_angle: f32 = (HALF_PI * 2) - angle;
                    const r_angle: f32 = HALF_PI - i_angle;
                    std.debug.print("[left] i: {d}; r: {d}\n", .{ std.math.radiansToDegrees(i_angle), std.math.radiansToDegrees(r_angle) });
                    self.apply_speed_from_angle(r_angle);
                },
                .right => {
                    const i_angle: f32 = (HALF_PI * 4) - angle;
                    const r_angle: f32 = HALF_PI - i_angle;
                    std.debug.print("[right] i: {d}; r: {d}\n", .{ std.math.radiansToDegrees(i_angle), std.math.radiansToDegrees(r_angle) });
                    self.apply_speed_from_angle(r_angle);
                },
                else => {},
            }
            return;
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
    pub const brick_cols: u8 = 8;
    pub const brick_rows: u8 = 14;
    pub const brick_rows_used: u8 = 5;

    pub const Error = error{
        GameOver,
    };

    allocator: std.mem.Allocator,
    player: *Player,
    ball: *Ball,
    bricks: *std.ArrayList(Brick),

    pub fn app(allocator: std.mem.Allocator) !void {
        raylib.InitWindow(Game.width, Game.height, "Block Breaker");
        raylib.SetTargetFPS(Game.fps);

        var player = Player{};
        var ball = Ball.create();
        var bricks = std.ArrayList(Brick).init(allocator);
        defer bricks.deinit();

        var row: i8 = 0;
        while (row < Game.brick_rows_used) : (row += 1) {
            var col: i8 = 0;
            while (col < Game.brick_cols) : (col += 1) {
                try bricks.append(Brick{
                    .x = @as(f32, @floatFromInt(col)) * Brick.Width,
                    .y = @as(f32, @floatFromInt(row)) * Brick.Height,
                });
            }
        }

        var application = Game{
            .allocator = allocator,
            .player = &player,
            .ball = &ball,
            .bricks = &bricks,
        };

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
        std.debug.print("Bricks left {d}\n", .{self.bricks.items.len});
    }

    fn draw(self: Game) void {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.BLACK);
        self.player.draw();
        self.ball.draw();
        for (self.bricks.items) |brick| {
            brick.draw();
        }
    }
};

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    try Game.app(allocator);
}
