-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/SprayWallManager.lua
-- *  PURPOSE:     SprayWall manager class
-- *
-- ****************************************************************************
SprayWallManager = inherit(Singleton)
local RESOURCES_DISTRIBUTE_INTERVAL = 60*60*1000

function SprayWallManager:constructor()
	local st, count = getTickCount(), 0
	self.m_Map = {}

	if DEBUG_LOAD_SAVE then outputServerLog("Loading SprayWalls...") end
	for i, info in ipairs(SprayWallData) do
		self.m_Map[i] = SprayWall:new(i, info.wallPosition, info.resources or 50)
		count = count + 1
	end

	addRemoteEvents{"sprayWallTagSprayed"}
	addEventHandler("sprayWallTagSprayed", root, bind(self.Event_SprayWallTagSprayed, self))

	-- Start the timer that produces and distributes the resources
	if DEBUG_LOAD_SAVE then outputServerLog(("Created %s spayWalls in %sms"):format(count, getTickCount()-st)) end
	setTimer(bind(self.distributeResources, self), RESOURCES_DISTRIBUTE_INTERVAL, 0)
end

function SprayWallManager:destructor()
	for k, SprayWall in pairs(self.m_Map) do
		delete(SprayWall)
	end
end

function SprayWallManager:distributeResources()
	for k, SprayWall in pairs(self.m_Map) do
		SprayWall:distributeResources()
	end
end

function SprayWallManager:Event_SprayWallTagSprayed(Id)
	local SprayWall = self.m_Map[Id]
	if SprayWall then
		local clientGroup = client:getGroup()
		local ownerGroup = SprayWall:getOwnerGroup()
		if not clientGroup then
			return
		end

		if clientGroup ~= ownerGroup then
			--if SprayWall:canBeSprayed() then
				SprayWall:setOwner(client, clientGroup)
				client:sendInfo(_("Du hast die Wand erfolgreich übersprüht!", client))

			--else

			--end
		else
			client:sendInfo(_("Diese Wand wurde bereits von deiner Gang übersprüht!", client))
		end
	end
end
