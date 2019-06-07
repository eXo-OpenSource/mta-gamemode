-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Item/Growable.lua
-- *  PURPOSE:     Growable class
-- *
-- ****************************************************************************
Growable = inherit(Object)

function Growable:constructor(id, type, typeData, pos, ownerId, size, planted, lastGrown, lastWatered, timesEarned)
	self.m_Id = id
	self.m_Type = type
	self.m_Object = createObject(typeData["Object"], pos, 0, 0, math.random(0,360))
	self.m_Object:setCollisionsEnabled(false)
	self.m_Planted = planted
	self.m_Size = size
	self.m_LastGrown = lastGrown
	self.m_LastWatered = lastWatered
	self.m_OwnerId = ownerId
	self.m_TimesEarned = timesEarned or 0

	self.ms_GrowPerHour = typeData["GrowPerHour"]
	self.ms_GrowPerHourWatered = typeData["GrowPerHourWatered"]
	self.ms_HoursWatered = typeData["HoursWatered"]
	self.ms_MaxSize = typeData["MaxSize"]
	self.ms_Item = typeData["Item"]
	self.ms_ItemPerSize = typeData["ItemPerSize"]
	self.ms_ObjectSizeMin = typeData["ObjectSizeMin"]
	self.ms_ObjectSizeSteps = typeData["ObjectSizeSteps"]
	self.ms_TimesEarnedForDestroy = typeData["TimesEarnedForDestroy"]
	self.ms_Illegal = typeData["Illegal"]
	self.m_BankAccountServer = BankServer.get("faction.state")

	--self.m_Colshape = createColSphere(pos.x, pos.y, pos.z+1, 1)
	--addEventHandler("onColShapeHit", self.m_Colshape, bind(self.onColShapeHit, self))
	--addEventHandler("onColShapeLeave", self.m_Colshape, bind(self.onColShapeLeave, self))

	self:refreshObjectSize()
end

function Growable:destructor()
	GrowableManager:getSingleton():removePlant(self.m_Id)
	if isElement(self.m_Colshape) then self.m_Colshape:destroy() end
	if isElement(self.m_Object) then self.m_Object:destroy() end
end


function Growable:checkGrow(force)
	local ts = getRealTime().timestamp
	local nextGrow = self.m_LastGrown+60*60
	if self.m_Size < self.ms_MaxSize then
		if ts > nextGrow or force then
			local grow = self.ms_GrowPerHour
			local watered = ""
			if self.m_LastWatered + self.ms_HoursWatered*60*60 - ts > 0 then
				grow = self.ms_GrowPerHourWatered
				watered = "(watered)"
			else
				self.m_Object:setData("Plant:Hydration", false, true)
				watered = "(not watered)"
			end
			if force then outputDebugString(("Grow Plant %s +%d %s"):format(self.m_Type, grow, watered)) end
			self.m_Size = self.m_Size + grow
			if self.m_Size > self.ms_MaxSize then self.m_Size = self.ms_MaxSize end
			self.m_LastGrown = ts
			self:refreshObjectSize()
		end
	end
end

function Growable:refreshObjectSize()
	self.m_Object:setScale(self.ms_ObjectSizeMin+self.m_Size*self.ms_ObjectSizeSteps)
end

function Growable:getObject()
	return self.m_Object
end

