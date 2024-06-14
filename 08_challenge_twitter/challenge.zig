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

    pub fn getNewsFeed(self: *Twitter, user_id: u32) ![]u32 {
        var feed_list = std.ArrayList(u32).init(self.allocator);

        const followees = self.follower_followees_map.get(user_id);

        var tweet_user_iterator = self.tweets_user_map.iterator();
        while (tweet_user_iterator.next()) |tweet_user| {
            if ((tweet_user.value_ptr.* == user_id) or
                (followees != null and followees.?.contains(tweet_user.value_ptr.*)))
            {
                try feed_list.append(tweet_user.key_ptr.*);
            }
        }

        if (feed_list.items.len <= 1) {
            return feed_list.items;
        }

        const ordered_feed = try self.allocator.alloc(u32, feed_list.items.len);
        std.debug.print("hello\n", .{});

        for (feed_list.items, 1..) |item, i| {
            ordered_feed[feed_list.items.len - i] = item;
        }
        return ordered_feed;
    }

    pub fn follow(self: *Twitter, follower_id: u32, followee_id: u32) !void {
        const followee_set = try self.follower_followees_map.getOrPut(follower_id);
        if (!followee_set.found_existing) {
            followee_set.value_ptr.* = std.AutoHashMap(u32, void).init(self.allocator);
        }
        try followee_set.value_ptr.*.put(followee_id, {});
    }

    pub fn unfollow(self: *Twitter, follower_id: u32, followee_id: u32) void {
        if (self.follower_followees_map.getEntry(follower_id)) |entry| {
            _ = entry.value_ptr.*.remove(followee_id);
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
        const result = try twitter.getNewsFeed(1);
        try std.testing.expectEqualSlices(
            u32,
            &.{5},
            result,
        );
    }

    try twitter.follow(1, 2);
    try twitter.postTweet(2, 6);
    {
        const result = try twitter.getNewsFeed(1);
        try std.testing.expectEqualSlices(
            u32,
            &.{ 6, 5 },
            result,
        );
    }

    twitter.unfollow(1, 2);
    {
        const result = try twitter.getNewsFeed(1);
        try std.testing.expectEqualSlices(
            u32,
            &.{5},
            result,
        );
    }
}
