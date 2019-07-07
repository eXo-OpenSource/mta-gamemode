-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/InfluxDB.lua
-- *  PURPOSE:     InfluxDB class
-- *
-- ****************************************************************************
InfluxLogging = inherit(Singleton)

function InfluxLogging:constructor()
	self.m_TimedPulse = TimedPulse:new(30 * 1000)
	self.m_TimedPulse:registerHandler(bind(self.writePerformance, self))
end

function InfluxLogging:destructor()
	delete(self.m_TimedPulse)
end

function InfluxLogging:writePerformance()
	local _, rows = getPerformanceStats("Lua timing", "d")
	local resource = "unknown"
    for _, v in pairs(rows) do
        if v[1] then
            if v[2] ~= "-" then
                local name = v[1] or "unknown"
                local time = v[3] or 0
				local calls = v[4] or 0

				if name:sub(0, 1) ~= "." then
					resource = name
				else
					if name ~= "unknown" then name = name:sub(#name * -1 + 1) end
					influx:write("performance", {["serial"] = localPlayer:getSerial(), ["name"] = name, ["resource"] = resource}, {["cpuTime"] = time, ["calls"] = calls, ["cpuUsage"] = tonumber(v[2]:sub(0, -2))})
				end
            end
        end
	end

	local data = {
		["fps"] = localPlayer.FPS.frames,
		["vram"] = dxGetStatus()["VideoMemoryFreeForMTA"],
		["posX"] = localPlayer.position.x,
		["posY"] = localPlayer.position.y,
		["posZ"] = localPlayer.position.z,
		["ping"] = localPlayer.ping,
		["packetloss"] = getNetworkStats().packetlossLastSecond,
	}

	for k, v in pairs({"player", "ped", "vehicle", "object", "pickup", "marker", "colshape", "texture", "shader"}) do
		data[v .. "Total"] = #getElementsByType(v)
		data[v .. "Streamed"] = #getElementsByType(v, root, true)
	end

	influx:write("client", {["serial"] = localPlayer:getSerial(), ["name"] = localPlayer:getName()}, data)
end
