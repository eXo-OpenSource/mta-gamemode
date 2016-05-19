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
		["ObjectSizeSteps"] = 0.1,
		["GrowPerHour"] = 1,
		["GrowPerHourWatered"] = 2,
		["HoursWatered"] = 6,
		["MaxSize"] = 20,
		["Item"] = "Weed",
		["MaxItem"] = 20
	};
}
GrowableManager.Map = {}

function GrowableManager:constructor()
	self.m_Timer = setTimer(bind(self.grow, self), 10*60*1000, 0)
	self:load()
end

function GrowableManager:deconstructor()
	for id, plant in pairs(GrowableManager.Map) do
		plant:save()
	end
end

function GrowableManager:load()
	local result = sql:queryFetch("SELECT * FROM ??_plants", sql:getPrefix())
	for i, row in pairs(result) do
		GrowableManager.Map[row.Id] = Growable:new(row.Id, GrowableManager.Types[row.Type], Vector3(row.PosX, row.PosY, row.PosZ), row.Owner, row.Size, row.planted, row.lastGrown, row.lastWatered)
	end
end

function GrowableManager:grow()
	for id, plant in pairs(GrowableManager.Map) do
		plant:checkGrow()
	end
end

function GrowableManager:addNewPlant(type, position, owner)
	local ts = getRealTime().timestamp
	sql:queryExec("INSERT INTO ??_plants (Type, Owner, PosX, PosY, PosZ, Size, planted, last_grown, last_watered) VALUES (? , ? , ?, ?, ?, ?, ?, ?, ?)",
	sql:getPrefix(), type, owner, position.x, position.y, position.z, 1, ts, ts, 0)
	GrowableManager.Map[sql:lastInsertId()] = Growable:new(GrowableManager.Types[type], position, owner, 1, ts, ts, 0)
end

function GrowableManager:getNextWaterPlant(player)
	for id, plant in pairs(GrowableManager.Map) do
		if getDistanceBetweenPoints3D(player:getPosition(), plant:getObject():getPosition()) <= 5 then
			return plant
		end
	end
	return false
end
