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
	self.m_Maps = {}
	
	fetchRemote(RaceManager.RES_PATH .. "list.php", bind(RaceManager.fetchMaps, self))

	self:registerMode(RaceDD)
	self:registerMode(RaceDM)
end

function RaceManager:fetchMaps(data, errno)
	if errno ~= 0 then outputDebug("An error occurred while receiving maps") return end

	local mapData = fromJSON(data)

	if mapData then
		for mode, maps in pairs(mapData) do
			if not self.m_Maps[mode] then self.m_Maps[mode] = {} end
			
			for mapname, path in pairs(maps) do
				table.insert(self.m_Maps, {name = mapname, path = path})
			end
		end
	end
end

function RaceManager:registerMode(mode)
	assert(type(mode) == "table", "Invalid mode @ RaceManager:registerMode")
	table.insert(self.m_RegisteredModes, mode)
end

function RaceManager:getRandomMap(mode)
	if self.m_Maps[mode] then
		return self.m_Maps[mode][math.random(1, #self.m_Maps[mode])]
	end
end

function RaceManager:loadMap(map)
	-- Todo: Check if the map was already loaded before and probably skip fetching meta.xml
	
	-- Fetch meta.xml
	Async.create(function() fetchRemote(("%s%s/meta.xml"):format(RaceManager.RES_PATH, map.path), {username = "maps", password = "RT6QSAaw"}, Async.waitFor(self)) end)()
	local data, errno = Async.wait()
	
	if errno ~= 0 or not data then return false end
	
	-- Write meta.xml
	local file = fileCreate(("temp/maps/%s/meta.xml"):format(map.name))
	file:write(data)
	file:close()
	
	-- Load meta.xml
	local xml = xmlLoadFile(("temp/maps/%s/meta.xml"):format(map.name))
	local infoNode = xml:findChild("info", 0)
	local mapInfo = infoNode:getAttributes()
	
	local mapNode = xml:findChild("map", 0)
	local mapSrc = mapNode:getAttribute("src")
	
	local mapScripts = {}
	local i = 0
	while true do
		local scriptNode = xml:findChild("script", i)
		if scriptNode then
			table.insert(mapScripts, {src = scriptNode:getAttribute("src"), type = scriptNode:getAttribute("type") or "server"})
			i = i + 1
		else
			break
		end
	end
	
	local mapFiles = {}
	local i = 0
	while true do
		local fileNode = xml:findChild("file", i)
		if fileNode then
			table.insert(mapFiles, fileNode:getAttribute("src"))
			i = i + 1
		else
			break
		end
	end
	
	local settingsNode = xml:findChild("settings", 0)	
	local mapSettings = {}
	for _, setting in pairs(settingsNode:getChildren()) do
		mapSettings[setting:getAttribute("name")] = setting:getAttribute("value")
	end
	
	xml:unload()
	
	-- Todo: Validate Map infos..
	
	map.info = mapInfo
	map.mapSrc = mapSrc
	map.scripts = mapScripts
	map.files = mapFiles
	map.settings = mapSettings
	
	return map
end