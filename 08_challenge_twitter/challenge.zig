// https://leetcode.com/problems/design-twitter/description/

const std = @import("std");
const Allocator = std.mem.Allocator;

const Twitter = struct {
    allocator: Allocator,
    follower_followees_map: std.AutoArrayHashMap(u32, std.AutoHashMap(u32, void)),
    tweets_user_map: std.AutoArrayHashMap(u32, u32),

    pub fn init(allocator: Allocator) Twitter {
        return Twitter{
            .allocator = allocator,
            .follower_followees_map = std.AutoArrayHashMap(u32, std.AutoHashMap(u32, void)).init(allocator),
            .tweets_user_map = std.AutoArrayHashMap(u32, u32).init(allocator),
        };
    }

    pub fn deinit(self: *Twitter) void {
        var follower_followees_iterator = self.follower_followees_map.iterator();
        while (follower_followees_iterator.next()) |follower_followees| {
            follower_followees.value_ptr.*.clearAndFree();
            follower_followees.value_ptr.*.deinit();
        }
        self.follower_followees_map.clearAndFree();
        self.follower_followees_map.deinit();

        self.tweets_user_map.clearAndFree();
        self.tweets_user_map.deinit();
    }

    pub fn postTweet(self: *Twitter, user_id: u32, tweet_id: u32) !void {
        try self.tweets_user_map.put(tweet_id, user_id);
    }

    pub fn getNewsFeed(self: *Twitter, user_id: u32) !std.ArrayList(u32) {
        var feed = std.ArrayList(u32).init(self.allocator);

        const followees = self.follower_followees_map.get(user_id);

        var tweet_user_iterator = self.tweets_user_map.iterator();
        while (tweet_user_iterator.next()) |tweet_user| {
            if (tweet_user.value_ptr.* == user_id) {
                try feed.append(tweet_user.key_ptr.*);
            } else if (followees != null and followees.?.contains(tweet_user.value_ptr.*)) {
                // Debug
                try feed.append(tweet_user.key_ptr.*);
            }
        }

        return feed;
    }

    pub fn follow(self: *Twitter, follower_id: u32, followee_id: u32) !void {
        var followees_map: std.AutoHashMap(u32, void) = undefined;
        if (self.follower_followees_map.get(follower_id)) |fm| {
            followees_map = fm;
        } else {
            followees_map = std.AutoHashMap(u32, void).init(self.allocator);
            try self.follower_followees_map.put(follower_id, followees_map);
        }

        try followees_map.put(followee_id, {});
    }

    pub fn unfollow(self: *Twitter, follower_id: u32, followee_id: u32) void {
        if (self.follower_followees_map.get(follower_id)) |*followees_map| {
            // Debug
            // _ = followees_map.remove(followee_id);
            _ = followees_map;
            _ = followee_id;
        }
    }
};

test "challenge" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var twitter = Twitter.init(allocator);
    defer twitter.deinit();

    try twitter.postTweet(1, 5);
    {
        var result = try twitter.getNewsFeed(1);
        defer result.deinit();
        try std.testing.expectEqualSlices(
            u32,
            &.{5},
            result.items,
        );
    }

    try twitter.follow(1, 2);
    try twitter.postTweet(2, 6);
    {
        var result = try twitter.getNewsFeed(1);
        defer result.deinit();
        try std.testing.expectEqualSlices(
            u32,
            &.{ 6, 5 },
            result.items,
        );
    }

    twitter.unfollow(1, 2);
    {
        var result = try twitter.getNewsFeed(1);
        defer result.deinit();
        try std.testing.expectEqualSlices(
            u32,
            &.{5},
            result.items,
        );
    }
}
