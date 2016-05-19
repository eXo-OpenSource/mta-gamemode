-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Item/Growable.lua
-- *  PURPOSE:     Growable class
-- *
-- ****************************************************************************
Growable = inherit(Object)

function Growable:constructor(id, typeData, pos, owner, size, planted, lastGrown, lastWatered)
	self.m_Id = id
	self.m_Object = createObject(typeData["Object"], pos)
	self.m_Object:setCollisionsEnabled(false)
	self.m_Planted = planted
	self.m_Size = size
	self.m_LastGrown = lastGrown
	self.m_LastWatered = lastWatered

	self.ms_GrowPerHour = typeData["GrowPerHour"]
	self.ms_GrowPerHourWatered = typeData["GrowPerHourWatered"]
	self.ms_HoursWatered = typeData["HoursWatered"]
	self.ms_MaxSize = typeData["MaxSize"]
	self.ms_Item = typeData["Item"]
	self.ms_MaxItem = typeData["MaxItem"]
	self.ms_ObjectSizeMin = typeData["ObjectSizeMin"]
	self.ms_ObjectSizeSteps = typeData["ObjectSizeSteps"]

	self:refreshObjectSize()
end

function Growable:checkGrow()
	local ts = getRealTime().timestamp
	local nextGrow = ts+60*60
	if self.m_LastGrown < nextGrow and self.m_Size < self.ms_MaxSize then
		local grow = self.ms_GrowPerHour
		if self.m_LastWatered < self.ms_HoursWatered*60*60 then
			grow = self.ms_GrowPerHourWatered
		end
		self.m_Size = self.m_Size+grow
		self:refreshObjectSize()
	end
end

function Growable:refreshObjectSize()
	self.m_Object:setScale(self.m_Size*self.ms_ObjectSizeSteps)
end

function Growable:save()
	sql:queryExec("UPDATE ??_plants SET Size = ?, last_grown = ?, last_watered = ? WHERE Id = ?", sql:getPrefix(), self.m_Size, self.m_LastGrown, self.m_LastWatered, self.m_Id)
end
