-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Item/GrowableManager.lua
-- *  PURPOSE:     Growable Item manager class
-- *
-- ****************************************************************************
GrowableManager = inherit(Singleton)
GrowableManager.Types = {
	["Weed"] = {
		["Object"] = 1870,
		["ObjectSizeMin"] = 0.1,
		["ObjectSizeSteps"] = 0.05,
		["GrowPerHour"] = 1,
		["GrowPerHourWatered"] = 2,
		["HoursWatered"] = 6,
		["MaxSize"] = 20,
		["Item"] = "Weed",
		["Seed"] = "Weed-Samen",
		["ItemPerSize"] = 1,
		["TimesEarnedForDestroy"] = 1,
		["Illegal"] = true,
		["SizeBetweenPlants"] = 2
	};
	["Apfelbaum"] = {
		["Object"] = 892,
		["ObjectSizeMin"] = 0.1,
		["ObjectSizeSteps"] = 0.05,
		["GrowPerHour"] = 1,
		["GrowPerHourWatered"] = 2,
		["HoursWatered"] = 3,
		["MaxSize"] = 20,
		["Item"] = "Apfel",
		["Seed"] = "Apfelbaum-Samen",
		["ItemPerSize"] = 1,
		["TimesEarnedForDestroy"] = 3,
		["Illegal"] = false,
		["SizeBetweenPlants"] = 3
	};
	["Blumen"] = {
		["Object"] = 325,
		["ObjectSizeMin"] = 0.4,
		["ObjectSizeSteps"] = 0.1,
		["GrowPerHour"] = 2,
		["GrowPerHourWatered"] = 4,
		["HoursWatered"] = 4,
		["MaxSize"] = 10,
		["Item"] = "Blumen",
		["Seed"] = "Blumen-Samen",
		["ItemPerSize"] = 0.1,
		["TimesEarnedForDestroy"] = 1,
		["Illegal"] = false,
		["SizeBetweenPlants"] = 2
	};
}
GrowableManager.Map = {}

function GrowableManager:constructor()

	self.m_Timer = setTimer(bind(self.grow, self), 10*60*1000, 0)
	self:load()

	addRemoteEvents{"plant:harvest", "plant:getClientCheck", "plant:onClientColShapeHit", "plant:onClientColShapeLeave"}
	addEventHandler("plant:harvest", root, bind(self.harvest, self))
	addEventHandler("plant:getClientCheck",root, bind(self.getClientCheck, self))
	addEventHandler("plant:onClientColShapeHit", root, bind(self.onClientColShapeHit, self))
	addEventHandler("plant:onClientColShapeLeave", root, bind(self.onClientColShapeLeave, self))

	--DEBUG
	addCommandHandler("growPlants", function(player)
		if player:getRank() >= RANK.Developer then
			self:grow(true)
			player:sendShortMessage("DEBUG: Alle Pflanzen wachsen nun!")
		end
	end)
end

function GrowableManager:destructor()
	for id, plant in pairs(GrowableManager.Map) do
		plant:save()
	end
end

function GrowableManager:load()
	local result = sql:queryFetch("SELECT * FROM ??_plants", sql:getPrefix())
	for i, row in pairs(result) do
		if getRealTime().timestamp - row.planted < 604800 then
			GrowableManager.Map[row.Id] = Growable:new(row.Id, row.Type, GrowableManager.Types[row.Type], Vector3(row.PosX, row.PosY, row.PosZ), row.Owner, row.Size, row.planted, row.last_grown, row.last_watered, row.times_earned)
		else
			sql:queryExec("DELETE FROM ??_plants WHERE Id = ?", sql:getPrefix(), row.Id)
		end
	end
end

function GrowableManager:removePlant(id)
	GrowableManager.Map[id] = nil
end

function GrowableManager:grow(force)
	for id, plant in pairs(GrowableManager.Map) do
		plant:checkGrow(force)
	end
end

