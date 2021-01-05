pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--require("mylib")

function _init()
    sprx=32
    spry=32
    x=2
end

function _update()
    sprx=(sprx + 1)%64
    spry=(spry + 1)%64
    x=64/2
end

function _draw()
    cls(0)
    camera(0,0)
    spr(001,sprx,spry)
end
__gfx__
00000000022222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000027272200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700021212220007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000022221200065770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000022211220077770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700022222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000002002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000002002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000