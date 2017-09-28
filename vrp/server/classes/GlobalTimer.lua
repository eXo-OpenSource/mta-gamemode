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
	self.m_Timer = setTimer(bind(self.execute, self), 50000, 0)
end

function GlobalTimer:execute()
	local currentTime = getRealTime()
	local weekday = currentTime.weekday
	local hour = currentTime.hour
	local minute = currentTime.minute
	for id, eventData in pairs(self.m_Events) do
		if eventData["active"] then
			if not eventData["weekday"] or eventData["weekday"] == weekday then
				if not eventData["hour"] or eventData["hour"] == hour then
					if minute == eventData["minute"] then
						eventData["callback"](unpack(eventData["args"]))
						eventData["active"] = false
						setTimer(function()
							eventData["active"] = true
						end, 60*1000, 1)
					end
				end
			end
		end
	end
end

function GlobalTimer:registerEvent(callback, name, weekday, hour, minute, ...)
	local id = #self.m_Events+1
	self.m_Events[id] = {
		["name"] = name,
		["callback"] = callback,
		["weekday"] = weekday,
		["hour"] = hour,
		["minute"] = minute,
		["active"] = true,
		["args"] = {...},
	}
end
