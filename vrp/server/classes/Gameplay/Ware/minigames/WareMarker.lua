-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Ware/minigames/WareMarker.lua
-- *  PURPOSE:     WareMarker class
-- *
-- ****************************************************************************
WareMarker = inherit(Object)
WareMarker.modeDesc = "Bleib im Marker!"
WareMarker.timeScale = 1

function WareMarker:constructor( super )
	self.m_Super = super
	self.m_Super.m_Successors = {}
	local pos = self.m_Super:getRandomPosition()
	pos.z = pos.z+0.5

	self.m_DummyObject = createObject(1337, pos)
	self.m_DummyObject:setCollisionsEnabled(false)
	self.m_DummyObject:setDimension(self.m_Super.m_Dimension)
	self.m_DummyObject:setAlpha(0)

	self.m_Marker = createMarker(pos, "cylinder", 4, 0, 255, 0, 125)
	self.m_Marker:setDimension(self.m_Super.m_Dimension)
	self.m_Marker:attach(self.m_DummyObject)

	self.m_MoveBind = bind(self.moveMarker, self)
	self:moveMarker()
end

function WareMarker:moveMarker()
	local pos = self.m_Super:getRandomPosition()
	pos.z = pos.z+1
	local time = math.random(4000, 10000)
	self.m_DummyObject:move(time, pos)
	self.m_Timer = setTimer(self.m_MoveBind, time+10, 1)
end

function WareMarker:destructor()
	for key, p in pairs(self.m_Super.m_Players) do
		if p:isWithinMarker(self.m_Marker) then
			self.m_Super:addPlayerToWinners(p)
		end
	end
	self.m_Marker:destroy()
	self.m_DummyObject:destroy()
	if isTimer(self.m_Timer) then killTimer(self.m_Timer) end
end
