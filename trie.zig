// https://github.com/Koura/algorithms/blob/main/search_trees/trie.zig

const std = @import("std");
const expect = std.testing.expect;
const Allocator = std.mem.Allocator;

const TrieNode = struct {
    nodes: std.AutoHashMap(u8, *TrieNode),
    isEnd: bool,

    pub fn init(allocator: *const Allocator) !*TrieNode {
        var node = try allocator.create(TrieNode);
        node.nodes = std.AutoHashMap(u8, *TrieNode).init(allocator.*);
        node.isEnd = false;
        return node;
    }
};

const Trie = struct {
    root: *TrieNode,

    pub fn init(allocator: *const Allocator) !Trie {
        const node = try TrieNode.init(allocator);
        return Trie{ .root = node };
    }

    pub fn insert(self: *Trie, key: []const u8, allocator: *const Allocator) !void {
        var node = self.root;
        for (key) |char| {
            if (!node.nodes.contains(char)) {
                const new_node = try TrieNode.init(allocator);
                try node.nodes.put(char, new_node);
            }
            node = node.nodes.get(char).?;
        }
        node.isEnd = true;
    }

    //Returns true if the word is present in the trie
    pub fn search(self: *Trie, key: []const u8) bool {
        var node = self.root;
        for (key) |char| {
            if (node.nodes.contains(char)) {
                node = node.nodes.get(char).?;
            } else {
                return false;
            }
        }
        return node.isEnd;
    }
};

test "search empty tree" {
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_allocator.deinit();
    const allocator = &arena_allocator.allocator();
    var tree = try Trie.init(allocator);
    const result = tree.search("car");
    try expect(result == false);
}

test "search existing element" {
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_allocator.deinit();
    const allocator = &arena_allocator.allocator();
    var tree = try Trie.init(allocator);
    try tree.insert("car", allocator);
    const result = tree.search("car");
    try expect(result == true);
}

test "search non-existing element" {
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_allocator.deinit();
    const allocator = &arena_allocator.allocator();
    var tree = try Trie.init(allocator);
    try tree.insert("car", allocator);
    var result = tree.search("There is no trie");
    try expect(result == false);
    //Make sure that partial matches are not marked as present
    result = tree.search("ca");
    try expect(result == false);
}

test "search with multiple words present" {
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_allocator.deinit();
    const allocator = &arena_allocator.allocator();
    var tree = try Trie.init(allocator);
    const words = [_][]const u8{
        "A", "to", "tea", "ted", "ten", "i", "in", "inn",
    };
    for (words) |word| {
        try tree.insert(word, allocator);
    }
    for (words) |word| {
        const result = tree.search(word);
        try expect(result == true);
    }
    //Root should have 'A', 't' and 'i' as its nodes
    try expect(tree.root.nodes.count() == 3);
}
