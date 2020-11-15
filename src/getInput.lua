rad = 360/(math.pi*2)
pmx, pmy = 0, 0
--player.yaw = 0

function GetInput(dT)
    local p = player 
    local an, ax, ay, az = lovr.headset.getOrientation()
    local playerRotSpd = 2
    local playerWalkSpd = 5
    
    if lovr.mouse and (DESKTOP==1) then 
        local mx, my = lovr.mouse.getPosition()
        local deltax, deltay = (mx-pmx), (my-pmy)
        pmx, pmy = mx, my 
        p.rot = p.rot + (deltax * 0.01)
        p.yaw = p.yaw - (deltay * 0.01)
        --print(deltax, deltay)
    end

    --if DESKTOP==0 then 
        --if totalFrames % 60 == 0 then 
            --6.28 = 360
            --local r = 57.3 * an 
            --print(round(ax*r,1), round(ay*r,1), round(az*r,1))
        --end
    --end

    if an ~= 0.0 then -- If not desktop mode  
        p.facing = an * ay -- set HMD facing to the Y component in radians 
    end    

    -- * DESKTOP mode input * -- 
    if DESKTOP == 1 then 
        if lovrVer <= 13 then 
            if lovr.keyboard then 
                if lovr.keyboard.isDown('k') then 
                    p.pos.x = p.pos.x - playerWalkSpd*(dT)*(math.cos(p.rot))
                    p.pos.z = p.pos.z - playerWalkSpd*(dT)*(math.sin(p.rot))
                elseif lovr.keyboard.isDown('i') then 
                    p.pos.x = p.pos.x + playerWalkSpd*(dT)*(math.cos(p.rot))
                    p.pos.z = p.pos.z + playerWalkSpd*(dT)*(math.sin(p.rot))
                end
                if lovr.keyboard.isDown('j') then 
                    p.pos.x = p.pos.x + playerWalkSpd*(dT)*(math.cos(p.rot-(math.pi/2)))
                    p.pos.z = p.pos.z + playerWalkSpd*(dT)*(math.sin(p.rot-(math.pi/2)))
                elseif lovr.keyboard.isDown('l') then 
                    p.pos.x = p.pos.x + playerWalkSpd*(dT)*(math.cos(p.rot+(math.pi/2)))
                    p.pos.z = p.pos.z + playerWalkSpd*(dT)*(math.sin(p.rot+(math.pi/2)))
                end
                if lovr.keyboard.isDown('o') then 
                    p.rot = p.rot + playerRotSpd*dT
                elseif lovr.keyboard.isDown('u') then 
                    p.rot = p.rot - playerRotSpd*dT
                end
            end
        else
            if lovr.keyboard then 
                if (p.state == PLAYERSTATE.NORMAL) or (p.state == PLAYERSTATE.JUMPING) or (p.state == PLAYERSTATE.FALLING) then 
                    if lovr.keyboard.isDown('u') then 
                        p.rot = p.rot - playerRotSpd*dT
                    elseif lovr.keyboard.isDown('o') then 
                        p.rot = p.rot + playerRotSpd*dT
                    end
                    if lovr.keyboard.isDown('i') then 
                        --given a direction, we need to find x (cos t) and y (sin t)
                        p.pos.x = p.pos.x + playerWalkSpd*(dT)*(math.cos(p.rot))
                        p.pos.z = p.pos.z + playerWalkSpd*(dT)*(math.sin(p.rot))
                    elseif lovr.keyboard.isDown('k') then 
                        p.pos.x = p.pos.x - playerWalkSpd*(dT)*(math.cos(p.rot))
                        p.pos.z = p.pos.z - playerWalkSpd*(dT)*(math.sin(p.rot))
                    end
                    if lovr.keyboard.isDown('j')  then 
                        p.pos.x = p.pos.x + playerWalkSpd*(dT)*(math.cos(p.rot-(math.pi/2)))
                        p.pos.z = p.pos.z + playerWalkSpd*(dT)*(math.sin(p.rot-(math.pi/2)))
                    elseif lovr.keyboard.isDown('l')  then 
                        p.pos.x = p.pos.x + playerWalkSpd*(dT)*(math.cos(p.rot+(math.pi/2)))
                        p.pos.z = p.pos.z + playerWalkSpd*(dT)*(math.sin(p.rot+(math.pi/2)))
                    end
                end 
                if not EDITMODE then 
                    if player.state == PLAYERSTATE.NORMAL then 
                        if lovr.keyboard.isDown('space') and player.jumpReleased then 
                            if SCENE ~= -1 then 
                                player.jumpReleased = false
                                player.jumpBase = p.pos.y
                                player.state = PLAYERSTATE.JUMPING
                            end
                                -- start
                            if SCENE == 0 then 
                                
                            end
                        end
                    end -- PLAYERSTATE.NORMAL
                else 
            --editmode? 
                    gameTime = 0
                    --totalFrames = 0
                    if lovr.keyboard.isDown('space') then 
                        p.pos.y = p.pos.y + (dT * playerWalkSpd) 
                    end
                    if lovr.keyboard.isDown('lctrl') then 
                        p.pos.y = p.pos.y - (dT * playerWalkSpd)
                    end
                    if lovr.keyboard.isDown('backspace') then 
                        if not player.erasePressed then 
                            table.remove(level.gems)
                            player.erasePressed = true 
                        end
                    else -- backspace released
                        player.erasePressed = false 
                    end
                    if lovr.keyboard.isDown('g') then 
                        player.gemPressed = true 
                    else -- 'g' released
                        if player.gemPressed then 
                            --print('gem pos: ', p.pos.x, p.pos.y, p.pos.z)
                            table.insert(level.gems, { x=round(p.pos.x,1), y=round(p.pos.y,1)+2, z=round(p.pos.z,1) })
                            player.gemPressed = false 
                        end
                    end
                    if lovr.keyboard.isDown('t') then 
                        player.tPressed = true 
                    else
                        if player.tPressed then 
                            table.insert(level.platforms, {
                                pos = { x=round(p.pos.x,1), y=round(p.pos.y-5,1), z=round(p.pos.z,1) },
                                platform_ofs = 5, platform_size = 5
                            })
                            player.tPressed = false
                        end
                    end
                end
            -- end edit mode                
                -- release space bool
                if not lovr.keyboard.isDown('space') then 
                    player.jumpReleased = true 
                end
                if not EDITMODE then 
                    if lovr.keyboard.isDown('tab') then 
                        EDITMODE = true 
                    end 
                else
                    if lovr.keyboard.isDown('escape') then 
                        EDITMODE = false 
                    end
                end
            end -- END KEYBOARD
        end
    end -- end desktop

    -- ** VR Mode input **
    if DESKTOP == 0 then  
        hands = lovr.headset.getHands()
        if lovr.headset.isDown('right', 'trigger') then
            if player.jumpReleased == true then
                player.jumpReleased = false
                if player.state == PLAYERSTATE.NORMAL then 
                    player.jumpBase = p.pos.y
                    player.state = PLAYERSTATE.JUMPING
                    -- start
                    if SCENE == 0 then 
                        p.pos.x = 5; player.jumpBase = 5; p.pos.y = 6; p.pos.z = 4
                        player.state = PLAYERSTATE.FALLING
                        SCENE = 1
                        gameTime = 0
                        include 'lv1.lua'
                    end
                end -- PLAYERSTATE.NORMAL
            end
        else 
            player.jumpReleased = true
        end
        if lovr.headset.isDown('right', 'touchpad') then
            local tpx, tpy = lovr.headset.getAxis('right', 'touchpad')
            --print(tpx, tpy)
            --[[
            if tpy > 0.5 then 
                p.pos.x = p.pos.x - playerWalkSpd*(dT)*(math.cos(-p.facing))
                p.pos.z = p.pos.z - playerWalkSpd*(dT)*(math.sin(-p.facing))    
            elseif tpx > 0.5 then 
                p.pos.x = p.pos.x + playerWalkSpd*(dT)*(math.cos(-p.facing+(math.pi/2)))
                p.pos.z = p.pos.z + playerWalkSpd*(dT)*(math.sin(-p.facing+(math.pi/2)))
            elseif tpx < -0.5 then 
                p.pos.x = p.pos.x + playerWalkSpd*(dT)*(math.cos(-p.facing-(math.pi/2)))
                p.pos.z = p.pos.z + playerWalkSpd*(dT)*(math.sin(-p.facing-(math.pi/2)))
            ]]
            if tpy <= 0.6 then
                --forward
                p.pos.x = p.pos.x + playerWalkSpd*(dT)*(math.cos(-p.facing-(math.pi/2)))
                p.pos.z = p.pos.z + playerWalkSpd*(dT)*(math.sin(-p.facing-(math.pi/2)))
            elseif tpy > 0.6 then
                --back 
                    p.pos.x = p.pos.x + playerWalkSpd*(dT)*(math.cos(-p.facing+(math.pi/2)))
                    p.pos.z = p.pos.z + playerWalkSpd*(dT)*(math.sin(-p.facing+(math.pi/2)))
            end
            
        end 
        
    end -- end vr mode input
    
    -- reset rotation within proper range
    if p.rot > 3.14 then p.rot = -3.14 end 
    if p.rot < -3.14 then p.rot = 3.14 end
    --print(p.yaw)
    if p.yaw < -2 then p.yaw = -2 end
    if p.yaw > 2 then p.yaw = 2 end 
    
    -- * Collision * --  
    -------------------
    -- wrap this whole bitch in a for
    --[[
    for i,plat in ipairs(level.platforms) do 
        if p.state == PLAYERSTATE.FALLING then -- CATCHME CODE
            -- iterate through all platforms
            local type = 'circle'
            if type == 'square' then 
            -- platform object should have 'height offset' and 'platform size'
                local pfpos, pfs = plat.pos, plat.platform_size/2 -- position and size of platform 
                local x1, z1, x2, z2 = pfpos.x - pfs, pfpos.z - pfs, pfpos.x + pfs, pfpos.z + pfs -- rectangle of platform collider
                local h = pfpos.y + plat.platform_ofs  -- height of collider
                if (p.pos.x > x1) then 
                    if (p.pos.x < x2) then 
                        if (p.pos.z > z1) then 
                            if (p.pos.z < z2) and ((p.pos.y < (h+0.1))and((p.pos.y > (h-0.1)))) then
                                -- if the player 'feet' is within the collider height +/- 1dm
                                p.pos.y = pfpos.y + plat.platform_ofs -- lock the player height
                                p.jumpTimer = 0 -- reset timer
                                p.state = PLAYERSTATE.NORMAL -- set player state
                                break
                            end
                        end
                    end
                end
            elseif type == 'circle' then 
                local pfpos, pfr = plat.pos, plat.platform_size/2 -- radius is 1/2 diameter
                -- pfpos is offset for collision check 
                local cx = p.pos.x - pfpos.x
                local cz = p.pos.z - pfpos.z -- cx, cz is distance from collider at 0,0
                local cd = (cx^2 + cz^2) -- ignore sqrt
                local cr = pfr^2 -- ignore sqrt 
                local h = pfpos.y + plat.platform_ofs  -- height of collider
                if (cd <= cr) and ((p.pos.y < (h+0.1))and((p.pos.y > (h-0.2)))) then 
                    p.pos.y = pfpos.y + plat.platform_ofs -- lock the player height
                    p.jumpTimer = 0 -- reset timer
                    p.state = PLAYERSTATE.NORMAL -- set player state
                    break
                end
            end 
            -- end 'catchme'
        elseif p.state == PLAYERSTATE.NORMAL then -- FALLING CODE 
            -- save a little effort by filter by player state, get vars as above
            local type = 'circle'
            if type == 'square' then 
                local pfpos, pfs = plat.pos, plat.platform_size/2 
                local x1, z1, x2, z2 = pfpos.x - pfs, pfpos.z - pfs, pfpos.x + pfs, pfpos.z + pfs
                local h = pfpos.y + plat.platform_ofs  
                if (p.pos.x < x1) or (p.pos.x > x2) or (p.pos.z < z1) or (p.pos.z > z2) then
                    -- if OUT of bounds of collider rect in any of the 4 directions
                    p.state = PLAYERSTATE.FALLING
                    p.jumpTimer = 0
                    p.fallBase = p.pos.y -- to determine fall acceleration
                    break
                end
            elseif type == 'circle' then 
                local pfpos, pfr = plat.pos, plat.platform_size/2 -- radius is 1/2 diameter
                -- pfpos is offset for collision check 
                local cx = p.pos.x - pfpos.x
                local cz = p.pos.z - pfpos.z -- cx, cz is distance from collider at 0,0
                local cd = (cx^2 + cz^2) -- ignore sqrt
                local cr = pfr^2 -- ignore sqrt 
                local h = pfpos.y + plat.platform_ofs  -- height of collider
                if cd > cr then 
                    p.state = PLAYERSTATE.FALLING
                    p.jumpTimer = 0
                    p.fallBase = p.pos.y -- to determine fall acceleration
                    break
                end
            end
        end -- end 'falling'
    end -- end platform for 
    ]]
    --print(p.state)
end
