-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/ServerSettings.lua
-- *  PURPOSE:     ServerSettings from Database
-- *
-- ****************************************************************************
ServerSettings = inherit(Singleton)

function ServerSettings:constructor()
	local result = sql:queryFetch("SELECT * FROM ??_settings", sql:getPrefix())
	for index, row in pairs(result) do
		if row.Index == "ServerPassword" and row.Value then
			setServerPassword(row.Value)
		end
	end
end
