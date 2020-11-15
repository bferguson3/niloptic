
worldLights = {}
worldLights.lights = {}

--[[
  World Lights!!
  -----
  worldLights.createWorldLight(
      { x, y, z } -- world position
      { r, g, b } -- color (out of 1.0)
      { constant, linear, quadratic } -- light falloff, aka CLQ (floats, generally 0.0 to 1.0)
      -- the other four params need to be implemented
    )
    CLQ explanation - 
    Constant falloff - affects glare of light, immediate falloff.
    Linear falloff - Has most effect on diffuse power of light. higher = broader area
    Quadratic falloff - has most effect on distance. 
    clq examples:
    0, 0.5, 0.5 : ~1m bright light, ~10m ambience
    1, 0, 0 : light goes on forever but not super bright 
    0, 1, 0 : light lasts about 25m ambient
    0, 0, 1 : light is very harsh and fades totally in 1-2m 
]]


worldLights.createWorldLight = function (worldPos, color, clq, effect, effectDelta, chromaArray, customMove)
        local worldPos = worldPos or { 1.0, 1.0, 1.0, 1.0 };
        local color = color or { 1.0, 1.0, 1.0 };
        local clq = clq or { 0.4, 0.4, 0.2 };
        local effect = effect or nil; 
        local effectDelta = effectDelta or nil;
        local chromaArray = chromaArray or nil; 
        local customMove = customMove or nil;
        local o = {}
        if worldPos then o.position = worldPos end 
        if color then o.color = color end 
        if clq then o.clq = clq end 
        if effect then o.effect = effect end
        if effectDelta then o.effectDelta = effectDelta end 
        if chromaArray then o.chromaArray = chromaArray end 
        if customMove then o.customMove = customMove end 
        
        table.insert(worldLights.lights, o)
        
        return o 
    end

worldLights.getLightPositions = function ()
    -- needs to override worldLights.lightPositions, a vec4 array
    local o = {}
    for i=1,#worldLights.lights do
        local p = {}
        p[1] = worldLights.lights[i].position[1] - player.scaledPos.x
        p[2] = worldLights.lights[i].position[2] - player.scaledPos.y
        p[3] = worldLights.lights[i].position[3] - player.scaledPos.z
        p[4] = 1.0
        
        table.insert(o, p)
    end
    return o
end

worldLights.getLightColors = function ()
    
    local o = {}
    for i=1,#worldLights.lights do 
        p = worldLights.lights[i].color
        p[4] = 1.0
        table.insert(o, p)
    end 
    return o
end

worldLights.getLightCount = function ()
    
    return tonumber(#worldLights.lights)
end

worldLights.getLightRanges = function () 
    local o = {}
    for i = 1, #worldLights.lights do 
        local c = worldLights.lights[i].range * worldScale;
        table.insert(o, c)
    end
    return o
end

worldLights.getWorldPos = function (n)
    local x, y, z
    x = worldLights.lights[n].position[1]
    y = worldLights.lights[n].position[2]
    z = worldLights.lights[n].position[3]
    return x, y, z 
end

worldLights.drawPointLights = function () 
    for i = 1, #worldLights.lights do 
        local x, y, z = worldLights.getWorldPos(i)
        local c = worldLights.lights[i].color -- {R,G,B}
        lovr.graphics.setColor(c[1], c[2], c[3], 1.0)
        lovr.graphics.sphere(x, y, z, 0.1)
    end
end

worldLights.getCLQs = function () 
    local o = {}
    for i = 1, #worldLights.lights do 
        p = {}
        table.insert(p, worldLights.lights[i].clq[1])
        table.insert(p, worldLights.lights[i].clq[2])
        table.insert(p, worldLights.lights[i].clq[3])
        table.insert(p, 1.0)
        table.insert(o, p)
    end
    return o 
end