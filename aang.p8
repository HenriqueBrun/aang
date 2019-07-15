pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

local global={
    can_spawn_enemy=false,
    frame_count=0,
    speed=1,
}

local enemies={}

local directions={"up","right","down","left"}

local aang={
      state="still",
      x=60,
      y=60,
      update=function(self)
        if(btnp(0)) then
            self.state = "left"
        end
        if(btnp(1)) then
            self.state = "right"
        end
        if(btnp(2)) then
            self.state = "up"
        end
        if(btnp(3)) then
            self.state = "down"
        end
      end,
      draw=function(self)
        if self.state == "still" then
            draw_still_aang(self)
        end
        if self.state == "up" then
            draw_looking_up_aang(self)
        end
        if self.state == "down" then
            draw_looking_down_aang(self)
        end
        if self.state == "left" then
            draw_looking_left_aang(self)
        end
        if self.state == "right" then
            draw_looking_right_aang(self)
        end
      end
    }

local energy={
    x=15,
    y=5,
    val=100,
    draw=function(self)
        if (self.val>0) then
            rectfill(self.x,self.y,self.x+self.val,self.y+8,12)
            print("energy",(self.x+100-12)/2,self.y+2,7)
        end
    end
}

local health={
    x=15,
    y=15,
    val=100,
    draw=function(self)
        rectfill(self.x,self.y,self.x+self.val,self.y+8,8)
        print("health",(self.x+100-12)/2,self.y+2,7)
    end
}

local score={
    x=84,
    y=118,
    val=0,
    draw=function(self)
        print("score: "..self.val,self.x,self.y,7)
    end
}

local atack={
	atacking=false,
	atack_duration=0,
    atack_type=aang.state,
    update=function(self)
         self.atack_type=aang.state
        if (btnp(4) and not (aang.state == "still") and not (energy.val == 0)) then
            energy.val-=10
         	self.atack_duration=0
            self.atacking=true
        end     

        if self.atack_duration < 7 then
        	self.atack_duration+=1
        else
        	self.atacking=false
         	self.atack_duration=0
        end
    end,
    draw=function(self)
        if (self.atacking == true) then
            if (self.atack_type == "down") then
                for i=0,128/8 do
                    spr(5,i*8,aang.y+28)
                end
            end
            if (self.atack_type == "up") then
                for i=0,128/8 do
                    spr(4,i*8,aang.y-16)
                end
            end
            if (self.atack_type == "left") then
                for i=0,128/8 do
                    spr(6,aang.x-24,i*8)
                end
            end
            if (self.atack_type == "right") then
                for i=0,128/8 do
                    spr(3,aang.x+24,i*8)
                end
            end
        end 
    end
}

function generate_enemies(global)
    if (global.frame_count == (30/(global.speed/2))) then
             global.can_spawn_enemy=true
    end

    if global.can_spawn_enemy then
        add(enemies,make_enemy())
        global.can_spawn_enemy=false 
        global.frame_count=0 
    else
        global.frame_count+=global.speed
    end
end

function define_enemy_x_starting_position(direction)
    if direction == 0 then
        return flr(rnd(36)) + 42
    end
    if  direction == 1 then
        return 120
    end
    if  direction == 2 then
        return flr(rnd(36)) + 42
    end
    if  direction == 3 then
        return 0
    end
end

function define_enemy_y_starting_position(direction)
    if direction == 0 then
        return 0
    end
    if  direction == 1 then
        return flr(rnd(36)) + 42
    end
    if  direction == 2 then
        return 120
    end
    if  direction == 3 then
        return flr(rnd(36)) + 42
    end
end

function make_enemy()
    local direct = flr(rnd(4))
    local enemy = {
        alive=true,
        direction=direct,
        x = define_enemy_x_starting_position(direct),
        y = define_enemy_y_starting_position(direct),
        speed = global.speed
    }
    return enemy
end


function walk_enemies(enemies)
     for enemy in all(enemies) do
        if enemy.alive then
            spr(get_enemy_type(enemy),enemy.x,enemy.y)
            enemy.x=increse_enemy_x(enemy)
            enemy.y=increse_enemy_y(enemy)
        end
     end    
end

function get_enemy_type(enemy)
    local direction=enemy.direction
    if direction == 0 then
        return 4
    end
    if  direction == 1 then
        return 3
    end
    if  direction == 2 then
        return 5
    end
    if  direction == 3 then
        return 6
    end
end

function increse_enemy_x(enemy)
    local direction=enemy.direction
    if direction == 0 then
        return enemy.x
    end
    if  direction == 1 then
        return enemy.x-1
    end
    if  direction == 2 then
        return enemy.x
    end
    if  direction == 3 then
        return enemy.x+1
    end
end

function increse_enemy_y(enemy)
    local direction=enemy.direction
    if direction == 0 then
        return enemy.y+1
    end
    if  direction == 1 then
        return enemy.y
    end
    if  direction == 2 then
        return enemy.y-1
    end
    if  direction == 3 then
        return enemy.y
    end
end

