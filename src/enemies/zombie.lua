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