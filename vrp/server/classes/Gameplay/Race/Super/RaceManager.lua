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

	self:registerMode(RaceDD, "DD")
	self:registerMode(RaceDM, "DM")

	addEventHandler("onVehicleStartExit", root, bind(RaceManager.onVehicleStartExit, self))
end

function RaceManager:fetchMaps(data, errno)
	if errno ~= 0 then outputDebug("An error occurred while receiving maps") return end

	local mapData = fromJSON(data)

	if mapData then
		for mode, maps in pairs(mapData) do
			if not self.m_Maps[mode] then self.m_Maps[mode] = {} end

			for mapname, path in pairs(maps) do
				table.insert(self.m_Maps[mode], {name = mapname, path = path})
			end
		end
	end
end

function RaceManager:onVehicleStartExit(player)
	if self:isPlayerInMode(player) then
		outputChatBox("onVehicleStartExit : cancelEvent")
		cancelEvent()
	end
end

---
-- Modes
--
function RaceManager:registerMode(mode, name)
	assert(type(mode) == "table", "Invalid mode @ RaceManager:registerMode")
	self.m_RegisteredModes[name] = mode:new()
end

function RaceManager:getMode(name)
	return self.m_RegisteredModes[name]
end

function RaceManager:isPlayerInMode(player)
	for _, mode in pairs(self.m_RegisteredModes) do
		if mode:isPlayer(player) then
			return true
		end
	end

	return false
end

---
-- Maps
--
function RaceManager:getRandomMap(mode)
	if self.m_Maps[mode] then
		return self.m_Maps[mode][math.random(1, #self.m_Maps[mode])]
	end
end

function RaceManager:createMap(map)
	Async.create(
		function()
			local st = getTickCount()

			if not fileExists(("files/maps/temporary/%s/meta.xml"):format(map.name)) then
				-- Fetch meta.xml
				local responseData, responseInfo = self:fetchAsync(("%s%s/meta.xml"):format(RaceManager.RES_PATH, map.path))
				if not responseInfo.success then outputDebug("Error while fetching map meta.") return false end

				-- Write meta.xml
				local file = fileCreate(("files/maps/temporary/%s/meta.xml"):format(map.name))
				file:write(responseData)
				file:close()
			end

			-- Load meta.xml
			local xml = xmlLoadFile(("files/maps/temporary/%s/meta.xml"):format(map.name))
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

			if not fileExists(("files/maps/temporary/%s/%s"):format(map.name, map.mapSrc)) then
				-- Create map file
				local responseData, responseInfo = self:fetchAsync(("%s%s/%s"):format(RaceManager.RES_PATH, map.path, map.mapSrc))
				if not responseInfo.success then outputDebug("Error while fetching map file: " .. tostring(responseInfo.statusCode)) return false end

				local file = fileCreate(("files/maps/temporary/%s/%s"):format(map.name, map.mapSrc))
				file:write(responseData)
				file:close()
			end

			for _, value in pairs(map.scripts) do
				if not fileExists(("files/maps/temporary/%s/%s"):format(map.name, value.src)) then
					local responseData, responseInfo = self:fetchAsync(("%s%s/%s"):format(RaceManager.RES_PATH, map.path, value.src))
					if responseInfo.success then
						local file = fileCreate(("files/maps/temporary/%s/%s"):format(map.name, value.src))
						file:write(responseData)
						file:close()
					else
						outputDebug("Error while fetching script file '%': " .. tostring(value.src, responseInfo.statusCode))
					end
				end
			end

			for _, value in pairs(map.files) do
				if not fileExists(("files/maps/temporary/%s/%s"):format(map.name, value)) then
					local responseData, responseInfo = self:fetchAsync(("%s%s/%s"):format(RaceManager.RES_PATH, map.path, value))
					if responseInfo.success then
						local file = fileCreate(("files/maps/temporary/%s/%s"):format(map.name, value))
						file:write(responseData)
						file:close()
					else
						outputDebug("Error while fetching map asset '%': " .. tostring(value, responseInfo.statusCode))
					end
				end
			end

			map.created = true
			outputChatBox("Created Map in " .. getTickCount() - st)
		end
	)()
end

function RaceManager:loadMap(map, dimension)
	if not map.created then
		outputChatBox("Create Map")
		self:createMap(map)
	end

	map.instance = MapParser:new(("files/maps/temporary/%s/%s"):format(map.name, map.mapSrc))
	if map.instance then
	--	map.instance:create(dimension)
		return map
	end
end

function RaceManager:fetch(callback, file)
	return fetchRemote(file, {username = "maps", password = "RT6QSAaw"},
		function(responseData, errno)
			callback(responseData, errno)
		end
	)
end

function RaceManager:fetchAsync(...)
	self:fetch(Async.waitFor(), ...)
	return Async.wait()
end
