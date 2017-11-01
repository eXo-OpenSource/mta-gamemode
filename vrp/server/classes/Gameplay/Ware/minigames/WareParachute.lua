-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Ware/minigames/WareParachute.lua
-- *  PURPOSE:     WareParachute class
-- *
-- ****************************************************************************
WareParachute = inherit(Object)
WareParachute.modeDesc = "Lande auf der Plattform!"
WareParachute.timeScale = 2
WareParachute.smallPlatform = false

function WareParachute:constructor( super )
	self.m_Super = super
	if WareParachute.smallPlatform then
		self:createPlatform()
	end
	self:portPlayers(250, true)

end

function WareParachute:createPlatform()
	if self.m_Super.m_Arena then
		local x,y,z,width,height = unpack(self.m_Super.m_Arena)
		if x and y and z and width and height then
			self.m_PlatformObj = createObject(3095,x+5+math.random(width*0.5),y+5+math.random(height*0.5),z+8)
			setElementDimension(self.m_PlatformObj,self.m_Super.m_Dimension)
		end
	end
end

function WareParachute:portPlayers(zOffset, bPara)
	local x, y, z, width, height = unpack(self.m_Super.m_Arena)
	for key, p in ipairs(self.m_Super.m_Players) do
		p:triggerEvent("PlatformEnv:toggleColShapeHitRespawn", false)
		p:triggerEvent("PlatformEnv:toggleWallCollission", false)
		p:setPosition((x+5)+ math.random(0,width-5), (y+5)+ math.random(0,height-5),z+zOffset)
		if bPara then
			p:giveWeapon(46, 1, true)
		end
	end
end

function WareParachute:destructor()
	self:portPlayers(1, false)
	for key, p in ipairs(self.m_Super.m_Players) do
		if WareParachute.smallPlatform then
			if getPedContactElement(p) == self.m_PlatformObj then
				self.m_Super:addPlayerToWinners(p)
			end
		else
			if p:getPosition().z >= Ware.arenaZ and p:isOnGround() and not p:isDead() then
				self.m_Super:addPlayerToWinners(p)
			end
		end
		p:triggerEvent("PlatformEnv:toggleColShapeHitRespawn", true)
		p:triggerEvent("PlatformEnv:toggleWallCollission", true)

	end
	if self.m_PlatformObj then
		destroyElement(self.m_PlatformObj)
	end
end
