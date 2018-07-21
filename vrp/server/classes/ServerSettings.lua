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
		if row.Index == "ServerPassword" then
			if (row.Value) then
				setServerPassword(row.Value)
			else
				setServerPassword()
			end
		end
		if row.Index == "FPSLimit" then 
			setFPSLimit(tonumber(row.Value) or 60)
		end
	end
end
