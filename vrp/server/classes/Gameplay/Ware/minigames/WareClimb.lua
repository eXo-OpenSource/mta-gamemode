-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Ware/minigames/WareClimb.lua
-- *  PURPOSE:     WareClimb class
-- *
-- ****************************************************************************
WareClimb = inherit(Object)
WareClimb.modeDesc = "Kletter auf die Plattform!"
WareClimb.timeScale = 0.8

function WareClimb:constructor( super )
	self.m_Super = super
	self:createPlatform()
end

function WareClimb:createPlatform()
	if self.m_Super.m_Arena then 
		local x,y,z,width,height = unpack(self.m_Super.m_Arena)
		if x and y and z and width and height then 
			self.m_PlatformObj = createObject(3095,x+5+math.random(width*0.5),y+5+math.random(height*0.5),z+3)
			setElementDimension(self.m_PlatformObj,self.m_Super.m_Dimension)
		end
	end
end

function WareClimb:destructor()
	for key, p in ipairs(self.m_Super.m_Players) do
		if getPedContactElement(p) == self.m_PlatformObj then 
			self.m_Super:addPlayerToWinners( p ) 
		end
	end
	if self.m_PlatformObj then 
		destroyElement(self.m_PlatformObj)
	end
end