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