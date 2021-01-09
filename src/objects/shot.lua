shot={
    w=8,
    h=8,
    s=nil,
    x=nil,
    y=nil,
    dx=nil,
    dy=nil,
    d=nil,

    update=function(self)
        -- outside bounds
        -- todo: refactor into func
        -- if self.x<roomx
        --     or self.x>roomx+128
        --     or self.y<roomy
        --     or self.y>roomy+128 then
        --     self.alive=false
        -- end
   
        if(self.x>0) cx=self.x+7
        if(self.x<=0) cx=self.x
        if(self.y>0) cy=self.y+7
        if(self.y<=0) cy=self.y
        c=mget(cx\8,cy\8)
   
        -- destructable
        if fget(c,1) then
            mset(cx\8,cy\8,c+1%5)
            self.alive=false
            booms:new({x=cx,y=cy})
            add_new_dust(cx,cy,rnd(5)-2,rnd(1)-2,5,rnd(4)+2,0.1,4)
            add_new_dust(cx,cy,rnd(5)-2,rnd(1)-2,5,rnd(1)+2,0.1,6)
        end

        -- indestructable
        if fget(c,0) then
            self.alive=false
            booms:new({x=self.x,y=self.y})
        end
   
        self.x+=self.dx
        self.y+=self.dy	
    end
}