lovrWhite = { 1.0, 1.0, 1.0, 1.0 }
lovrBlack = { 0.0, 0.0, 0.0, 1.0 }
lovrRed = { 1.0, 0.0, 0.0, 1.0 }
lovrGreen = { 0.0, 1.0, 0.0, 1.0 }
lovrBlue = { 0.0, 0.0, 1.0, 1.0 }

EGA = {
    {0.0, 0.0, 0.0, 1.0},
    {0.0, 0.0, 0.67, 1.0},
    {0.0, 0.67, 0.0, 1.0},
    {0.0, 0.67, 0.67, 1.0},
    {0.67, 0.0, 0.0, 1.0},
    {0.67, 0.0, 0.67, 1.0},
    {0.67, 0.33, 0.0, 1.0},
    {0.67, 0.67, 0.67, 1.0},
    {0.33, 0.33, 0.33, 1.0},
    {0.33, 0.33, 1.0, 1.0},
    {0.33, 1.0, 0.33, 1.0},
    {0.33, 1.0, 1.0, 1.0},
    {1.0, 0.33, 0.33, 1.0},
    {1.0, 0.33, 1.0, 1.0},
    {1.0, 1.0, 0.33, 1.0},
    {1.0, 1.0, 1.0, 1.0},
}

--# First, check out the commit you wish to go back to (get sha-1 from git log)
--e.g. if full SHA1 is 9d3c3a0caa7f7b35ef15adb96fc80fcbb59ac72a:
--git reset --hard 9d3c3a0caa7f7b35ef15adb96fc80fcbb59ac72a
--# Then do a forced update.
--git push origin +9d3c3a0caa7f7b35ef15adb96fc80fcbb59ac72a^:master
--# Push specific commit
--git push origin 9d3c3a0caa7f7b35ef15adb96fc80fcbb59ac72a:master

function round(num, numDecimalPlaces)
    -- From luausers
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function include(fileName)
    local m = lovr.filesystem.load(fileName)
    m()
end

-- define myDebug object 
myDebug = {
    showFPS = false,
    logFPS = false,
    showFrameDelta = false
}

myDebug.init = function()
    myDebug.file = 'myDebug' .. os.time() .. '.log'
    lovr.filesystem.write(myDebug.file, '')
end

myDebug.print = function (tx) 
    lovr.filesystem.append(myDebug.file, tx .. '\n')
    print(tx)
end
  
function incbin(fn)
    return lovr.filesystem.read(fn)
end

function split (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

--[[
function bitoper(a, b, oper)
   local r, m, s = 0, 2^52
   repeat
      s,a,b = a+b+m, a%m, b%m
      r,m = r + m*oper%(s-a-b), m/2
   until m < 1
   return r
end

function AND(a, b)
    return bitoper(a, b, 4)
end

function XOR(a, b)
    return bitoper(a, b, 3)
end

function OR(a, b)
    return bitoper(a, b, 1)
end
]]
function AND(a, b)
    local result = 0
    local bitval = 1
    while a > 0 and b > 0 do
      if a % 2 == 1 and b % 2 == 1 then -- test the rightmost bits
          result = result + bitval      -- set the current bit
      end
      bitval = bitval * 2 -- shift left
      a = math.floor(a/2) -- shift right
      b = math.floor(b/2)
    end
    return result
end

function clamp(min, val, max)
    return math.max(min, math.min(val, max));
end