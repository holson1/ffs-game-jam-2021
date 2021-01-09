-- game_jam

function _init()
    -- global vars
    t=0
    cam = {}
    cam.x = 0
    cam.y = 0
    msg=''
   
    -- TODO: move to char.lua
    char={}
    char.x=32
    char.y=64
    char.dx=0
    char.dy=0
    char.spr=001
    -- [idle, walk]
    char.state=0
    char.max_speed=3
    can_shoot=true

    -- thanks doc_robs!
    dust={}
       
    shots=new_group(shot)
    booms=new_group(boom)
    crocs=new_group(croc)
   
    --crocs:new({x=80,y=112,d=true})
end
   
function _update()
    t=(t+1)%64
   
    handle_input()
       
    char.x+=char.dx	
    char.y+=char.dy
   
    char.spr = set_spr(char.state, 001)
   
    -- friction
    if char.dx > 0.1 then
        char.dx -= 0.1
    elseif char.dx < -0.1 then
        char.dx += 0.1
    else
        char.dx = 0
    end

    if char.dy > 0.1 then
        char.dy -= 0.1
    elseif char.dy < -0.1 then
        char.dy += 0.1
    else
        char.dy = 0
    end
    
    shots:update()
    booms:update()
    crocs:update()
   
    for d in all(dust) do
        d:update()
    end

    cam.x = char.x - 64
    cam.y = char.y - 64
end
   
function _draw()
    cls()
    camera(cam.x, cam.y)
    map(0,0,0,0,32,32)
    spr(char.spr,char.x,char.y,1,1)

    shots:draw()
    booms:draw()
    crocs:draw()
   
    for d in all(dust) do
        d:draw()
    end
       
    debug()
end