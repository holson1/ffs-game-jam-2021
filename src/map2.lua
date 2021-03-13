MAP_SIZE=64 -- map size in tiles
ROOM_SIZE=8 -- room size in tiles

empty = {
    spr=064,
    flag=0
}

wall = {
    spr=079,
    flag=1
}

floor = {
    spr=095,
    flag=0
}

highlighted_wall = {
    spr=111,
    flag=1
}

highlighted_floor = {
    spr=111,
    flag=0
}

hall = {
    spr=070,
    flag=0
}

start = {
    spr=086,
    flag=0
}

exit = {
    spr=085,
    flag=7
}

-- in pico8, map space and tokens are limited
-- this is a relatively cheap way to design a map
-- TODO: build some tooling around this
base_room="x______xx______x________________________________x______xx______x"
wall_room="xxxxxxxxx______xx______xx______xx______xx______xx______xxxxxxxxx"
empty_room="________________________________________________________________"

rooms = {base_room, wall_room, empty_room}
room_map = {
    x=wall,
    _=floor
}

function create_room_new(_map, xtile, ytile)
    local room_pick = rooms[rndi(1,#rooms + 1)]
    for i = 0, #room_pick do
        local ix = i + 1
        local c = sub(room_pick,ix,ix)

        local xcoord = (i % ROOM_SIZE) + 1
        local ycoord = ceil((ix)/ROOM_SIZE)
        xcoord += xtile
        ycoord += ytile

        _map[ycoord][xcoord] = room_map[c]
    end
end


function generate_map_new()
    local _map = {}
    for i=0,MAP_SIZE do
        add(_map, {})
        for j=0,MAP_SIZE do
            add(_map[i], empty)
        end
    end

    create_room_new(_map,0,0)
    create_room_new(_map,8,0)
    create_room_new(_map,0,8)
    create_room_new(_map,8,8)

    return _map
end

function draw_map_new(_map)
    for i,row in ipairs(_map) do
        for j,cell in ipairs(row) do
            spr(cell.spr, j*8, i*8)
        end
    end
end
