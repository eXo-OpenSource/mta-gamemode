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
		["Object"] = 3409,
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
		["Illegal"] = true
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
		["Illegal"] = false
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
		["Illegal"] = false
	};
}
GrowableManager.Map = {}

function GrowableManager:constructor()

	self.m_Timer = setTimer(bind(self.grow, self), 10*60*1000, 0)
	self:load()

	addRemoteEvents{"plant:harvest", "plant:getClientCheck"}
	addEventHandler("plant:harvest", root, bind(self.harvest, self))
	addEventHandler("plant:getClientCheck",root, bind(self.getClientCheck, self))

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
		GrowableManager.Map[row.Id] = Growable:new(row.Id, row.Type, GrowableManager.Types[row.Type], Vector3(row.PosX, row.PosY, row.PosZ), row.Owner, row.Size, row.planted, row.last_grown, row.last_watered, row.times_earned)
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

function GrowableManager:getClientCheck(seed, bool, z_pos, isUnderWater)
	if bool then
		--if client:isOnGround() then
			if not client:isInWater() and not isUnderWater then
				if not client.vehicle then
					local plantName = self:getPlantNameFromSeed(seed)
					if plantName then
						local pos = client:getPosition()
						client:giveAchievement(61)
						client:getInventory():removeItem(seed, 1)
						GrowableManager:getSingleton():addNewPlant(plantName, Vector3(pos.x, pos.y, z_pos), client)
					else
						client:sendError(_("Internal Error: Invalid Plant", client))
					end
				else
					client:sendError(_("Du sitzt in einem Fahrzeug!", client))
				end
			else
				client:sendError(_("Du bist im Wasser! Hier kannst du nichts pflanzen!", client))
			end
		--else
		--	client:sendError(_("Du bist nicht am Boden!", client))
		--end
	else
		client:sendError(_("Dies ist kein guter Untergrund zum Anpflanzen! Suche dir ebene Gras- oder Erdflächen", client))
	end
end
