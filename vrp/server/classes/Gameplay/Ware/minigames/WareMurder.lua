-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Ware/minigames/WareMurder.lua
-- *  PURPOSE:     WareMurder class
-- *
-- ****************************************************************************
WareMurder = inherit(Object)
WareMurder.modeDesc = "Ein Killer ist unterwegs!"
WareMurder.time = 1.4
local allowedWeapons = 
{
	24,25,31,34,35,38,18,16
}

function WareMurder:constructor( super )
	self.m_Super = super
	self.m_Super.m_Successors = {}
	for key, p in ipairs(self.m_Super.m_Players) do 
		p:setData("ware:dead",0)
	end
	self:giveWeapons()
end

function WareMurder:giveWeapons()
	if self.m_Super.m_Arena then 
		if #self.m_Super.m_Players > 0 then
			local randWeap = allowedWeapons[math.random(1, #allowedWeapons)]
			local murder = math.random(1, #self.m_Super.m_Players)
			self.m_Murder = self.m_Super.m_Players[murder]
			if isElement(self.m_Murder) then  
				giveWeapon(self.m_Murder, randWeap, 9999,true)
			end
		end
	end
end

function WareMurder:onDeath( player, killer, weapon  )
	local isWareDead = player:getData("ware:dead")
	if isWareDead == 0 then 
		player:setData("ware:dead",1)
	end
end

function WareMurder:destructor()
	local deadCount = 0
	for key, p in ipairs(self.m_Super.m_Players) do 
		if p:getData("ware:dead") == 0 and p ~= self.m_Murder then 
			self.m_Super:addPlayerToWinners( p) 
		else 
			deadCount = deadCount + 1
		end
		takeAllWeapons(p)
	end
	if deadCount >= 2 then 
		self.m_Super:addPlayerToWinners( self.m_Murder ) 
		takeAllWeapons(self.m_Murder)
	end
end