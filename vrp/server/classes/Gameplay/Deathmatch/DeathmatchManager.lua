-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Deathmatch/DeathmatchManager.lua
-- *  PURPOSE:     DeathmatchManager
-- *
-- ****************************************************************************

DeathmatchManager = inherit(Singleton)

function DeathmatchManager:constructor()
	InteriorEnterExit:new(Vector3(2522.97, -1343.70, 31.05), Vector3(834.24, 7.44, 1004.19), 270, 180, 3)
	self.m_EntryMaker = createMarker(822.49, 3.86, 1004.18, "cylinder", 1, 255, 0, 0, 125)
	self.m_EntryMaker:setInterior(3)
	addEventHandler("onMarkerHit", self.m_EntryMaker, function(hitElement, dim)
		if hitElement:getType() == "player" and dim then
			self:openGUI(hitElement)
		end
	end)
end

function DeathmatchManager:openGUI(player)
	player:triggerEvent("openDeathmatchGUI")
end
