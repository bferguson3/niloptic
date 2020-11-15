-- Nil Optic
-- (c) 2020 Ben Ferguson

-- Load Lua and lovr helper library stuff
m = lovr.filesystem.load('src/lib.lua'); m()

include 'src/worldLights.lua'
include 'src/getInput.lua'

-- VERSION OPTIONS -- 
DESKTOP = 1 -- set to 0 for HMD based input
INTEL = false 
EDITMODE = false

-- Globals
fRenderDelta = 0.0
sOperatingSystem = ''
fFPSAvg = 0.0
totalFrames = 0
hx, hy, hz = 0.0, 0.0, 0.0

PLAYERSTATE = {
    ['NORMAL'] = 1,
    ['JUMPING'] = 2,
    ['FALLING'] = 3
}
-- Init values
player = {
    pos = { x = 0.0, y = 0.0, z = 0.0 },
    scaledPos = {},
    rot = 0.0,
    facing = math.pi,
    state = PLAYERSTATE['NORMAL'],
    jumpTimer = 0.0,
    jumpHeight = 10.0,
    jumpBase = 0.0, 
    fallBase = 0.0,
    hmd_orient = {},
    actual_height = 170,
    yaw = 0,
    jumpReleased = true,
    gemPressed = false
}
if DESKTOP == 1 then player.actual_height = 220 end 
playerYf = 0.0
playerYDelta = 0.0
player.pos = { x = 0.0, y = 0.0, z = 0.0 }
player.scaledPos = {}
--hmdOffset = { x = 0, y = -1.0, z = 0 }
player.rot = -math.pi*(1/2)
worldScale = 1.0
local lightBlob = nil
lightPos = { 0.0, 0.0, 0.0 }
adjLightPos = {} 
sunDirection = { -0.25, -1.0, 0.0 }
sunColor = { 0.0, 0.0, 0.0, 1.0 }
worldAmbience = { 0.05, 0.05, 0.05, 1.0 }
minContrast = 0.005
lovrVer = 0
deltaTime = 0
gameTime = 0 
--Platform setup - stage test 
--platforms = { 
    
--}


