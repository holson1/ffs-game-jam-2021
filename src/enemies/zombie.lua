zombie={
    life=50,
    s=144,
    w=16,
    h=16,
    x=nil,
    y=nil,
    d=nil,
    state='walk',
    spri=0,

    animations={
        walk={144,146}
    },

    update=function(self)
        local movespeed = 0.25
        local aggro_range = 64

        -- todo: generic animation code for all enemies
        if (t%16 == 0) then
            self.spri = (self.spri + 1) % 16
            local anim = self.animations[self.state]
            local transformed_spri = (self.spri % #anim) + 1
            
            self.s = anim[transformed_spri]
        end

        -- aggro
        if abs(self.x - char.x) > aggro_range and abs(self.y - char.y) > aggro_range then
            -- patrol
        else
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