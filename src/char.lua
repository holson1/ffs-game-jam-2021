function init_char()
    local char={
        x=32,
        y=64,
        dx=0,
        dy=0,
        spr=001,
        spri=0,
        state='idle',
        facing='n',
        max_speed=3,
        flip=false,

        states={
            'idle',
            'walk',
            'dash',
            'shoot',
            'charge'
        },

        animations={
            idle={
                u={035},
                d={005},
                n={003}
            },
            walk={
                u={037, 037, 039, 039},
                d={043, 043, 041, 041},
                n={007,009,011,013}
            }
        },

        get_animation=function(self)
            return self.animations[self.state][self.facing]
        end,

        update=update_char,

        draw=function(self)
            spr(self.spr,self.x,self.y,2,2,self.flip)
        end
    }
    return char
end

function update_char(_char)
    handle_input(_char)
    update_position(_char)

    -- todo: proper animation timing system
    if (t%4 == 0) then
        _char.spri = (_char.spri + 1) % 16
        set_spr(_char)
    end
end

function handle_input(_char)

    local default_max_speed = 2
    local acceleration = 0.3
    local diagonal_speed_mod = .707

    -- todo: proper diagonal handling / staircase effect
    if ((btn(0) or btn(1)) and (btn(2) or btn(3))) then
        _char.max_speed = default_max_speed * diagonal_speed_mod
    else
        _char.max_speed = default_max_speed
    end

    -- l/r
    if btn(0) and not(btn(1)) then
        _char.dx = max(_char.dx - acceleration, -_char.max_speed)
        _char.flip = false
        _char.facing = 'n'
    elseif btn(1) and not(btn(0)) then
        _char.dx = min(_char.dx + acceleration, _char.max_speed)
        _char.flip = true
        _char.facing = 'n'
    end
       
    -- u/d
    if btn(2) and not(btn(3)) then
        _char.dy = max(_char.dy - acceleration, -_char.max_speed)
        _char.facing = 'u'
    elseif btn(3) and not(btn(2)) then
        _char.dy = min(_char.dy + acceleration, _char.max_speed)
        _char.facing = 'd'
    end
       
    -- x
    if btn(5) then
    end
   
    -- z
    if btnp(4) then
        sfx(2)
    end
end
  
function update_position(_char)
    local friction = 0.2

    _char.x+=_char.dx	
    _char.y+=_char.dy

    if _char.dx > friction then
        _char.dx -= friction
    elseif _char.dx < -friction then
        _char.dx += friction
    else
        _char.dx = 0
    end

    if _char.dy > friction then
        _char.dy -= friction
    elseif _char.dy < -friction then
        _char.dy += friction
    else
        _char.dy = 0
    end

    -- update state based on current dx/dy
    if (_char.dx == 0 and _char.dy == 0) then
        _char.state = 'idle'
    else
        _char.state = 'walk'
    end
end

function set_spr(_char)
    local anim = _char:get_animation()
    local transformed_spri = (_char.spri % #anim) + 1
    
    _char.spr = anim[transformed_spri]
end