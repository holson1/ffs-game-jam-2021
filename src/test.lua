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