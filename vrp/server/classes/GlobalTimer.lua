-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/GlobalTimer.lua
-- *  PURPOSE:     Global Timer class
-- *
-- ****************************************************************************
GlobalTimer = inherit(Singleton)

function GlobalTimer:constructor()
	self.m_Events = {}
end

function GlobalTimer:execute()
	local currentTime = getRealTime()
	local weekday = currentTime.weekday
	local hour = currentTime.hour
	local minute = currentTime.minute
	for id, eventData in pairs(self.m_Events) do

	end
end

function GlobalTimer:registerEvent(callback, name, weekday, hour, minute)
	local id = #self.m_Events+1
	self.m_Events[id] = {
		["name"] = name,
		["callback"] = callback,
		["weekday"] = callback,
		["hour"] = callback,
		["minute"] = callback,
		["done"] = false,
	}
end