function lovr.load()

    print(_VERSION)
    local a, b
    a, lovrVer, b = lovr.getVersion()
    --lovrVer = 14
    print(string.format("LOVR version: %d.%d.%d", a, lovrVer, b))
    if b == 1 then print('Intel GPU patch applied.') end
    -- print os info
    sOperatingSystem = lovr.getOS()
    print('OS detected: ' .. sOperatingSystem)
    if sOperatingSystem ~= 'Android' then 
        
        lovr.keyboard = require('src/lovr-keyboard')
        lovr.mouse = require('src/lovr-mouse')
        -- set up logfile
        myDebug.init()
        
    end
    
    player.state = PLAYERSTATE.NORMAL

    -- set up shaders
    local defaultVertex = lovr.filesystem.read('src/default.vs')
    local defaultFragment = lovr.filesystem.read('src/default.fs')
    local specularFragment = lovr.filesystem.read('src/default-specular.fs')
    local gemFrag = lovr.filesystem.read('src/gemshader.fs')
    --local wireframeFrag = lovr.filesystem.read('src/wireframe.fs')
    
    -- Init light blob 
    lightBlob = lovr.graphics.newShaderBlock(
        'uniform', 
        {
            pointLightCount  = 'int', 
            pointLightPositions = { 'vec4', 16 },
            pointLightColors = { 'vec4', 16 },
            sunColor = 'vec4', --sun.diffuse
            sunDirection = 'vec3',
            worldAmbience = 'vec4', --sun.ambience
            pointLightCLQ = { 'vec4', 16 }
        },
        {}
    )
    lightBlob:send('sunDirection', sunDirection)
    lightBlob:send('sunColor', sunColor)
    lightBlob:send('worldAmbience', worldAmbience)
    lightBlob:send('pointLightCLQ', worldLights.getCLQs())
    
    shader = lovr.graphics.newShader(
        lightBlob:getShaderCode('lightBlob') .. defaultVertex,
        lightBlob:getShaderCode('lightBlob') .. defaultFragment, 
        { flags = {
            uniformScale = true
        }}
    )
    
    specShader = lovr.graphics.newShader(
        lightBlob:getShaderCode('lightBlob') .. defaultVertex,
        lightBlob:getShaderCode('lightBlob') .. defaultFragment, 
        { flags = {
            uniformScale = true
        }}
    )
    gemShader = lovr.graphics.newShader(
        lightBlob:getShaderCode('lightBlob') .. defaultVertex,
        lightBlob:getShaderCode('lightBlob') .. gemFrag, 
        { flags = {
            uniformScale = true
        }}
    )
    lovr.headset.setClipDistance(0.1, 100)
 -- Red light -- not as harsh, long range low poer
    worldLights.createWorldLight(
        { -3.0, 1.0, -3.0 }, -- position
        { 1.0, 0.1, 0.1 }, -- RGB
        { 0.0, 0.1, 0.1 }, -- CLQ 
        'flicker', -- not used
        0.2 -- not used
    )
    -- Blue light -- harsh, moderate range
    worldLights.createWorldLight(
        { 3.0, 1.0, -2.75 }, 
        { 0.1, 0.1, 1.0 }, 
        { 0.0, 0.1, 0.05 }
    )
    -- Green light -- dull and short range, all light from it fades after ~6m
    worldLights.createWorldLight(
        { -1.0, 3.3, -4.1 }, 
        { 0.3, 1.0, 0.3 }, 
        { 0.0, 0.2, 0.2 }
    )
    
    --[[Wire frame shader bs]]
    --wfShader = lovr.graphics.newShader(
    --    defaultVertex, wireframeFrag, { flags = { uniformScale = true }}
   -- )
    --wireframeTex = lovr.graphics.newTexture('tex/wireframe.png', 1, 1, 1, 1)
    --wireframeTex2 = lovr.graphics.newTexture('Sphere.png', 1, 1, 1, 1)
    
    
    -- load textures
    
    -- sfx
    
    --lovr.graphics.setDepthTest('greater', true)
    lovr.graphics.setCullingEnabled(true)
    SCENE = 0
end
 

function lovr.mirror()
    lovr.graphics.clear()
    lovr.draw()
end


