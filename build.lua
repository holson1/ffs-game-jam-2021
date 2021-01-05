local rfile = io.open("test.p8", "r")
sec = "__preamble__"

-- the main sections of a pico8 cart
sections = {
    __preamble__ = {},
    __lua__ = {},
    __gfx__ = {},
    __gff__ = {},
    __sfx__ = {},
    __music__ = {}
}

for line in rfile:lines() do
    if line == "__lua__" then
        sec = "__lua__"
    elseif line == "__gfx__" then
        sec = "__gfx__"
    end

    table.insert(sections[sec], line)
end

io.close(rfile)

-- writing

local wfile = io.open("new.p8", "w")
io.output(wfile)

for _i,v in ipairs(sections["__preamble__"]) do
    io.write(v)
    io.write("\n")
end

for _i,v in ipairs(sections["__lua__"]) do
    io.write(v)
    io.write("\n")
end

for _i,v in ipairs(sections["__gfx__"]) do
    io.write(v)
    io.write("\n")
end

io.close(wfile)