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
            if DEBUG then ExecTimeRecorder:getSingleton():addIteration("3D/CoronaEffect", true) end
        else

        end
    end    
    if DEBUG then ExecTimeRecorder:getSingleton():endRecording("3D/CoronaEffect") end
end