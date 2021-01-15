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
    crocs=new_group(croc)
 
    char=init_char()
    --crocs:new({x=80,y=112,d=true})

    gun={
        x=0,
        y=0
    }

    crosshair = {
        x=0,
        y=0
    }
end
   
function _update()
    t=(t+1)%64
 
    char:update()

    shots:update()
    booms:update()
    crocs:update()
   
    for d in all(dust) do
        d:update()
    end

    cam.x = char.x - 64
    cam.y = char.y - 64

    gun.x = char.x
    gun.y = char.y
    if (t < 16) then
        gun.y+=1
    end


    -- todo: proper circle movement
    if char.flip then
        crosshair.x = char.x + 4 + 32
    else
        crosshair.x = char.x + 4 - 32
    end

    if char.facing == 'u' then
        crosshair.y = char.y + 4 - 32
    elseif char.facing == 'd' then
        crosshair.y = char.y + 4 + 32
    else
        crosshair.y = char.y + 4
    end
end
   
function _draw()
    cls()
    camera(cam.x, cam.y)
    map(0,0,0,0,32,32)


    -- todo: proper gun following
    -- if char.facing == 'u' then
    --     spr(192,gun.x,gun.y,2,2,char.flip)
    -- end

    char:draw()

    -- todo: proper gun following
    -- if char.facing ~= 'u' then
    --     spr(192,gun.x+2,gun.y,2,2,char.flip)
    -- end

    -- todo: crosshair? good for debug
    spr(194,crosshair.x,crosshair.y)

    shots:draw()
    booms:draw()
    crocs:draw()
   
    for d in all(dust) do
        d:draw()
    end
       
    debug()
end