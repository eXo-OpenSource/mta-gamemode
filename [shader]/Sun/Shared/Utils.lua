local clientFpsVar = 0
local clientFpsStartTick = false
local clientFpsCurrentTick = 0

function getFps()
    
    if not (clientFpsStartTick) then
        clientFpsStartTick = getTickCount()
    end
        
    clientFpsVar = clientFpsVar + 1
    clientFpsCurrentTick = getTickCount()
        
    if ((clientFpsCurrentTick - clientFpsStartTick) >= 1000) then
        clientFps = clientFpsVar
        
        clientFpsVar = 0
        clientFpsStartTick = false
    end
    
    if (clientFps) then
		return clientFps
    else
        return 0
    end
end

function getAttachedPosition(x, y, z, rx, ry, rz, distance, angleAttached, height)
 
    local nrx = math.rad(rx);
    local nry = math.rad(ry);
    local nrz = math.rad(angleAttached - rz);
    
    local dx = math.sin(nrz) * distance;
    local dy = math.cos(nrz) * distance;
    local dz = math.sin(nrx) * distance;
    
    local newX = x + dx;
    local newY = y + dy;
    local newZ = (z + height) - dz;
    
    return newX, newY, newZ;
end