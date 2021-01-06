function _init()
    sprx=16
    spry=16
    sw=8
    sh=8
end

function _update()
    sw=plus(sw, 1)
    sh=plus(sh, 1)
end

function _draw()
    cls(0)
    camera(0,0)
    sspr(8,0,8,8,sprx,spry, sw, sh)
end