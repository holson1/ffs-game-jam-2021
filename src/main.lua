-- game_jam

function _init()
    -- global vars
    t=0
    roomx=0
    roomy=0
    cellx=0
    celly=0
    score=0
    msg=''
   
    -- char
    char={}
    char.x=32
    char.y=64
    char.dx=0
    char.dy=0
    char.spr=001
    -- [idle, walk]
    char.state=0
    char.max_speed=2

    can_shoot=true

    -- test123	
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
    
    shots:update()
    booms:update()
    crocs:update()
   
    for d in all(dust) do
        d:update()
    end
   
    -- set room
    roomx=(char.x\128)*128
    roomy=(char.y\128)*128
end
   
function _draw()
    cls()
    
    camera(max(0,char.x-64), roomy)
    
    map(0,0,0,0,16,16)
    spr(char.spr,char.x,char.y,1,1)

    shots:draw()
    booms:draw()
    crocs:draw()
   
    for d in all(dust) do
        d:draw()
    end
       
    debug()
end

-->8
-- todo: draw
-->8
-- debug
   
_log={}
log_l=1
for i=1,log_l do
    add(_log,'')
end

function log(str)
    add(_log,str)
end
   
function debug()
    vars = {
        'x='..char.x,
        'y='..char.y,
        'dx='..char.dx,
        'dy='..char.dy,
        --'state='..char.state
        'roomx='..roomx,
        'roomy='..roomy,
        --'shots='..count(shots._)
    }

    -- draw the log
    for i=count(_log)-log_l+1,count(_log) do
        add(vars,'> '.._log[i])
    end

    for i,v in ipairs(vars) do
        print(v,roomx+8,i*8,15)
    end
end

-->8
-- char
   
function handle_input()
    -- l/r
    if btn(0) then
        char.dx-=0.2
    elseif btn(1) then
        char.dx+=0.2
    end
       
    -- u/d
    if btn(2) then
        char.dy-=0.2
    elseif btn(3) then
        char.dy+=0.2
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
-->8
-- dust
function add_new_dust(_x,_y,_dx,_dy,_l,_s,_g,_f)
    add(dust, {
    fade=_f,x=_x,y=_y,dx=_dx,dy=_dy,life=_l,orig_life=_l,rad=_s,col=0,grav=_g,draw=function(self)
    pal()palt()circfill(self.x,self.y,self.rad,self.col)
    end,update=function(self)
    self.x+=self.dx self.y+=self.dy
    self.dy+=self.grav self.rad*=0.9 self.life-=1
    if type(self.fade)=="table"then self.col=self.fade[flr(#self.fade*(self.life/self.orig_life))+1]else self.col=self.fade end
    if self.life<0then del(dust,self)end end})
end
-->8
-- objects
   
function new_group(bp)
    return {
        _={},
        bp=bp,
        
        new=function(self,p)
        for k,v in pairs(bp) do
            if v!=nil then
                p[k]=v
            end
        end
        p.alive=true
            add(self._,p)
        end,
           
        update=function(self)
            for i,v in ipairs(self._) do
                v:update()
                if v.alive==false then
                del(self._,self._[i])
                end
            end
        end,
        
        draw=function(self)
            for v in all(self._) do
                spr(v.s,v.x,v.y,ceil(v.w/8),ceil(v.h/8),v.d)
            end
        end
    }
end
   
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
        if self.x<roomx
            or self.x>roomx+128
            or self.y<roomy
            or self.y>roomy+128 then
            self.alive=false
        end
   
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
   
boom={
    s=008,
    w=8,
    h=8,
    x=nil,
    y=nil,

    update=function(self)
            self.s+=1
            if(self.s>11) self.alive=false
    end
}

-->8
-- enemies
   
croc={
    life=2,
    s=040,
    w=8,
    h=8,
    x=nil,
    y=nil,
    d=nil,

    update=function(self)
    end
}