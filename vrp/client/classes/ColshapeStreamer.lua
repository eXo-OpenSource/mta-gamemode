-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/ColshapeStreamer.lua
-- *  PURPOSE:     creates/destroys ColShapes onStreamIn/Out
-- *
-- ****************************************************************************

ColshapeStreamer = inherit(Singleton)
ColshapeStreamer.Map = {}
addRemoteEvents{"ColshapeStreamer:registerColshape", "ColshapeStreamer:deleteColshape"}

function ColshapeStreamer:constructor()
    self.m_StreamInBind = bind(self.onStreamIn, self)
    self.m_StreamOutBind = bind(self.onStreamOut, self)

    self.m_RegisterBind = bind(self.registerColshape, self)
    addEventHandler("ColshapeStreamer:registerColshape", root, self.m_RegisterBind)

    self.m_DeleteBind = bind(self.deleteColshape, self)
    addEventHandler("ColshapeStreamer:deleteColshape", root, self.m_DeleteBind)
end

function ColshapeStreamer:destructor()

end

function ColshapeStreamer:registerColshape(pos, element, category, elementId, size, colshapeHitEvent, colshapeLeaveEvent, streamInEvent, streamOutEvent)
    local index = #ColshapeStreamer.Map+1
    ColshapeStreamer.Map[index] = {}
    ColshapeStreamer.Map[index].element = element
    ColshapeStreamer.Map[index].element.index = index
    ColshapeStreamer.Map[index].colshapePosition = pos
    ColshapeStreamer.Map[index].category = category
    ColshapeStreamer.Map[index].elementId = elementId
    ColshapeStreamer.Map[index].colshapeSize = size
    ColshapeStreamer.Map[index].colshapeHitEvent = colshapeHitEvent
    if colshapeLeaveEvent then
        ColshapeStreamer.Map[index].colshapeLeaveEvent = colshapeLeaveEvent
    end
    if streamInEvent then
        ColshapeStreamer.Map[index].streamInEvent = streamInEvent
    end
    if streamOutEvent then
        ColshapeStreamer.Map[index].streamOutEvent = streamOutEvent
    end
    addEventHandler("onClientElementStreamIn", ColshapeStreamer.Map[index].element, self.m_StreamInBind)
    addEventHandler("onClientElementStreamOut", ColshapeStreamer.Map[index].element, self.m_StreamOutBind)

    if isElementStreamedIn(element) then
        triggerEvent("onClientElementStreamIn", ColshapeStreamer.Map[index].element)
    end
end

function ColshapeStreamer:deleteColshape(category, elementId)
    for key, colshape in pairs(ColshapeStreamer.Map) do
        if colshape.category == category and colshape.elementId == elementId then
            if colshape.colshape then colshape.colshape:destroy() end
            ColshapeStreamer.Map[key] = nil
        end
    end
end

function ColshapeStreamer:onStreamIn()
    local element = ColshapeStreamer.Map[source.index]
    element.colshape = createColSphere(element.colshapePosition[1], element.colshapePosition[2], element.colshapePosition[3], element.colshapeSize)
    element.colshape:setDimension(source:getDimension())
    if element.category == "beggarped" then
        element.colshape:attach(source)
    end
    
    addEventHandler("onClientColShapeHit", element.colshape, function(hit, dim)
        if hit == localPlayer and dim then
            triggerServerEvent(element.colshapeHitEvent, localPlayer, element.elementId)
        end
    end)
    if element.colshapeLeaveEvent then
        addEventHandler("onClientColShapeLeave", element.colshape, function(hit, dim)
            if hit == localPlayer and dim then
                triggerServerEvent(element.colshapeLeaveEvent, localPlayer, element.elementId)
            end
        end)
    end
end

function ColshapeStreamer:onStreamOut()
    local element = ColshapeStreamer.Map[source.index]
    if element.colshape then 
        element.colshape:destroy()
        element.colshape = nil
    end
end