function addRemoteEvents(eventList)
    for _, v in pairs(eventList) do
        addEvent(v, true)
    end
end

function getPlayerFromPartialName(name)
    local name = name and name:gsub("#%x%x%x%x%x%x", ""):lower() or nil
    if name then
        for _, player in ipairs(getElementsByType("player")) do
            local name_ = getPlayerName(player):gsub("#%x%x%x%x%x%x", ""):lower()
            if name_:find(name, 1, true) then
                return player
            end
        end
    end
end

Player = {}
registerElementClass("player", Player)

function Player:triggerEvent(ev, ...)
    triggerClientEvent(self, ev, self, ...)
end

local function search (key, elements)
    for i, v in ipairs(elements) do
        if tostring(v.key) == tostring(key) then
            if type(v.value) ~= "function" then
                return v.value
            else
                return v.value()
            end
        end
    end

    return false
end

function case (name)
    return function(value)
        return {key = name, value = value}
    end
end

function switch (searchFor)
    return function(elements)
        local result = search(searchFor, elements)
        if not result then
            return search("default", elements)
        end

        return result
    end
end