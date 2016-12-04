-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Config.lua
-- *  PURPOSE:     Config class
-- *
-- ****************************************************************************
Config = inherit(Singleton)

function Config:constructor()
  if fileExists('/server/config/config.json') then
  	local config = Config.check('/server/config/config.json.dist', '/server/config/config.json')
	Config.data = config
  else
    error('No config to load. Please add a config at \'/server/config/config.json\'')
  end
end

function Config.get(section)
  if section then
    return Config.data[section]
  else
    return Config.data
  end
end

function Config.load(path)
	local file = fileOpen(path, true)
    local data = fileRead(file, fileGetSize(file))
	local toReturn = fromJSON(data)
	fileClose(file)

	return toReturn
end

function Config.check(distFile, configFile)
	local checkSource = Config.load(distFile)
	local checkTarget = Config.load(configFile)
	-- Run check
	Config.checkInternal(checkSource, checkTarget, "#normal")
	Config.checkInternal(checkTarget, checkSource, "#dist")

	return checkTarget
end

function Config.checkInternal(dist, config, preString)
	for i, v in pairs(dist) do
		if not config[i] then
			error(('Element \'%s\' is missing!'):format(("%s.%s"):format(preString, i)))
		end
		if type(v) ~= type(config[i]) then
			outputDebugString(('Element-Typo of \'%s\' is incorrect! [Expected: %s, got: %s]'):format(("%s.%s"):format(preString, i), type(v), type(config[i])), 2)
		end
		if type(v) == "table" then
			Config.checkInternal(v, config[i], ("%s.%s"):format(preString, i))
		end
	end
	return true;
end
