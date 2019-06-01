-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/CoronaEffect.lua
-- *  PURPOSE:     Custom Corona class
-- *
-- ****************************************************************************

CoronaEffect = {}
CoronaEffect.Map = {}

function CoronaEffect.initalize()
    addEventHandler("onClientRender", root, CoronaEffect.update)
end

function CoronaEffect.add(marker, type, args)
    CoronaEffect.Map[marker] = {
        type = type,
        st = getTickCount(),
        args = args,
        color = {marker:getColor()},
        size = marker:getSize(),
    }
end

function CoronaEffect.getEffect(marker)
    return CoronaEffect.Map[marker]
end

function CoronaEffect.remove(marker)
    if CoronaEffect.Map[marker] then 
        CoronaEffect.Map[marker] = nil
    end
end

function CoronaEffect.update()
    if DEBUG then ExecTimeRecorder:getSingleton():startRecording("3D/CoronaEffect") end

    for marker, data in pairs(CoronaEffect.Map) do
        if isElement(marker) then
           
            local args = data.args
            local st = data.st
            if data.type == "fade" then
                local targetSize, fadeTime = args[1], args[2]
                if getTickCount() - st < fadeTime then 
                    local size = data.size + (targetSize - data.size)*(getTickCount() - st)/(fadeTime) --linear interpolation
                    marker:setSize(size)
                else
                    marker:setSize(targetSize)
                    CoronaEffect.remove(marker)
                end
            end
            if data.type == "strobe" then
                local onTime, offTime, onAlpha, offAlpha = unpack(args)
                local on = data.state
                local first = false -- iterate without timeout for the first time (so the strobe effect plays instantly)
                if on == nil then on = (marker:getAlpha() == onAlpha) first = true end
                if first or (getTickCount() - st >= (on and onTime or offTime)) then 
                    marker:setAlpha(on and offAlpha or onAlpha)
                    data.st = getTickCount()
                    data.state = not on
                end
            end
            if data.type == "blink" then
                local startSize, endSize, fadeTime, timeJitter = args[1], args[2], args[3], args[4]
                
                local fadeIn = data.state
                if fadeIn == nil then data.state = true data.jitter = math.random(-timeJitter, timeJitter) data.size = marker:getSize() end -- first time, initialise
                if fadeIn == false then -- fade out ;)
                    local size = data.size + (startSize - data.size)*(getTickCount() - st)/(fadeTime + data.jitter) --linear interpolation
                    marker:setSize(size)
                else
                    local size = data.size + (endSize - data.size)*(getTickCount() - st)/(fadeTime + data.jitter) --linear interpolation
                    marker:setSize(size)
                end
                if (getTickCount() - st) > (fadeTime + data.jitter) then 
                    data.state = not data.state
                    data.st = getTickCount()
                    data.size = marker:getSize()
                end
            end
            if DEBUG then ExecTimeRecorder:getSingleton():addIteration("3D/CoronaEffect", true) end
        else
            CoronaEffect.remove(marker)
        end
    end    
    if DEBUG then ExecTimeRecorder:getSingleton():endRecording("3D/CoronaEffect") end
end