function Growable:harvest(player)
	if not player.vehicle then
	--if player:getId() == self.m_OwnerId or (player:getFaction() and player:getFaction():isStateFaction() and player:isFactionDuty()) then

		local amount = self.m_Size*self.ms_ItemPerSize

		if self.ms_Item == "Blumen" then
			if amount >= 1 then
				if player:getWeapon(10) ~= 14 then
					player:triggerEvent("hidePlantGUI")
					player:sendInfo(_("Du hast einen Blumenstrauß geerntet!", player))
					giveWeapon(player, 14, 1, true)
					sql:queryExec("DELETE FROM ??_plants WHERE Id = ?", sql:getPrefix(), self.m_Id)
					triggerClientEvent("ColshapeStreamer:deleteColshape", player, "growable", self.m_Id)
					delete(self)
				else
					player:sendError(_("Du hast bereits einen Blumenstrauß dabei!", player))
				end
			else
				player:sendError(_("Die Blumen sind noch nicht ausreichend gewachsen!", player))
			end
			return
		end

		if self.ms_Illegal and player:getFaction() and player:getFaction():isStateFaction() and player:isFactionDuty() then
			if amount > 0 then
				StateEvidence:getSingleton():addItemToEvidence(player, self.ms_Item, amount)
			end
			player:triggerEvent("hidePlantGUI")
			self.m_Size = 0
			sql:queryExec("DELETE FROM ??_plants WHERE Id = ?", sql:getPrefix(), self.m_Id)
			triggerClientEvent("ColshapeStreamer:deleteColshape", player, "growable", self.m_Id)
			StatisticsLogger:getSingleton():addDrugHarvestLog(player, self.m_Type, self.m_OwnerId, amount, 1)
			delete(self)
		elseif amount > 0 then
			if player:getInventory():getFreePlacesForItem(self.ms_Item) >= amount then
				player:sendInfo(_("Du hast %d %s geerntet!", player, amount, self.ms_Item))
				player:getInventory():giveItem(self.ms_Item, amount)
				player:triggerEvent("hidePlantGUI")
				self.m_Size = 0
				self.m_TimesEarned = self.m_TimesEarned + 1
				self:refreshObjectSize()
				StatisticsLogger:getSingleton():addDrugHarvestLog(player, self.m_Type, self.m_OwnerId, amount, 0)
				if self.m_TimesEarned >= self.ms_TimesEarnedForDestroy  then
					sql:queryExec("DELETE FROM ??_plants WHERE Id = ?", sql:getPrefix(), self.m_Id)
					triggerClientEvent("ColshapeStreamer:deleteColshape", player, "growable", self.m_Id)
					delete(self)
				end
				player:setData("Plant:Current", false)
			else
				player:sendError(_("Du hast in deinem Inventar nicht Platz für %d %s!", player, amount, self.ms_Item))
			end
		else
			player:sendError(_("Die Pflanze ist noch nicht gewachsen!", player))
		end
	--else
	--	player:sendError(_("Die Pflanze gehört nicht dir!", player))
	--end
	else
		player:sendError(_("Du sitzt in einem Fahrzeug!", player))
	end
end

function Growable:waterPlant(player)
	if not player.vehicle then
		self.m_LastWatered = getRealTime().timestamp
		player:setAnimation("bomber", "BOM_Plant_Loop", 2000, true, false)
		setTimer(function()
			player:setAnimation("carry", "crry_prtial", 1, false, true, true, false) -- Stop Animation Work Arround
		end, 2000 ,1)
		player:triggerEvent("Plant:onWaterPlant", self:getObject())
		self:getObject():setData("Plant:Hydration", true, true)
		self:onColShapeLeave(player, true)
		self:onColShapeHit(player, true)
	else
		player:sendError(_("Du sitzt in einem Fahrzeug!", player))
	end
end

function Growable:save()
	local result = sql:queryExec("UPDATE ??_plants SET Size = ?, last_grown = ?, last_watered = ?, times_earned = ? WHERE Id = ?", sql:getPrefix(), self.m_Size, self.m_LastGrown, self.m_LastWatered, self.m_TimesEarned, self.m_Id)
	if not result then outputDebug("Plant ID "..self.m_Id.." not saved!") end
end

function Growable:onColShapeHit(hit, dim)
	if hit:getType() == "player" and dim then
		hit:setData("Plant:Current", self)
		hit:triggerEvent("showPlantGUI", self.m_Id, self.m_Type, self.m_LastGrown, self.m_Size, self.ms_MaxSize, self.ms_Item, self.ms_ItemPerSize, self.m_Owner, self.m_LastWatered, self.ms_HoursWatered)
	end
end

function Growable:onColShapeLeave(leave, dim)
	if leave:getType() == "player" and dim then
		leave:setData("Plant:Current", false)
		leave:triggerEvent("hidePlantGUI")
	end
end
