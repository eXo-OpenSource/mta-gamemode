addEvent("latencyTest", true)
addEventHandler("latencyTest", root, function(tick)
    client:triggerEvent("latencyTestCallback", tick)
end)


addEvent("latencyTestCallback", true)
latencyHandler = function(tick)
    local l = getTickCount() - tick
    if l > 500 then
        local r = getRealTime()
        local t = r.hour ..":"..r.minute..":"..r.second
        outputChatBox("l " .. l .. " - " .. t)
    end
end
addEventHandler("latencyTestCallback", root, latencyHandler)


removeEventHandler("latencyTestCallback", root, latencyHandler)


timer = setTimer(function() 
    triggerServerEvent("latencyTest", localPlayer, getTickCount())
end, 250, 0)