pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

local enemies={}

local directions={"up","right","down","left"}
local directions_key={up=0,right=1,down=2,left=3}

local energy={
    x=15,
    y=5,
    val=100,
    draw=function(self)
        if (self.val>0) then
            rectfill(self.x,self.y,self.x+100,self.y+8,0)
            rectfill(self.x,self.y,self.x+self.val,self.y+8,12)
            rect(self.x,self.y,self.x+100,self.y+8,0)
            print("energy",(self.x+100-12)/2,self.y+2,7)
        end
    end
}

local health={
    x=15,
    y=15,
    val=100,
    draw=function(self)
        rectfill(self.x,self.y,self.x+100,self.y+8,0)
        rectfill(self.x,self.y,self.x+self.val,self.y+8,8)
        rect(self.x,self.y,self.x+100,self.y+8,0)
        print("health",(self.x+100-12)/2,self.y+2,7)
    end
}

local aang={
      state="still",
      alive=true,
      x=60,
      y=54,
      update=function(self)
        if(health.val == 0 or energy.val == 0) then
            self.alive=false
        else
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

local score={
    x=90,
    y=118,
    val=0,
    draw=function(self)
        print("score:"..self.val,self.x,self.y,1)
    end
}

local global={
    can_spawn_enemy=false,
    frame_count=0,
    speed=1,
    update=function(self)
    	if (score.val%25) == 0 then
	 		self.speed+=0.5
	 		self.frame_count=0
    	end
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
            sfx(2 + directions_key[self.atack_type])
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
                    spr(5,i*8,aang.y+27)
                end
            end
            if (self.atack_type == "up") then
                for i=0,128/8 do
                    spr(4,i*8,aang.y-15)
                end
            end
            if (self.atack_type == "left") then
                for i=0,128/8 do
                    spr(6,aang.x-21,i*8)
                end
            end
            if (self.atack_type == "right") then
                for i=0,128/8 do
                    spr(3,aang.x+21,i*8)
                end
            end
        end 
    end
}

function generate_enemies(global)
    if (global.frame_count >= flr((30/(global.speed/2)))) then
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
	sfx(2+direct)
    local enemy = {
        alive=true,
        dead_frames=0,
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
        else
        	if enemy.dead_frames < 5 then
			 	spr(7,enemy.x,enemy.y)
			 	enemy.dead_frames+=1
        	end
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
                if box_hit(enemy.x,enemy.y,0,aang.y+27,enemy.x+8,enemy.y+8,128,aang.y+28+8) then
                    enemy.alive=false
                    energy.val+=10
                    score.val+=1
    				global:update()
                end
            end
            if atack.atack_type == "right" then
                if box_hit(enemy.x,enemy.y,aang.x+21,0,enemy.x+8,enemy.y+8,aang.x+24+8,128) then
                    enemy.alive=false
                    energy.val+=10
                    score.val+=1
                    global:update()
                end
            end
            if atack.atack_type == "left" then
                if box_hit(enemy.x,enemy.y,aang.x-21,0,enemy.x+8,enemy.y+8,aang.x-16,128) then
                    enemy.alive=false
                    energy.val+=10
                    score.val+=1
                    global:update()
                end
            end
            if atack.atack_type == "up" then
                if box_hit(enemy.x,enemy.y,0,aang.y-15,enemy.x+8,enemy.y+8,128,aang.y-8) then
                    enemy.alive=false
                    energy.val+=10
                    score.val+=1
                    global:update()
                end
            end
        end
    end
end

function _init()
 cls(0) 
 sfx(1)
end

function _update()
    if aang.alive then
     aang:update()
     generate_enemies(global)
     atack:update()
     verify_hit()
     verify_damage()
    end
end

function _draw()
    if aang.alive and score.val < 999 then
     cls() 
     map(0, 0, 0, 0, 16, 16)
     aang:draw()
     energy:draw()
     health:draw()
     score:draw()
     atack:draw()
     walk_enemies(enemies)
    else
     cls()
     if  score.val >= 999  then
     	 you_won()
     else
	     you_died()
     end
    end
end

function you_died()
   
    for i=0,flr(global.frame_count),1 do
      print("you died!",50,60,i)

      print("s",50,52,8 + flr(rnd(7)))
      print("c",54,52,8 + flr(rnd(7)))
      print("o",58,52,8 + flr(rnd(7)))
      print("r",62,52,8 + flr(rnd(7)))
      print("e",66,52,8 + flr(rnd(7)))
      print(":"..score.val,69,52,8 + flr(rnd(7)))
    end
     
    if global.frame_count < 14 then
        global.frame_count+=0.334   
    else
        global.frame_count=8
    end 

end

function you_won()
   
    for i=0,flr(global.frame_count),1 do
      print("you won!",50,60,i)

      print("s",50,52,8 + flr(rnd(7)))
      print("c",54,52,8 + flr(rnd(7)))
      print("o",58,52,8 + flr(rnd(7)))
      print("r",62,52,8 + flr(rnd(7)))
      print("e",66,52,8 + flr(rnd(7)))
      print(":"..score.val,69,52,8 + flr(rnd(7)))
    end
     
    if global.frame_count < 14 then
        global.frame_count+=0.334   
    else
        global.frame_count=8
    end 

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

function verify_damage()
	for enemy in all(enemies) do
		if enemy.alive and box_hit(enemy.x,enemy.y,48,48,enemy.x+8,enemy.y+8,79,79) then
		 	health.val-=10
		 	enemy.alive=false
		end
	end 
end

function lines_overlapping(min1,max1,min2,max2)
    return max1>min2 and max2>min1
end

function box_hit(left1,top1,left2,top2,right1,bottom1,right2,bottom2)
    return lines_overlapping(left1,right1,left2,right2) and lines_overlapping(top1,bottom1,top2,bottom2)
end

__gfx__
0ffccff00ffccff00ffccff00000000000000800004444000007770088889988000000000000000000000000dd555666dddddddddd5555dd555555557777cccc
ffccccffffccccffffccccff00c0000000000008449994400070007089999998000000000000000000000000dd556666dddddddddd5555dd5ddd5555c77ccccc
fffccffffffccffffffccfff01c7000080008080499494440700000799aaaa990000000000000000000000005556665555555555dd5555dd5ddd5dddcccc77cc
f57ff57ff75ff57ff75ff75f170c10010808880049494449070077079aa77aa90000000000000000000000005566656655555555dd5555dd55555ddd7ccc7cc7
ffffffffffffffffffffffff70007c0780889880499449990070070799a77a990000000000000000000000005666656555555555dd5555dddddd555577cccc77
0ff55ff00ff55ff00ff55ff0000001cc0089a988949449947007700789aaaa980000000000000000000000006665566555555555dd5555ddddddd5557cc77cc7
00ffff0000ffff0000ffff00000000700889aa9804499444070000708999a99800000000000000000000000066566656dddddddddd5555dd55555555cccc77cc
00000000000000000000000000000000089aaa980004440000777700888999880000000000000000000000006656556cdddddddddd5555dd55555dd5c77ccccc
090ff090090ff090090ff0900000000000000000000000000000000000000000000000000000000000000000666555ddc65565666656556cdddddddd55555555
999ff999999ff999999ff99988888f0000000000000000000000000000000000000000000000000000000000666655dd6566656666566656dddddddd56665666
0899998088999988889999800000000000000000000000000000000000000000000000000000000000000000556665555665566666655665dddddddd56665666
0888888088888888888888800000000000000000000000000000000000000000000000000000000000000000665666555656666556666565dddddddd55555555
0889988088899888888f98800000000000000000000000000000000000000000000000000000000000000000565666656656665555666566dddddddd55555555
0099990080999908009999000000000000000000000000000000000000000000000000000000000000000000566556665566655555566655dddddddd66656665
009999008099990800999900000000000000000000000000000000000000000000000000000000000000000065666566666655dddd556666dddddddd66656665
00888800f088880f008888000000000000000000000000000000000000000000000000000000000000000000c6556566666555dddd555666dddddddd55555555
00900900009009000000000000000000000000000000000000000000000000000000000000000000000000006665656c66666666c6665656cccccccc0ff55ff0
00900900009009000000000088000000000000000000000000000000000000000000000000000000000000006656565c66555566c565656665666656fff5ff88
00400440004004000000000008000000000000000000000000000000000000000000000000000000000000006565656c65666656c656565666555566fffff888
00400050004004000000000008000000000000000000000000000000000000000000000000000000000000006565656c56555565c656565665666656f75f8578
00500045005005000000000008000000000000000000000000000000000000000000000000000000000000006565656c65666656c656565656555565ffff8888
0540000005400450000000000f000000000000000000000000000000000000000000000000000000000000006565656c56555565c6565656656666560ff55ff0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000006656565c65666656c56565665655556500ffff00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000006665656cccccccccc66656566666666600000000
__map__
0f0f0f0f0f0d0e0e0e0e0d0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0d0e0e0e0e0d0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0d0e0e0e0e0d0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0d0e0e0e0e0d0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0d0e0e0e0e0d0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c0c0b2c2c2c2c1b0c0c0c0c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e2b1f1f1f1f2d0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e2b1f1f1f1f2d0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e2b1f1f1f1f2d0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e2b1f1f1f1f2d0e0e0e0e0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c0c1d2e2e2e2e1c0c0c0c0c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0d0e0e0e0e0d0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0d0e0e0e0e0d0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0d0e0e0e0e0d0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0d0e0e0e0e0d0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0d0e0e0e0e0d0f0f0f0f0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010900000c0500e0501005000000000000c3501235012350000010000100001000010000100001000010000100001000010000000000000000000000000000000000000000000000000000000000000000000000
01140100230730c0750e07510075100751007500000244152631528315000050c0750e07510075000002441526315343151007510075100750000024415263152477323073000000000000000000000000000000
011000000c07000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000e07000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001107000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 01424344