function verify_hit()
    for enemy in all(enemies) do
        if atack.atack_type == directions[enemy.direction+1] and enemy.alive and atack.atacking then
            if atack.atack_type == "down" then
                if box_hit(enemy.x,enemy.y,0,aang.y+28,enemy.x+8,enemy.y+8,128,aang.y+28+8) then
                    enemy.alive=false
                    energy.val+=10
                    score.val+=1
                end
            end
            if atack.atack_type == "right" then
                if box_hit(enemy.x,enemy.y,aang.x+24,0,enemy.x+8,enemy.y+8,aang.x+24+8,128) then
                    enemy.alive=false
                    energy.val+=10
                    score.val+=1
                end
            end
            if atack.atack_type == "left" then
                if box_hit(enemy.x,enemy.y,aang.x-24,0,enemy.x+8,enemy.y+8,aang.x-16,128) then
                    enemy.alive=false
                    energy.val+=10
                    score.val+=1
                end
            end
            if atack.atack_type == "up" then
                if box_hit(enemy.x,enemy.y,0,aang.y-16,enemy.x+8,enemy.y+8,128,aang.y-8) then
                    enemy.alive=false
                    energy.val+=10
                    score.val+=1
                end
            end
        end
    end
end

function _init()
 cls(0) 
 -- sfx(1)
end

function _update()
    aang:update()
    generate_enemies(global)
    atack:update()
    verify_hit()
end

function _draw()
    cls()
    aang:draw()
    energy:draw()
    health:draw()
    score:draw()
    atack:draw()
    walk_enemies(enemies) 
end

function draw_still_aang(aang)
    spr(1,aang.x,aang.y)
    spr(17,aang.x,aang.y+7) 
    spr(33,aang.x,aang.y+14)
end

function draw_looking_down_aang(aang)
    spr(1,aang.x,aang.y)
    spr(17,aang.x,aang.y+7) 
    spr(32,aang.x,aang.y+14)
end

function draw_looking_left_aang(aang)
    spr(0,aang.x,aang.y)
    spr(18,aang.x,aang.y+7,1,1,true)
    spr(19,aang.x-8,aang.y+7,1,1,true) 
    spr(33,aang.x,aang.y+14)
end

function draw_looking_right_aang(aang)
    spr(2,aang.x,aang.y)
    spr(18,aang.x,aang.y+7)
    spr(19,aang.x+8,aang.y+7)
    spr(33,aang.x,aang.y+14)
end

function draw_looking_up_aang(aang)
    spr(1,aang.x,aang.y)
    spr(35,aang.x+8,aang.y+2,1,1,false,true)
    spr(16,aang.x,aang.y+7) 
    spr(35,aang.x-8,aang.y+2,1,1,true,true)
    spr(33,aang.x,aang.y+14)
end

function lines_overlapping(min1,max1,min2,max2)
    return max1>min2 and max2>min1
end

function box_hit(left1,top1,left2,top2,right1,bottom1,right2,bottom2)

    -- rectfill(left1,top1,right1,bottom1,14)
    -- rectfill(left2,top2,right2,bottom2,14)
    -- printh("test 1:"..(lines_overlapping(left1,right1,left2,right2) and 'true' or 'false'),"debug.txt")
    -- printh("test 2:"..(lines_overlapping(top1,bottom1,top2,bottom2) and 'true' or 'false'),"debug.txt")
    -- printh("test final:"..(lines_overlapping(left1,right1,left2,right2) and lines_overlapping(top1,bottom1,top2,bottom2) and 'true' or 'false'),"debug.txt")
    return lines_overlapping(left1,right1,left2,right2) and lines_overlapping(top1,bottom1,top2,bottom2)
end

__gfx__
0ffccff00ffccff00ffccff0000000000000080000444400000777000ff55ff00000000000000000000000000000000000000000000000000000000000000000
ffccccffffccccffffccccff00c00000000000084499944000700070fff5ff880000000000000000000000000000000000000000000000000000000000000000
fffccffffffccffffffccfff01c70000800080804994944407000007fffff8880000000000000000000000000000000000000000000000000000000000000000
f57ff57ff75ff57ff75ff75f170c1001080888004949444907007707f75f85780000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffff70007c07808898804994499900700707ffff88880000000000000000000000000000000000000000000000000000000000000000
0ff55ff00ff55ff00ff55ff0000001cc0089a98894944994700770070ff55ff00000000000000000000000000000000000000000000000000000000000000000
00ffff0000ffff0000ffff00000000700889aa98044994440700007000ffff000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000089aaa980004440000777700000000000000000000000000000000000000000000000000000000000000000000000000
090ff090090ff090090ff09000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
999ff999999ff999999ff99988888f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08999980889999888899998000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888880888888888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0889988088899888888f988000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999900809999080099990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999900809999080099990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888800f088880f0088880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00900900009009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00900900009009000000000088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00400440004004000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00400050004004000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00500045005005000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0540000005400450000000000f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010900000c0500e0501005000000000000c3501235012350000010000100001000010000100001000010000100001000010000000000000000000000000000000000000000000000000000000000000000000000
01140100230730c0750e07510075100751007500000244152631528315000050c0750e07510075000002441526315343151007510075100750000024415263152477323073000000000000000000000000000000
__music__
00 01424344

