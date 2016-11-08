-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Config.lua
-- *  PURPOSE:     Config class
-- *
-- ****************************************************************************
Config = inherit(Singleton)

function Config:constructor()
  if fileExists(':vrp/server/constants/config.json') then
  	local config = Config.check(':vrp/server/constants/config.json.dist', ':vrp/server/constants/config.json')
	Config.data = config
  else
    error('No config to load. Please add a config at \':vrp/server/constants/config.json\'')
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
			preString = ("%s.%s"):format(preString, i)
			error(('Element \'%s\' is missing!'):format(preString))
		end
		if type(v) ~= type(config[i]) then
			preString = ("%s.%s"):format(preString, i)
			outputDebugString(('Element-Typo of \'%s\' is incorrect! [Expected: %s, got: %s]'):format(preString, type(v), type(config[i])), 2)
		end
		if type(v) == "table" then
			preString = ("%s.%s"):format(preString, i)
			if Config.checkInternal(v, config[i], preString) then
				preString = preString:gsub((".%s"):format(i), "")
			end
		end
	end
	return true;
end
