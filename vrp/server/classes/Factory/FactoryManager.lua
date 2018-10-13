-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Factory/FactoryManager.lua
-- *  PURPOSE:     FactoryManager class
-- *
-- ****************************************************************************

FactoryManager = inherit(Singleton)
FactoryManager.Map = {}

function FactoryManager:constructor()
	local st, count = getTickCount(), 0

	local query = sql:queryFetch("SELECT * FROM ??_factory", sql:getPrefix())

	for key, value in pairs(query) do
		FactoryManager.Map[value["Id"]] = Factory:new(value["Id"], Vector3(value["PosX"], value["PosY"], value["PosZ"]))
		count = count + 1
	end

	if DEBUG_LOAD_SAVE then outputServerLog(("Created %s factories in %sms"):format(count, getTickCount()-st)) end
end
