function handle_input()

    local default_max_speed = 2.5
    local acceleration = 0.15
    local diagonal_speed_mod = .707

    -- todo: proper diagonal handling / staircase effect
    if ((btn(0) or btn(1)) and (btn(2) or btn(3))) then
        char.max_speed = default_max_speed * diagonal_speed_mod
    else
        char.max_speed = default_max_speed
    end

    -- l/r
    if btn(0) and not(btn(1)) then
        char.dx = max(char.dx - acceleration, -char.max_speed)
    elseif btn(1) and not(btn(0)) then
        char.dx = min(char.dx + acceleration, char.max_speed)
    end
       
    -- u/d
    if btn(2) and not(btn(3)) then
        char.dy = max(char.dy - acceleration, -char.max_speed)
    elseif btn(3) and not(btn(2)) then
        char.dy = min(char.dy + acceleration, char.max_speed)
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