function lovr.update(dT)
    -- Per-frame ticks
    deltaTime = dT 
    gameTime = gameTime + dT
    fRenderDelta = os.clock()
    totalFrames = totalFrames + 1
    if totalFrames > 1e7 then totalFrames = 0 end 
    local fr 
    
    if sOperatingSystem ~= 'Android' then 
        if myDebug.showFPS or myDebug.logFPS then fr = 1/dT end 
        if myDebug.showFPS then 
            print('update delta', dT, '/ FPS: ', fr)
        end 
        if myDebug.logFPS then 
            fFPSAvg = fFPSAvg + fr
        end
    end
    
    local lp = player 
   
    
    -- INPUT
    GetInput(dT)
    if EDITMODE then lp.state = PLAYERSTATE.NORMAL end

    -- Scale player position to match worldScale variable
    hx, hy, hz = lovr.headset.getPosition()
    --hy = hy + hmdOffset.y 
    lp.scaledPos = {
        x = lp.pos.x * worldScale + hx,
        y = lp.pos.y * worldScale + hy,
        z = lp.pos.z * worldScale + hz,
    }
    
    -- Jump position code 
    local GRAVITY = 2
    local playerYf = lp.pos.y 
    if lp.state == PLAYERSTATE.JUMPING then 
        lp.jumpTimer = lp.jumpTimer + dT
        lp.pos.y = lp.jumpBase + (lp.jumpHeight * math.sin(lp.jumpTimer)) - (lp.jumpTimer * lp.jumpTimer * GRAVITY)
        local playerYDelta = lp.pos.y - playerYf 
        if playerYDelta < 0 then   
            lp.state = PLAYERSTATE.FALLING
            lp.jumpTimer = 0
            lp.fallBase = lp.pos.y
        end
    elseif lp.state == PLAYERSTATE.FALLING then 
        lp.jumpTimer = lp.jumpTimer + dT 
        --lp.pos.y = lp.fallBase - (lp.jumpTimer * lp.jumpTimer * GRAVITY)
        local dy = playerYf - (lp.fallBase - (lp.jumpTimer * lp.jumpTimer * GRAVITY))
        if dy >= 0.20 then dy = 0.19 end
        lp.pos.y = lp.pos.y - dy 
        if lp.pos.y < 0 then 
            lp.pos.y = 0  
            lp.jumpTimer = 0
            lp.state = PLAYERSTATE.NORMAL 
        end
    end
    
    -- LIGHTING
    -- quick animation
    for i=1,3 do 
        worldLights.lights[i].position[1] = lp.pos.x 
        worldLights.lights[i].position[2] = lp.pos.y + 2
        worldLights.lights[i].position[3] = lp.pos.z
    end
    worldLights.lights[1].position[1] = lp.pos.x + 4*math.sin(totalFrames/120)
    worldLights.lights[2].position[1] = lp.pos.x + 4*math.cos(totalFrames/120)
    worldLights.lights[3].position[2] = lp.pos.y + 4*math.sin(totalFrames/120)
    
    lightBlob:send('sunDirection', sunDirection)
    lightBlob:send('pointLightCount', worldLights.getLightCount()) 
    lightBlob:send('pointLightColors', worldLights.getLightColors())
    lightBlob:send('pointLightPositions', worldLights.getLightPositions())
    lightBlob:send('pointLightCLQ', worldLights.getCLQs())
    
    shader:sendBlock('lightBlob', lightBlob)
    specShader:sendBlock('lightBlob', lightBlob)

    
    -- Create camera projection based on scaled world and headset offsets
    local hof = (lp.actual_height - 170.0)/100.0
    
    camera = lovr.math.newMat4():lookAt(
        vec3(lp.scaledPos.x, lp.scaledPos.y + hof, lp.scaledPos.z),
        vec3(lp.scaledPos.x + math.cos(lp.rot), 
             lp.scaledPos.y + hof + lp.yaw, 
             lp.scaledPos.z + math.sin(lp.rot)))
    lightcam = camera
    view = lovr.math.newMat4(camera):invert()
    
    if (SCENE > 0) then
        if (lp.scaledPos.y+hof < (gameTime/3)-1.0) then 
            SCENE = -1
            gameTime = 0
            lp.pos.x = 0; lp.pos.y = 0; lp.pos.z = 0
            sfxDeath:play()
        end
    end  

    -- Check gem collision 
    --[[
    for i,g in ipairs(level.gems) do
        local x1, x2 = g.x-1, g.x+1
        local y1, y2 = g.y-1, g.y+1
        local z1, z2 = g.z-1, g.z+1 
        if not g.got then 
            if lp.pos.x >= x1 and lp.pos.x <= x2 then 
                if lp.pos.y+1.7 >= y1 and lp.pos.y+1.7 <= y2 then 
                    if lp.pos.z >= z1 and lp.pos.z <= z2 then 
                        g.got = true
                        sfxGem:play()
                    end
                end
            end
        end
    end
    ]]

    --specShader:send('specularStrength', 0.5)
    --specShader:send('metallic', 32.0)
    -- Adjust head position (for specular)
    if lovr.headset then 
        hx, hy, hz = lovr.headset.getPosition()
        --specShader:send('viewPos', { hx + player.scaledPos.x, 
        --                             hy + player.scaledPos.y + hmdOffset.y, 
        --                             hz + player.scaledPos.z, 1.0 } )
        --shader:send('viewPos', { hx, hy, hz })
    else
        print('WARNING - Headset driver failed to load')
        --specShader:send('viewPos', { player.pos.x, player.pos.y, player.pos.z })
    end
    
end

SCENE = 0
sin = math.sin

lg = lovr.graphics

function lovr.draw()
    lovr.graphics.clear(worldAmbience)
    lovr.graphics.transform(view)
    
    lg.print('hello world', 0, 2, -2)

    lovr.graphics.reset()
end



function lovr.quit()
    if sOperatingSystem ~= 'Android' then 
        if myDebug.logFPS then 
            myDebug.print('Average FPS: ' .. round(fFPSAvg/totalFrames, 2))
        end
    end
    
end