function GrowableManager:harvest(id)
	if id and id > 0 then
		if GrowableManager.Map[id] then
			GrowableManager.Map[id]:harvest(client)
		else
		--	client:sendError(_("Harvest Error! Plant not found! (%d)", client, id))
		end
	end
end

function GrowableManager:addNewPlant(type, position, owner)
	local ts = getRealTime().timestamp
	sql:queryExec("INSERT INTO ??_plants (Type, Owner, PosX, PosY, PosZ, Size, planted, last_grown, last_watered, times_earned) VALUES (? , ? , ?, ?, ?, ?, ?, ?, ?, ?)",
	sql:getPrefix(), type, owner:getId(), position.x, position.y, position.z, 0, ts, ts, 0, 0)
	StatisticsLogger:getSingleton():addPlantLog(owner, type)
	local id = sql:lastInsertId()
	GrowableManager.Map[id] = Growable:new(id, type, GrowableManager.Types[type], position, owner:getId(), 0, ts, ts, 0, 0)
	for key, player in ipairs(getElementsByType("player")) do
		if player:isLoggedIn() then
			player:triggerEvent("ColshapeStreamer:registerColshape", {position.x, position.y, position.z+1}, GrowableManager.Map[id].m_Object, "growable", GrowableManager.Map[id].m_Id, 1, "plant:onClientColShapeHit", "plant:onClientColShapeLeave")
		end
	end
	GrowableManager.Map[id]:onColShapeHit(owner, true)
end

function GrowableManager:getNextPlant(player, range)
	for id, plant in pairs(GrowableManager.Map) do
		if plant and isElement(plant:getObject()) then
			if getDistanceBetweenPoints3D(player:getPosition(), plant:getObject():getPosition()) <= range then
				return plant
			end
		end
	end
	return false
end

function GrowableManager:getPlantNameFromSeed(seed)
	for index, data in pairs(GrowableManager.Types) do
		if data["Seed"] == seed then
			return index
		end
	end
	return false
end

function GrowableManager:checkPlantConditionsForPlayer(player, seed)
	local plantName = GrowableManager:getSingleton():getPlantNameFromSeed(seed)
	if not plantName then player:sendError(_("Internal Error: Invalid Plant", player)) return false end
	if player:isInWater() then player:sendError(_("Du bist im Wasser! Hier kannst du nichts pflanzen!", player)) return false end
	if player.vehicle then player:sendError(_("Du sitzt in einem Fahrzeug!", player)) return false end
	if GrowableManager:getSingleton():getNextPlant(player, GrowableManager.Types[plantName].SizeBetweenPlants) then player:sendError(_("Du bist zu nah an einer anderen Pflanze!", player)) return false end
	return true
end

function GrowableManager:getClientCheck(seed, bool, z_pos, isUnderWater)
	if not bool or isUnderWater then client:sendError(_("Dies ist kein guter Untergrund zum Anpflanzen! Suche dir ebene Gras- oder Erdflächen", client)) return false end
	if not self:checkPlantConditionsForPlayer(client, seed) then return false end
	
	local pos = client:getPosition()
	client:giveAchievement(61)
	client:getInventory():removeItem(seed, 1)
	GrowableManager:getSingleton():addNewPlant(GrowableManager:getSingleton():getPlantNameFromSeed(seed), Vector3(pos.x, pos.y, z_pos), client)
end

function GrowableManager:sendGrowablesToClient(player)
	if not player then player = root end
	for key, growable in pairs(GrowableManager.Map) do
		local x, y, z = getElementPosition(growable.m_Object)
		triggerClientEvent(player, "ColshapeStreamer:registerColshape", player, {x, y, z+1}, growable.m_Object, "growable", growable.m_Id, 1, "plant:onClientColShapeHit", "plant:onClientColShapeLeave")
	end
end

function GrowableManager:onClientColShapeHit(id)
	GrowableManager.Map[id]:onColShapeHit(client, true)
end

function GrowableManager:onClientColShapeLeave(id)
	if GrowableManager.Map[id] then
		GrowableManager.Map[id]:onColShapeLeave(client, true)
	end
end