-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/InfluxDB.lua
-- *  PURPOSE:     InfluxDB class
-- *
-- ****************************************************************************
InfluxDB = inherit(Singleton)

function InfluxDB:constructor()
    self.m_Username = "exo"
    self.m_Password = "Ly2Eq8-.XnfVKiu2K*t.zHgQ788pe6_h" -- well
    self.m_Database = "exo"
    self.m_Host = "https://influxdb.merx.dev"
end

function InfluxDB:write(measurement, value, tags)
	outputChatBox(measurement)
    if not DEBUG then
        local timestamp = getRealTime().timestamp.."000000000"
        local tagsData = ""

        if tags then
			for k, v in pairs(tags) do
				local v = v or "-"
                tagsData = tagsData .. "," .. tostring(k) .. "=" .. tostring(v):gsub(",", ";")
            end
        end

        fetchRemote(self.m_Host .. "/write?db=" .. self.m_Database, {
            ["method"] = "POST",
            ["username"] = self.m_Username,
			["password"] = self.m_Password,
            ["postData"] = measurement .. ",host=merx.dev,region=eu1" .. tagsData .. " value=" .. value .. " " .. timestamp
		}, function(result)
			outputServerLog(tostring(result))
		end)
    end
end
