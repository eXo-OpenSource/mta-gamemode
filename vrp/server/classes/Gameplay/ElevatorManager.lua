-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/ElevatorManager.lua
-- *  PURPOSE:     ElevatorManager class
-- *
-- ****************************************************************************
ElevatorManager = inherit(Object)
ElevatorManager.Map = {}
addRemoteEvents{"onTryElevator"}

function ElevatorManager:constructor()
    addEventHandler("onTryElevator", root, bind(self.Event_onTryElevator, self))
end

function ElevatorManager:destructor()

end

function ElevatorManager:Event_onTryElevator()
    if client.m_ElevatorData and client.m_ElevatorData[1] and client.m_ElevatorData[2] and ElevatorManager.Map[client.m_ElevatorData[1]] then 
        self:check(client,  client.m_ElevatorData)
    end
end


function ElevatorManager:check(player, obj)
    local elevator, marker = unpack(obj)
    if elevator and marker and isElement(marker) then
        if self:checkRange(marker, player) then 
            elevator:showElevator(player, marker)
        end
    end
    return
end

function ElevatorManager:checkRange(element, player)
    return Vector3(element:getPosition() - player:getPosition()):getLength() < 3 
end