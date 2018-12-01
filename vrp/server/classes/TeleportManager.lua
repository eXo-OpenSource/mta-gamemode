-- ****************************************************************************
-- *
-- * PROJECT: vRoleplay
-- * FILE: server/classes/TeleportManager.lua
-- * PURPOSE: Manages Teleporter-Instances and the keybind-stuff
-- *
-- ****************************************************************************
TeleportManager = inherit(Singleton)
TeleportManager.Map = {}
addRemoteEvents{"onTryEnterTeleporter"}
function TeleportManager:constructor()
	addEventHandler("onTryEnterTeleporter", root, bind(self.Event_KeyBindTeleport, self))
end

function TeleportManager:Event_KeyBindTeleport()
	if client and client.m_Teleporter then 
		local instance, marker, type = unpack(client.m_Teleporter)
		if TeleportManager.Map[instance] and self:check(client, marker) then 
			if type == "enter" then
				instance:teleport(client, "enter", instance.m_InteriorPosition, instance.m_InteriorRotation, instance.m_InteriorId, instance.m_Dimension)
			else 
				instance:teleport(client, "exit", instance.m_EntryPosition, instance.m_EnterRotation, instance.m_EnterInterior or 0, instance.m_EnterDimension or 0)
			end
		end
	end
end

function TeleportManager:check( player, pickup)
	if player and isElement(player) and pickup and isElement(pickup) then 
		if (player:getPosition() - pickup:getPosition()):getLength() < 2 and (pickup:getInterior() == player:getInterior()) and (pickup:getDimension()==player:getDimension()) then
			return true
		end
	end
	return false
end

function TeleportManager:destructor()

end
