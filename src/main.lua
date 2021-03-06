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

    map = generate_map_new()
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
    draw_map_new(map)

    -- todo: proper gun following
    -- if char.facing == 'u' then
    --     spr(gun.spr,gun.x,gun.y,1,1,char.flip)
    -- end


    spr(194,crosshair.x,crosshair.y)

    shots:draw()
    char:draw()

    -- if char.facing ~= 'u' then
    --     spr(gun.spr,gun.x,gun.y,1,1,char.flip)
    -- end

    booms:draw()
    zombies:draw()
   
    for d in all(dust) do
        d:draw()
    end
       
    debug()
end