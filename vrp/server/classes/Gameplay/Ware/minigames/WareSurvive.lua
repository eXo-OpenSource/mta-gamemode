-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Ware/minigames/WareSurvive.lua
-- *  PURPOSE:     WareSurvive class
-- *
-- ****************************************************************************
WareSurvive = inherit(Object)
WareSurvive.modeDesc = "Bleib am Leben!"
WareSurvive.time = 1
local allowedWeapons = 
{
	24,25,31,34,35,38,18,16
}

function WareSurvive:constructor( super )
	self.m_Super = super
	self.m_Super.m_Successors = {}
	for key, p in ipairs(self.m_Super.m_Players) do 
		p:setData("ware:dead",0)
	end
	self:giveWeapons()
end

function WareSurvive:giveWeapons()
	if self.m_Super.m_Arena then 
		local randWeap = allowedWeapons[math.random(1, #allowedWeapons)]
		for key, p in ipairs(self.m_Super.m_Players) do 
			giveWeapon(p, randWeap, 9999,true)
		end
	end
end

function WareSurvive:onDeath( player, killer, weapon  )
	local isWareSurvive = player:getData("ware:dead")
	if isWareSurvive == 0 then 
		player:setData("ware:dead",1)
	end
end

function WareSurvive:destructor()
	for key, p in ipairs(self.m_Super.m_Players) do 
		if p:getData("ware:dead") == 0 then 
			self.m_Super:addPlayerToWinners( p) 
		end
		takeAllWeapons(p)
	end
end