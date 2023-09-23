-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Config.lua
-- *  PURPOSE:     Config class
-- *
-- ****************************************************************************
Config = inherit(Singleton)

Config.File = "/server/config/config.ini"
Config.Options = {}
Config.Values = {}

--[[
	type = "string" OR "number" are supported
]]
function Config.register(key, type, defaultValue)
	Config.Options[key] = {type = type, defaultValue = defaultValue}
end

function Config:constructor()
	if fileExists(Config.File) then
		self:load()
	end
end

function Config:load()
	local file = File.Open(Config.File)
	local content = file:getContent()
	file:close()

	local lines
	if getVersion().os == "Windows" then
		lines = split(content, "\r\n")
	else
		lines = split(content, "\n")
	end

	for _, line in ipairs(lines) do
		if line ~= "" then
			local option = split(line, "=")
			Config.Values[option[1]] = option[2]
		end
	end
end

function Config.get(key)
	local option = Config.Options[key]


	if not option then
		outputServerLog(("WARNING: Using unregistered config key '%s'"):format(key))
	end

	if not Config.Values[key] then
		return option.defaultValue
	end

	if option.type == "number" then
		return tonumber(Config.Values[key]) or option.defaultValue
	else -- assume string
		return Config.Values[key]
	end
end
