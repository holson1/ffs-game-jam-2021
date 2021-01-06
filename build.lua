-- Build script for Pico8 Development

local Config = require("config")

local sec = "__preamble__"

-- the main sections of a pico8 cart
local sections_ordered = {
    "__preamble__",
    "__lua__",
    "__gfx__",
    "__gff__",
    "__map__",
    "__sfx__",
    "__music__"
}

local sections = {}
for i,each in ipairs(sections_ordered) do
    sections[each] = {}
end

-- reading
-- cart data
local cart_in = io.open(Config.cart_path, "r")
for line in cart_in:lines() do
    if sections[line] ~= nil then
        sec = line
    end

    table.insert(sections[sec], line)
end

io.close(cart_in)

-- src lua files
sections.__lua__ = {'__lua__'}
for _,source_path in ipairs(Config.sourceFiles) do
    table.insert(sections.__lua__, "--" .. source_path)

    local lua_file = io.open(source_path, "r")
    for line in lua_file:lines() do
        table.insert(sections.__lua__, line)
    end

    table.insert(sections.__lua__, "-->8")
end

-- writing

local cart_out = io.open(Config.cart_path, "w")
io.output(cart_out)

for i,section in ipairs(sections_ordered) do
    print("Writing section: " .. section)

    for _i,v in ipairs(sections[section]) do
        io.write(v)
        io.write("\n")
    end
end

io.close(cart_out)