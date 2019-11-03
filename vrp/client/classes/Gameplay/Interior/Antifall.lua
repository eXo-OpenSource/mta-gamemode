-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Interior/Antifall.lua
-- *  PURPOSE:     Handles falling through Interiors
-- *
-- ****************************************************************************
Antifall = inherit(Object) 

ANTIFALL_COOLDOWN = 2000

function Antifall:constructor() 
	self.m_Initial = {getElementPosition(localPlayer)}
	self.m_Time = getTickCount()
	self.m_Update = bind(self.update, self)
	addEventHandler("onClientPreRender", root, self.m_Update)
end

function Antifall:destructor()
	removeEventHandler("onClientPreRender", root, self.m_Update)
end

function Antifall:update() 
	local x, y, z = getElementPosition(localPlayer)
	local dist = getDistanceBetweenPoints2D(self.m_Initial[1], self.m_Initial[2], x, y)
	if dist > .5 then 
		delete(self)
	end
	if (self.m_Initial[3] - z) > 2 then 
		if (getTickCount() - self.m_Time) > ANTIFALL_COOLDOWN then
			triggerServerEvent("InteriorManager:onFall", localPlayer)
			self.m_Time = getTickCount()
		end
	end
end