-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Item/Growable.lua
-- *  PURPOSE:     Growable class
-- *
-- ****************************************************************************
Growable = inherit(Object)

function Growable:constructor(id, type, typeData, pos, owner, size, planted, lastGrown, lastWatered)
	self.m_Id = id
	self.m_Type = type
	self.m_Object = createObject(typeData["Object"], pos)
	self.m_Object:setCollisionsEnabled(false)
	self.m_Planted = planted
	self.m_Size = size
	self.m_LastGrown = lastGrown
	self.m_LastWatered = lastWatered
	self.m_Owner = owner

	self.ms_GrowPerHour = typeData["GrowPerHour"]
	self.ms_GrowPerHourWatered = typeData["GrowPerHourWatered"]
	self.ms_HoursWatered = typeData["HoursWatered"]
	self.ms_MaxSize = typeData["MaxSize"]
	self.ms_Item = typeData["Item"]
	self.ms_MaxItem = typeData["MaxItem"]
	self.ms_ObjectSizeMin = typeData["ObjectSizeMin"]
	self.ms_ObjectSizeSteps = typeData["ObjectSizeSteps"]

	self.m_Colshape = createColSphere(pos.x, pos.y, pos.z+1, 1)
	addEventHandler("onColShapeHit", self.m_Colshape, bind(self.onColShapeHit, self))
	addEventHandler("onColShapeLeave", self.m_Colshape, bind(self.onColShapeLeave, self))

	self:refreshObjectSize()
end

function Growable:checkGrow()
	local ts = getRealTime().timestamp
	local nextGrow = self.m_LastGrown+60*60
	if self.m_Size < self.ms_MaxSize then
		if ts > nextGrow then
			local grow = self.ms_GrowPerHour
			if self.m_LastWatered > ts+self.ms_HoursWatered*60*60 then
				grow = self.ms_GrowPerHourWatered
			else
				self.m_Object:setData("Plant:Hydration", false, true)
			end
			self.m_Size = self.m_Size+grow
			if self.m_Size > self.ms_MaxSize then self.m_Size = self.ms_MaxSize end
			self.m_LastGrown = ts
			self:refreshObjectSize()
		end
	end
end

function Growable:refreshObjectSize()
	self.m_Object:setScale(self.m_Size*self.ms_ObjectSizeSteps)
end

function Growable:getObject()
	return self.m_Object
end

function Growable:waterPlant(player)
	self.m_LastWatered = getRealTime().timestamp
	player:setAnimation("bomber", "BOM_Plant_Loop", 2000, true, false)
	player:triggerEvent("PlantWeed:onWaterPlant", self:getObject())
	self:getObject():setData("Plant:Hydration", true, true)
end

function Growable:save()
	local result = sql:queryExec("UPDATE ??_plants SET Size = ?, last_grown = ?, last_watered = ? WHERE Id = ?", sql:getPrefix(), self.m_Size, self.m_LastGrown, self.m_LastWatered, self.m_Id)
	if not result then outputDebug("Plant ID "..self.m_Id.." not saved!") end
end

function Growable:onColShapeHit(hit, dim)
	if hit:getType() == "player" and dim then
		hit:triggerEvent("showPlantGUI", self.m_Type, self.m_LastGrown, self.m_Size, self.ms_MaxSize, self.m_Items, self.m_Owner, self.m_LastWatered, self.ms_HoursWatered)
	end
end

function Growable:onColShapeLeave(leave, dim)
	if leave:getType() == "player" and dim then
		leave:triggerEvent("hidePlantGUI")
	end
end
