-- ****************************************************************************
-- *
-- * PROJECT: vRoleplay
-- * FILE: server/classes/InteriorEnterExitManager.lua
-- * PURPOSE: Interior enter/exit manager
-- *
-- ****************************************************************************
InteriorEnterExitManager = inherit(Singleton)
InteriorEnterExitManager.Map ={}

addRemoteEvents{"clientTryEnterEntrance", "InteriorEnterExit:onEnterColHit", "InteriorEnterExit:onExitColHit"}
function InteriorEnterExitManager:constructor() 
    addEventHandler("clientTryEnterEntrance", root, bind(self.Event_requestEntrance, self))
    addEventHandler("InteriorEnterExit:onEnterColHit", root, bind(self.onEnterColHit, self))
    addEventHandler("InteriorEnterExit:onExitColHit", root, bind(self.onExitColHit, self))
end

function InteriorEnterExitManager:destructor()

end

function InteriorEnterExitManager:Event_requestEntrance()
    if client.m_LastEnterExit and not getPedOccupiedVehicle(client) then 
        self:check(client, client.m_LastEnterExit)
    end
end

function InteriorEnterExitManager:check(player, enterExit)
    local id, type = unpack(enterExit)
    if id and InteriorEnterExitManager.Map[id] then 
        local obj = InteriorEnterExitManager.Map[id]
        if type == "enter" then 
            if obj.m_EnterMarker and self:checkRange(obj.m_EnterMarker, player) then 
                obj:enter(player)
            end
        else 
            if obj.m_ExitMarker and self:checkRange(obj.m_ExitMarker, player) then 
                obj:exit(player)
            end 
        end
    end
    return
end

function InteriorEnterExitManager:checkRange(element, player)
    return Vector3(element:getPosition() - player:getPosition()):getLength() < 3 
end

function InteriorEnterExitManager:sendInteriorEnterExitToClient(player)
	if not player then player = root end
	for key, enterexit in pairs(InteriorEnterExitManager.Map) do
		local x, y, z = getElementPosition(enterexit.m_EnterMarker)
        triggerClientEvent(player, "ColshapeStreamer:registerColshape", player, {x, y, z+0.2}, enterexit.m_EnterMarker, "enterexit", enterexit.m_Id, 2, "InteriorEnterExit:onEnterColHit")
        local x, y, z = getElementPosition(enterexit.m_ExitMarker)
        triggerClientEvent(player, "ColshapeStreamer:registerColshape", player, {x, y, z+0.2}, enterexit.m_ExitMarker, "enterexit", enterexit.m_Id, 2, "InteriorEnterExit:onExitColHit")
	end
end

function InteriorEnterExitManager:onEnterColHit(id)
    InteriorEnterExitManager.Map[id]:onEnterColHit(client)
end

function InteriorEnterExitManager:onExitColHit(id)
    InteriorEnterExitManager.Map[id]:onExitColHit(client)
end