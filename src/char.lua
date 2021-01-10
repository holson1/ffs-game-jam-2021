function init_char()
    local char={
        x=32,
        y=64,
        dx=0,
        dy=0,
        spr=001,
        spri=1,
        state='idle',
        max_speed=3,
        flip=false,

        update=update_char,

        draw=function(self)
            spr(self.spr,self.x,self.y,2,2,self.flip)
        end
    }
    return char
end

function update_char(_char)
    if (t%4 == 0) then
        _char.spri+=1
    end

    handle_input(_char)
            
    _char.x+=_char.dx	
    _char.y+=_char.dy

    --_char.spr = set_spr(_char.state, 001)

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
        _char.flip = false

        a = {007, 009}
        -- todo: actual animation
        -- _char.spr=a[max(1,_char.spri % 3)]
        if t%4 == 0 then
            if _char.spr == 007 then
                _char.spr = 009
            else
                _char.spr = 007
            end
        end
            
    elseif btn(1) and not(btn(0)) then
        _char.dx = min(_char.dx + acceleration, _char.max_speed)
        _char.flip = true
        _char.spr = 003
    end
       
    -- u/d
    if btn(2) and not(btn(3)) then
        _char.dy = max(_char.dy - acceleration, -_char.max_speed)
        _char.spr = 013
    elseif btn(3) and not(btn(2)) then
        _char.dy = min(_char.dy + acceleration, _char.max_speed)
        _char.spr = 005
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