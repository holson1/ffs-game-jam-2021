-- TODO: delete this file once map2 is fully functional
-- and maybe steal the start/end pieces from it

-- MAP_SIZE=64 -- map size in tiles

-- empty = {
--     spr=064,
--     flag=0
-- }

-- wall = {
--     spr=079,
--     flag=1
-- }

-- floor = {
--     spr=095,
--     flag=0
-- }

-- hall = {
--     spr=070,
--     flag=0
-- }

-- start = {
--     spr=086,
--     flag=0
-- }

-- exit = {
--     spr=085,
--     flag=7
-- }


function create_room(_map, x, y, min_wh, max_wh)
    local width = rndi(min_wh, max_wh)
    local height = rndi(min_wh, max_wh)
    local roomx = x+1 -- lua offset
    local roomy = y+1

    for i=roomy,(roomy+width) do
        for j=roomx,(roomx+height) do
            if i < MAP_SIZE and j < MAP_SIZE then
                _map[i][j] = floor
            end
        end
    end

    return {
        x=roomx,
        y=roomy,
        w=width,
        h=height,
        midx=(roomx + (width \ 2)),
        midy=(roomy + (height \ 2)),
        connections={}
    }
end

function generate_map()
    local _map = {}
    for i=0,MAP_SIZE do
        add(_map, {})
        for j=0,MAP_SIZE do
            add(_map[i], wall)
        end
    end

    -- ROOMS
    local rooms = {}

    -- decide how many rooms to create
    local num_rooms = rndi(4,9)

    -- decide max size of rooms based on density
    local max_wh = (MAP_SIZE \ num_rooms) + 3

    local cursor_x = rndi(0,max_wh)
    local cursor_y = rndi(0,max_wh)

    for i=1,num_rooms do
        local new_room = create_room(_map, (cursor_x % MAP_SIZE), cursor_y, 6, max_wh)

        add(rooms, new_room)

        cursor_x += rndi(max_wh, flr(max_wh * 1.5))
        cursor_y = (cursor_x \ MAP_SIZE) * max_wh
    end

    log(#rooms)


    -- HALLS
    -- global var for debugging
    connections = {}

    for i,r in ipairs(rooms) do

        local valid_rooms = {}
        for j,r2 in ipairs(rooms) do
            if i~=j and r.connections[j] == nil then
                add(valid_rooms, r2)
            end
        end

        local midtile = {x=r.midx, y=r.midy}
        local target_room = nearest_room(midtile, valid_rooms).i

        -- draw hall tiles to target room


        add(r.connections, target_room)
        add(rooms[target_room].connections, i)

        local connection = {
            x0=rooms[i].midx,
            y0=rooms[i].midy,
            x1=rooms[target_room].midx,
            y1=rooms[target_room].midy
        }
        add(connections, connection)
    end

    -- EXIT and START
    -- pick a corner at random, put the exit in the room closest to that corner
    local corners = {
        {x=0,y=0},
        {x=0,y=MAP_SIZE},
        {x=MAP_SIZE,y=MAP_SIZE},
        {x=MAP_SIZE,y=0}
    }
    local exit_i = rndi(1,5)
    local exit_corner = corners[exit_i]

    local exit_room = nearest_room(exit_corner, rooms).room
    _map[exit_room.midy][exit_room.midx] = exit
    
    local start_corner = corners[max(1, (exit_i + 2) % 5)]

    local start_room = nearest_room(start_corner, rooms).room
    _map[start_room.midy][start_room.midx] = start

    -- set the character starting pos
    char.x = start_room.midx * 8
    char.y = start_room.midy * 8


    -- validation
    -- take right turns around the map, can every room be visited?

    return _map
end

function draw_map(_map)
    for i,row in ipairs(_map) do
        for j,cell in ipairs(row) do
            spr(cell.spr, j*8, i*8)
        end
    end

    for con in all(connections) do
        line(con.x0 * 8, con.y0 * 8, con.x1 * 8, con.y1 * 8, 8)
    end
end

-- find the nearest room to a given tile
function nearest_room(tile, _rooms)
    local distance = 9999
    local target_index = 1
    local target_room = {}

    for i,r in ipairs(_rooms) do
        local xdist = abs(tile.x - r.midx)
        local ydist = abs(tile.y - r.midy)
        local hdist = sqrt((xdist^2) + (ydist^2))
        if hdist < distance then
            target_index = i
            target_room = r
            distance = hdist
        end
    end

    return {
        i=target_index,
        room=target_room
    }
end