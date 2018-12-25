-- ****************************************************************************
-- *
-- * PROJECT: vRoleplay
-- * FILE: server/classes/InteriorEnterExitManager.lua
-- * PURPOSE: Interior enter/exit manager
-- *
-- ****************************************************************************
InteriorEnterExitManager = inherit(Singleton)
InteriorEnterExitManager.Map ={}

addRemoteEvents{"clientTryEnterEntrance"}
function InteriorEnterExitManager:constructor() 
    addEventHandler("clientTryEnterEntrance", root, bind(self.Event_requestEntrance, self))
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