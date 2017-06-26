-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
RaceManager = inherit(Singleton)
RaceManager.RES_PATH = "http://pewx.de/res/maps/"

function RaceManager:constructor()
	self.m_RegisteredModes = {}

	fetchRemote(RaceManager.RES_PATH .. "list.php", bind(RaceManager.loadMaps, self))

	self:registerMode(RaceDD)
	self:registerMode(RaceDM)
end

function RaceManager:loadMaps(data, errno)
	if errno ~= 0 then outputDebug("An error occurred while receiving maps") return end

	self.m_Maps = fromJSON(data)

	for map, path in pairs(self.m_Maps["dd"]) do
		outputConsole(("%s // Path: %s"):format(map, path))

		fetchRemote(RaceManager.RES_PATH .. path .. "/meta.xml", {username = "maps", password = "RT6QSAaw"}, function(data, errno) outputConsole(data) end)
	end
end

function RaceManager:registerMode(mode)
	assert(type(mode) == "table", "Invalid mode @ RaceManager:registerMode")
	table.insert(self.m_RegisteredModes, mode)
end
