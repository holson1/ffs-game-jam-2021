function init_char()
    local char={
        x=32,
        y=64,
        w=8,
        h=10,
        xshift=-3,
        yshift=-5,
        dx=0,
        dy=0,
        last_dx=0,
        last_dy=0,
        spr=001,
        spri=0,
        state='idle',
        facing='n',
        angle=0.5,
        max_speed=3,
        action_time=0,
        can_dash=true,
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
            },
            dash={
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
            rect(self.x, self.y, self.x + self.w, self.y + self.h)
            spr(self.spr,self.x + self.xshift,self.y + self.yshift,2,2,self.flip)
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

    -- todo: clean up this spaghetti
    if _char.state == 'dash' then

        add_new_dust(_char.x + 8, _char.y + 14, 0, 0, 5, rnd(2) + 2, 0, 1)

        if _char.action_time >= 8 then
            _char.state = 'walk'
            _char.can_dash = true
        else
            _char.action_time += 1
        end
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

    if _char.state ~= 'dash' then
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
    end

    -- better angle code
    if btn(0) or btn(1) or btn(2) or btn(3) then
        _char.angle = atan2(_char.dx, -_char.dy)
    end
       
    -- x
    if btnp(5) then
        if _char.can_dash then
            _char.action_time = 0
            _char.state = 'dash'
            _char.can_dash = false
            _char.dx = cos(_char.angle) * 4
            _char.dy = -sin(_char.angle) * 4
        end
    end
   
    -- z
    if btnp(4) then
        -- sfx(2)

        add_new_dust(_char.x + 6, _char.y + 8, -cos(_char.angle), sin(_char.angle), 5, rnd(5) + 2, 0.1, 7)

        shots:new({
            x=_char.x + 4,
            y=_char.y + 4,
            dx=cos(_char.angle) * 4,
            dy=-sin(_char.angle) * 4
        })
    end
end
  
function update_position(_char)
    local friction = 0.2

    -- check collision before any movement
    local new_xpos = _char.x + _char.dx
    local new_ypos = _char.y + _char.dy

    -- to check collision, look at all the walls around the character
    -- if the new position would overlap with a wall,
    -- don't update the position and just return

    -- get the map cell at each bound
    local collision_left = new_xpos \ 8
    local collision_right = (new_xpos + _char.w) \ 8
    local collision_up = (new_ypos \ 8)
    local collision_down = ((new_ypos + _char.h) \ 8)

    local collide = true
    if map[collision_up][collision_left].flag == 1 then
    elseif map[collision_up][collision_right].flag == 1 then
    elseif map[collision_down][collision_right].flag == 1 then
    elseif map[collision_down][collision_left].flag == 1 then
    else
        collide = false
    end

    -- TODO: allow for movement along walls
    if collide then
    else
        _char.x+=_char.dx	
        _char.y+=_char.dy
    end

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
    elseif _char.state ~= 'dash' then
        _char.state = 'walk'
    end
end

function set_spr(_char)
    local anim = _char:get_animation()
    local transformed_spri = (_char.spri % #anim) + 1
    
    _char.spr = anim[transformed_spri]
end