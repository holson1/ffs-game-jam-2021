pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--src/main.lua
-- game_jam

function _init()
    -- global vars
    t=0
    cam = {}
    cam.x = 0
    cam.y = 0
    msg=''
   
    -- thanks doc_robs!
    dust={}
       
    shots=new_group(shot)
    booms=new_group(boom)
    zombies=new_group(zombie)
 
    char=init_char()
    zombies:new({x=80, y=32, d=true})

    gun={
        x=0,
        y=0,
        spr=196
    }

    crosshair = {
        x=0,
        y=0
    }

    map = generate_map()
end
   
function _update()
    t=(t+1)%64
 
    char:update()

    shots:update()
    booms:update()
    zombies:update()
   
    for d in all(dust) do
        d:update()
    end

    cam.x = char.x - 64
    cam.y = char.y - 64

    -- gun stuff
    gun.x = char.x + 4
    gun.y = char.y + 8
    if char.angle == 0.25 then
        gun.spr = 196
    elseif char.angle == 0.375 or char.angle == 0.125 then
        gun.spr = 198
    elseif char.angle == 0.5 or char.angle == 0 then
        gun.spr = 197
    elseif char.angle == 0.625 then
        gun.spr = 199
    end

    crosshair.x = (char.x + 4) + (cos(char.angle) * 48)
    crosshair.y = (char.y + 4) - (sin(char.angle) * 48)
end
   
function _draw()
    cls()
    camera(cam.x, cam.y)

    -- custom map code
    draw_map(map)

    -- todo: proper gun following
    if char.facing == 'u' then
        spr(gun.spr,gun.x,gun.y,1,1,char.flip)
    end


    spr(194,crosshair.x,crosshair.y)

    shots:draw()
    char:draw()

    if char.facing ~= 'u' then
        spr(gun.spr,gun.x,gun.y,1,1,char.flip)
    end

    booms:draw()
    zombies:draw()
   
    for d in all(dust) do
        d:draw()
    end
       
    debug()
end
-->8
--src/map.lua
wall = {
    spr=079,
    flag=1
}

floor = {
    spr=095,
    flag=0
}

function create_room(_map)
    local width = flr(rnd(8)) + 3
    local height = flr(rnd(8)) + 3
    local roomx = flr(rnd(7)) + 1
    local roomy = flr(rnd(7)) + 1

    for i=roomx,(roomx+width) do
        for j=roomy,(roomy+height) do
            if i < 16 and j < 16 then
                _map[i][j] = floor
            end
        end
    end
end

function generate_map()
    local _map = {}
    for i=1,16 do
        add(_map, {})
        for j=1,16 do
            add(_map[i], wall)
        end
    end

    create_room(_map)

    return _map
end

function draw_map(_map)
    for i,row in ipairs(_map) do
        for j,cell in ipairs(row) do
            spr(cell.spr, j*8, i*8)
        end
    end
end
-->8
--src/objects/boom.lua
boom={
    s=008,
    w=8,
    h=8,
    x=nil,
    y=nil,

    update=function(self)
            self.s+=1
            if(self.s>11) self.alive=false
    end
}
-->8
--src/objects/shot.lua
shot={
    w=4,
    h=4,
    s=195,
    x=nil,
    y=nil,
    dx=nil,
    dy=nil,
    d=nil,

    update=function(self)
        -- destroy on OOB
        if self.x < cam.x
            or self.x > cam.x + 128
            or self.y < cam.y
            or self.y > cam.y + 128 then
                self.alive = false
        end
  
        if t%2 == 0 then
            add_new_dust(self.x + self.w, self.y + self.h, self.dx/2, self.dy/2, 9, rnd(3), 0, 15)
        end
   
        self.x+=self.dx
        self.y+=self.dy	
    end
}
-->8
--src/lib/group.lua
function new_group(bp)
    return {
        _={},
        bp=bp,
        
        new=function(self,p)
        for k,v in pairs(bp) do
            if v!=nil then
                p[k]=v
            end
        end
        p.alive=true
            add(self._,p)
        end,
           
        update=function(self)
            for i,v in ipairs(self._) do
                v:update()
                if v.alive==false then
                del(self._,self._[i])
                end
            end
        end,
        
        -- todo: change to sspr
        draw=function(self)
            for v in all(self._) do
                spr(v.s,v.x,v.y,ceil(v.w/8),ceil(v.h/8),v.d)
            end
        end
    }
