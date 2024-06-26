// https://leetcode.com/problems/text-justification/description/?envType=study-plan-v2&envId=top-interview-150

const std = @import("std");
const Allocator = std.mem.Allocator;

fn countLineSize(words: [][]const u8) usize {
    var count: usize = words.len - 1;
    for (words) |word| {
        count += word.len;
    }
    return count;
}

fn justifyEvenly(allocator: Allocator, words: [][]const u8, max_width: usize) ![]const u8 {
    if (words.len <= 1) return justifyLeft(allocator, words, max_width);

    var line = try allocator.alloc(u8, max_width);

    var word_width: usize = 0;
    for (words) |word| {
        word_width += word.len;
    }

    const space_slots = words.len - 1;
    const total_spaces = max_width - word_width;
    const spacing = @divFloor(total_spaces, space_slots);

    var i: usize = 0;
    for (words, 0..) |word, j| {
        for (word, 0..) |char, k| {
            line[i + k] = char;
        }
        i += word.len;

        if (j < words.len - 1) {
            const extra_spaces = total_spaces % space_slots;
            const space = if (j < extra_spaces) spacing + 1 else spacing;

            for (0..space) |k| {
                line[i + k] = ' ';
            }
            i += space;
        }
    }

    return line;
}

fn justifyLeft(allocator: Allocator, words: [][]const u8, max_width: usize) ![]const u8 {
    var line = try allocator.alloc(u8, max_width);

    var i: usize = 0;
    for (words, 0..) |word, j| {
        for (word, 0..) |char, k| {
            line[i + k] = char;
        }
        i += word.len;

        if (j < words.len - 1) {
            line[i] = ' ';
            i += 1;
        }
    }

    for (i..max_width) |j| {
        line[j] = ' ';
    }

    return line;
}

fn justifyLines(allocator: Allocator, words: [][]const u8, max_width: usize) !std.ArrayList([]const u8) {
    var lines = std.ArrayList([]const u8).init(allocator);

    var word_index: usize = 0;

    while (word_index < words.len) {
        var line_words = std.ArrayList([]const u8).init(allocator);
        defer line_words.deinit();

        var next_word_index = word_index;

        while (next_word_index < words.len) {
            const word = words[next_word_index];
            try line_words.append(word);
            next_word_index += 1;
            if (countLineSize(line_words.items) > max_width) {
                _ = line_words.pop();
                next_word_index -= 1;
                break;
            }
        }

        word_index = next_word_index;

        const justified_line = try if (next_word_index == words.len) justifyLeft(allocator, line_words.items, max_width) else justifyEvenly(allocator, line_words.items, max_width);
        try lines.append(justified_line);
    }

    return lines;
}

test "challenge case 1" {
    const allocator = std.testing.allocator;

    var words = [_][]const u8{ "This", "is", "an", "example", "of", "text", "justification." };
    const result = try justifyLines(allocator, &words, 16);
    defer {
        for (result.items) |item| {
            result.allocator.free(item);
        }
        result.deinit();
    }
    const expected = [_][]const u8{ "This    is    an", "example  of text", "justification.  " };

    for (result.items, expected) |result_line, expected_line| {
        try std.testing.expectEqualStrings(expected_line, result_line);
    }
}

test "challenge case 2" {
    const allocator = std.testing.allocator;

    var words = [_][]const u8{ "What", "must", "be", "acknowledgment", "shall", "be" };
    const result = try justifyLines(allocator, &words, 16);
    defer {
        for (result.items) |item| {
            result.allocator.free(item);
        }
        result.deinit();
    }
    const expected = [_][]const u8{ "What   must   be", "acknowledgment  ", "shall be        " };

    for (result.items, expected) |result_line, expected_line| {
        try std.testing.expectEqualStrings(expected_line, result_line);
    }
}

test "challenge case 3" {
    const allocator = std.testing.allocator;

    var words = [_][]const u8{ "Science", "is", "what", "we", "understand", "well", "enough", "to", "explain", "to", "a", "computer.", "Art", "is", "everything", "else", "we", "do" };
    const result = try justifyLines(allocator, &words, 20);
    defer {
        for (result.items) |item| {
            result.allocator.free(item);
        }
        result.deinit();
    }
    const expected = [_][]const u8{ "Science  is  what we", "understand      well", "enough to explain to", "a  computer.  Art is", "everything  else  we", "do                  " };

    for (result.items, expected) |result_line, expected_line| {
        try std.testing.expectEqualStrings(expected_line, result_line);
    }
}
