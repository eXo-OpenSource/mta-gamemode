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
		["ItemPerSize"] = 1
	};
}
GrowableManager.Map = {}

function GrowableManager:constructor()

	self.m_Timer = setTimer(bind(self.grow, self), 10*60*1000, 0)
	self:load()

	addRemoteEvents{"plant:harvest"}
	addEventHandler("plant:harvest", root, bind(self.harvest, self))
end

function GrowableManager:destructor()
	for id, plant in pairs(GrowableManager.Map) do
		plant:save()
	end
end

function GrowableManager:load()
	local result = sql:queryFetch("SELECT * FROM ??_plants", sql:getPrefix())
	for i, row in pairs(result) do
		GrowableManager.Map[row.Id] = Growable:new(row.Id, row.Type, GrowableManager.Types[row.Type], Vector3(row.PosX, row.PosY, row.PosZ), row.Owner, row.Size, row.planted, row.last_grown, row.last_watered)
	end
end

function GrowableManager:grow()
	for id, plant in pairs(GrowableManager.Map) do
		plant:checkGrow()
	end
end

function GrowableManager:harvest(id)
	if id and id > 0 then
		GrowableManager.Map[id]:harvest(client)
	end
end

function GrowableManager:addNewPlant(type, position, owner)
	local ts = getRealTime().timestamp
	sql:queryExec("INSERT INTO ??_plants (Type, Owner, PosX, PosY, PosZ, Size, planted, last_grown, last_watered) VALUES (? , ? , ?, ?, ?, ?, ?, ?, ?)",
	sql:getPrefix(), type, owner:getName(), position.x, position.y, position.z, 0, ts, ts, 0)
	local id = sql:lastInsertId()
	GrowableManager.Map[id] = Growable:new(id, type, GrowableManager.Types[type], position, owner:getName(), 0, ts, ts, 0)
	GrowableManager.Map[id]:onColShapeHit(owner, true)
end

function GrowableManager:getNextPlant(player, range)
	for id, plant in pairs(GrowableManager.Map) do
		if getDistanceBetweenPoints3D(player:getPosition(), plant:getObject():getPosition()) <= range then
			return plant
		end
	end
	return false
end