end
-->8
--src/lib/dust.lua
function add_new_dust(_x,_y,_dx,_dy,_l,_s,_g,_f)
    add(dust, {
    fade=_f,x=_x,y=_y,dx=_dx,dy=_dy,life=_l,orig_life=_l,rad=_s,col=0,grav=_g,draw=function(self)
    pal()palt()circfill(self.x,self.y,self.rad,self.col)
    end,update=function(self)
    self.x+=self.dx self.y+=self.dy
    self.dy+=self.grav self.rad*=0.9 self.life-=1
    if type(self.fade)=="table"then self.col=self.fade[flr(#self.fade*(self.life/self.orig_life))+1]else self.col=self.fade end
    if self.life<0then del(dust,self)end end})
end
-->8
--src/log.lua
_log={}
log_l=4
for i=1,log_l do
    add(_log,'')
end

function log(str)
    add(_log,str)
end
   
function debug()
    vars = {
        --'x='..char.x,
        --'y='..char.y,
        --'dx='..char.dx,
        --'dy='..char.dy,
        --"camx="..cam.x,
        --"camy="..cam.y
        'state='..char.state,
        'facing='..char.facing,
        't='..t,
        'spri='..char.spri,
        "angle="..char.angle,
        "action_time="..char.action_time,
        --'shots='..count(shots._)
    }

    -- draw the log
    for i=count(_log)-log_l+1,count(_log) do
        add(vars,'> '.._log[i])
    end

    for i,v in ipairs(vars) do
        print(v,cam.x+8,cam.y+(i*8),15)
    end
end
-->8
--src/char.lua
function init_char()
    local char={
        x=32,
        y=64,
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
    elseif _char.state ~= 'dash' then
        _char.state = 'walk'
    end
end

function set_spr(_char)
    local anim = _char:get_animation()
    local transformed_spri = (_char.spri % #anim) + 1
    
    _char.spr = anim[transformed_spri]
end
-->8
--src/enemies/zombie.lua
zombie={
    life=50,
    s=144,
    w=16,
    h=16,
    x=nil,
    y=nil,
    d=nil,
    state='idle',
    spri=0,

    animations={
        idle={144},
        walk={144,146}
    },

    update=function(self)
        local movespeed = 0.25
        local aggro_range = 32

        -- todo: generic animation code for all enemies
        if (t%16 == 0) then
            self.spri = (self.spri + 1) % 16
            local anim = self.animations[self.state]
            local transformed_spri = (self.spri % #anim) + 1
            
            self.s = anim[transformed_spri]
            -- slime
            add_new_dust(self.x + 2 + rnd(6), self.y + 4 + rnd(4), 0, 0, 5, rnd(2), 0.7, 3)
            add_new_dust(self.x + 8, self.y + 15, 0, 0, 90, 1, 0, 3) 
        end

        -- aggro
        if abs(self.x - char.x) > aggro_range and abs(self.y - char.y) > aggro_range then
            self.state = 'idle'
        else
            self.state = 'walk'
            -- todo: proper pathing code

            -- calculate angle to player
            local xdiff = self.x - char.x
            local ydiff = self.y - char.y
            local angle = atan2(xdiff, -ydiff)
            self.x -= cos(angle) * movespeed
            self.y += sin(angle) * movespeed
        end
    end
}
-->8
__gfx__
00000000000000111100000000000011110000000000001111000000000000111100000000000011110000000000001111000000000000111100000000000000
00000000000001111110000000000111111000000000011111100000000001111110000000000111111000000000011111100000000001111110000000000000
00700700000001fff1100000000001fff110000000001111ff100000000001fff1100000000001fff1100000000001fff1100000000001fff110000000000000
00077000000001272110000000000127211000000000111f27100000000001272110000000000127211000000000012721100000000001272110000000000000
00077000000011272710000000001127271000000000172f27110000000011272710000000001127271000000000112727100000000011272710000000000000
007007000000116ff66000000000116ff66000000000066ff61100000000116ff66000000000116ff66000000000116ff66000000000116ff660000000000000
00000000000006666660000000000666666000000000666666600000000006666660000000000666666000000000066666600000000006666660000000000000
00000000000006555660000000000655566000000000665555600000000006555660000000000655566000000000065556600000000006555660000000000000
00000000000066555660000000006655566000000006665555660000000066555660000000006655566000000000665556600000000066555660000000000000
00000000000066555666000000006655566600000006665555660000000066555666000000006655566600000000665556660000000066555666000000000000
00000000000066111666000000006611166600000006661111660000000066111666000000006611166600000000661116660000000066111666000000000000
00000000000066111666000000006611166600000006611111660000000061111666000000006611166600000000661116660000000061111666000000000000
00000000000661111166000000066611116600000006611d1166600000066111116600000006611111660000000666111d660000000661111166000000000000
000000000000611d11d6000000006611d11600000006611d1166000000006d11d11600000000611d111600000000661111d600000000611d11d6000000000000
00000000000001101100000000000011011000000000011011000000000000010110000000000011001000000000000110000000000000101100000000000000
00000000000000100100000000000001001000000000001010000000000000000010000000000001000000000000000010000000000000000100000000000000
00000000000000000000000000000011110000000000001111000000000000111100000000000011110000000000001111000000000000000000000000000000
00000000000000000000000000000111111000000000011111100000000001111110000000000111111000000000011111100000000000000000000000000000
00000000000000000000000000000111111000000000011111100000000001111110000000001111ff10000000001111ff100000000000000000000000000000
0000000000000000000000000000011111100000000001111110000000000111111000000000111f271000000000111f27100000000000000000000000000000
0000000000000000000000000000011111110000000001111111000000000111111100000000172f271100000000172f27110000000000000000000000000000
0000000000000000000000000000066111110000000006611111000000000661111100000000066ff61100000000066ff6110000000000000000000000000000
00000000000000000000000000000666116000000000066611600000000006661160000000006666666000000000666666600000000000000000000000000000
00000000000000000000000000000666666000000000066666600000000006666660000000006655556000000000665555600000000000000000000000000000
00000000000000000000000000000565565600000000056556560000000005655656000000066655556600000006665555660000000000000000000000000000
00000000000000000000000000006655556600000000665555660000000066555566000000066655556600000006665555660000000000000000000000000000
00000000000000000000000000006665566600000000666556660000000066655666000000066611116600000006661111660000000000000000000000000000
00000000000000000000000000006666666600000000666666660000000066666666000000066111111600000006611111660000000000000000000000000000
0000000000000000000000000000666666666000000066666666600000006666666660000006611d111660000006611d11666000000000000000000000000000
0000000000000000000000000000666666660000000066666666000000006666666600000006611d116600000006611d11660000000000000000000000000000
00000000000000000000000000000011011000000000001101000000000000010110000000000110100000000000001011000000000000000000000000000000
00000000000000000000000000000010010000000000001000000000000000000100000000000010000000000000000010000000000000000000000000000000
00000000000000000000000000000000000000007776777777776777ddddddddd777776dddddddddddddddddd677777dd777776dd677777ddddddddd66666666
00000000000000000000000000000000000000007776777777776777666666ddd777776d66666666dd666666d67777d77d77776dd677777d7777777766666666
0000000000000000000000000000000000000000777677777777677777777d6dd777776d77777777d6d77777d6777d7777d7776dd677777d7777777766666666
000000000000000000000000000000000000000066677777777776667777d76dd777776d77777777d67d7777d677d777777d776dd677777d7777777766666666
00000000000000000000000000000000000000007777766666677777777d776dd777776d77777777d677d777d67d77777777d76dd677777d7777777766666666
0000000000000000000000000000000000000000777767777776777777d7776dd777776d77777777d6777d77d6d7777777777d6dd677777d7777777766666666
000000000000000000000000000000000000000077776777777677777d77776dd777776d77777777d67777d7dd666666666666ddd677777d6666666666666666
00000000000000000000000000000000000000007777677777767777d777776dd777776dddddddddd677777dddddddddddddddddd677777ddddddddd66666666
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000777dddddddddd777dddddddd
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000777dddddddddd777dddddddd
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000777dddddddddd777dddddddd
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dddddddddddddddddddddddd
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dddddddddddddddddddddddd
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ddddd777777ddddddddddddd
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ddddd777777ddddddddddddd
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ddddd777777ddddddddddddd
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00222206002222000022220000222200002222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111205001162006012220060222200001111060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00222205002252005022220050222200002222050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02222225002222005222220052222220022222250000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00222205002252005022220050222200002222050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00222205002252005022220050222200002222050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00220205002252005022220050212200002212050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000000200200002002000200200000202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000033330000000000003333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000333333000000000033333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000311313000000000031131300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000311313000000000031133300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000313333000000000031333303330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000333133300000000033311333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000311133300000000031113333030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00003331113300000000333113300030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00003333333300000000333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00033333333300000000333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00033333333300000000333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000333333000000000033333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000330333000000000033003330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000330033000000000330000330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00003300033000000003300000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00033333333300000033333333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000088880000000000000ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000008000080000000000099990000000000000000ff000900000000000000000000000000000000000000000000000000000000000000000000
0000000000000000808008080008800000990ff000000990000009ff000090000000000000000000000000000000000000000000000000000000000000000000
000000000000000080000008008fe800000a09f00999a99f0000999000000a9000a9000000000000000000000000000000000000000000000000000000000000
000000000000000080000008008ef800000900000000009f0000a00f00000099000a900000000000000000000000000000000000000000000000000000000000
000000000000000080800808000880000009000000009f900009009f0000909f00a9000000000000000000000000000000000000000000000000000000000000
000009000000000008000080000000000009000000000ff00090000000000f000000000000000000000000000000000000000000000000000000000000000000
0000099999000000008888000000000000000000000000000000000000000ff00000000000000000000000000000000000000000000000000000000000000000
99999999999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000ff0000ff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000090000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4f4f4f4f4f4f4f4f4f4f4f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4a4949494949494949474f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d45464646454645464b4949494700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d46454646464546455d5e5f5f4b49494949494949494947000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d45464546464645465e5d5f5f5f5f5f5e5d5e5f5d5e5f48000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d46454645454645454a494949475f5f5f5e5d5f5e5d5d48000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d4546454545464646484f004f4d5e5f5f5f5f5f5f5e5d48000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d4645464546454646484f004f4d5d5f5f5f5f5f5f5f5e48000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d4546464645464546484f00004d5f5f5f5f5f5f5f5f5f48000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d4645464646454645484f00004d5d5f5f5f5f5f5f5f5f48000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d4546454646464546484f00004d5e5d5d5f5f5f5d5f5d48000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d4645464545464545484f00004b4e4e4e4e4e4e4e4e4e4c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d4546454545464646484f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d4645464546454646484f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d4546464645464546484f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d4645464646454645484f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d4546454646464546484f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4d4645464545464545484f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4b4e4e4e4e4e4e4e4e4c4f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000004f4f4f4f4f4f4f4f4f4f4f4f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000155001550025500255003550035500455004550055500655006550075500855008550095500a5500a5500b5500c5500d5500d5500f5500d5500e5000f5000e5000f5000550005500055000550005500
000100000905009050090500805007050060500505003050020500105000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000086310063100630006330a6000a6000a6000a6030960309603086030760307603086030860308603006030e6030f6031a603036030f6030f6030e6030e60313603146031460314603136031260312603
01120000000500000000000000000000000000000000000024027280271f027230272402224012070000b0000405000000000000000000000000000000000000280342800528005000002f034000000000000000
01120000000500000000000000000000000000000000000024027280271f027230272402224012070000b000040500000000000000000000000000000000000028034280052f0040000000000000000000000000
011200000405300003000032960334105346050000300003106230000300003000030000300003000030000304053000030000300003000030400304053000031062300003000030000300003000030000300003
01120000000050000500005000050004500045070450c04500005000000000500005000050000500005000050000500005000050000504045040450b045070450000500005000050000500005000050000500005
0112000000500005000050118521185201852218522005000050000500005000050000500005000050000500005002b520005002a52028500285202450024520235222352223522235211c5211c5221c5221c523
011100002305033000240502400023050000001f050000001c050000001a050000001c0541c0501c0501c0551f000000001f0541f0501f0501f0552100000000210542105021051210001f0541f0401f0301f020
011000002f0501770430050240002f050000002b050000002f0501c0002b0501c000240501f000230501f0002305033000240502400023050000001f050000001c0541c0501c0501c0551a0541a0501a0501a055
011000001c0500000000000000001f000000001f0500000000000210000000000000210500000000000000001f050000000000000000000000000000000000002305033000240502400023050000001f05000000
011000001c0500000000000000001f000000001f05000000000000000000000000002305000000000002300023050000002405000000000000000000000000002405000000260500000028050000002405000000
0110000026050000000000000000000000000024050000000000000000000000000021050000001f000000001f050000002105000000000000000000000000002405000000260500000028050000002405000000
0110000026050000000000000000000000000024050000000000000000000000000021050000002b0500000028050000000000000000000000000000000000002305033000240502400023050000001f05000000
011000000406300000241000406300000000000406300000106330000000000040630400000000040630406304063000000000004063000000000004063000001063300000000000400004063000000400004063
__music__
01 05040607
00 05030644
00 05040607
00 05030644
00 05420644
00 05420644
00 05420644
02 41420644
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 09424344
01 0a0e4344
00 0b0e4344
00 0c0e4344
02 0d0e4344

