function init_char()
    local char={
        x=32,
        y=64,
        dx=0,
        dy=0,
        spr=001,
        state='idle',
        max_speed=3,

        update=update_char,

        draw=function(self)
            sspr(8,0,16,16,self.x,self.y)
        end
    }
    return char
end

function update_char(_char)
    handle_input(_char)
            
    _char.x+=_char.dx	
    _char.y+=_char.dy

    _char.spr = set_spr(_char.state, 001)

    -- friction
    if _char.dx > 0.1 then
        _char.dx -= 0.1
    elseif _char.dx < -0.1 then
        _char.dx += 0.1
    else
        _char.dx = 0
    end

    if _char.dy > 0.1 then
        _char.dy -= 0.1
    elseif _char.dy < -0.1 then
        _char.dy += 0.1
    else
        _char.dy = 0
    end
end

function handle_input(_char)

    local default_max_speed = 2.5
    local acceleration = 0.15
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
    elseif btn(1) and not(btn(0)) then
        _char.dx = min(_char.dx + acceleration, _char.max_speed)
    end
       
    -- u/d
    if btn(2) and not(btn(3)) then
        _char.dy = max(_char.dy - acceleration, -_char.max_speed)
    elseif btn(3) and not(btn(2)) then
        _char.dy = min(_char.dy + acceleration, _char.max_speed)
    end
       
    -- x
    if btn(5) then
    end
   
    -- z
    if btnp(4) then
        sfx(2)
    end
end
   
function set_spr(state, base_spr)
    return 001
end