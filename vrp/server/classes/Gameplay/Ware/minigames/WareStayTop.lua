-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Ware/minigames/WareStayTop.lua
-- *  PURPOSE:     WareStayTop class
-- *
-- ****************************************************************************
WareStayTop = inherit(Object)
WareStayTop.modeDesc = "Bleib auf dem Boden!"
WareStayTop.time = 1
WareStayTop.rotateTimes =
{
	[1] = 8000,
	[2] = 6000,
	[3] = 4000,
}
function WareStayTop:constructor( super )
	self.m_Super = super
	self.m_Super.m_Successors = {}
	self.m_RandomTiles = {}
	for i = 1, 5 do
		self.m_RandomTiles[i] = math.random(1, 16)
	end
	self.m_RandomTiles2 = {}
	local randNumber, skipNumber
	for i2 = 1, 5 do
		randNumber = math.random(1, 16 )
		skipNumber = false
		for i = 1, #self.m_RandomTiles do
			if self.m_RandomTiles[i] == randNumber then
				skipNumber = true
			end
		end
		if not skipNumber then self.m_RandomTiles2[i2] = randNumber end
	end
	for key, p in ipairs(self.m_Super.m_Players) do
		for i = 1, #self.m_RandomTiles do
			p:triggerEvent("PlatformEnv:rotateTile", self.m_RandomTiles[i], WareStayTop.rotateTimes[self.m_Super.m_Gamespeed])
			p:triggerEvent("PlatformEnv:toggleColShapeHitRespawn", false)

			self.m_RotateTimer = setTimer(function()
				if self then
					p:triggerEvent("PlatformEnv:rotateTile", self.m_RandomTiles2[i], WareStayTop.rotateTimes[self.m_Super.m_Gamespeed])
				end
			end, 2000/self.m_Super.m_Gamespeed, 1)
		end
	end
end

function WareStayTop:destructor()
	if self.m_RotateTimer and isTimer(self.m_RotateTimer) then killTimer(self.m_RotateTimer) end
	local x, y, z
	for key, p in ipairs(self.m_Super.m_Players) do
		p:triggerEvent("PlatformEnv:toggleColShapeHitRespawn", true)
		p:triggerEvent("PlatformEnv:resetAllTiles")
		x,y,z = getElementPosition(p)
		if z >= Ware.arenaZ then
			self.m_Super:addPlayerToWinners( p)
		end
	end
end
