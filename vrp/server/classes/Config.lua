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
    local file = fileOpen(':vrp/server/constants/config.json', true)
    local data = fileRead(file, fileGetSize(file))
    Config.data = fromJSON(data)
    fileClose(file)
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
