local file = io.open("test.txt", "r")
local content = file:read("*all")
file:close()


local words = {}
for word in content:gmatch("%S+") do
    table.insert(words, word:lower())
end

local frequencies = {}
for _, word in ipairs(words) do
    frequencies[word] = (frequencies[word] or 0) + 1
end

local sorted_words = {}
for word, frequencies in pairs(frequencies) do
    table.insert(sorted_words, {word = word, frequencies = frequencies})
end
table.sort(sorted_words, function (a, b) return a.frequencies > b.frequencies end)


print("Most used words:")
for i=1, 10 do
    print(sorted_words[i].word, sorted_words[i].frequencies)
end

