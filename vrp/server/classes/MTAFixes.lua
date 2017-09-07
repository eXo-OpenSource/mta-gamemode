-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/MTAFixes.lua
-- *  PURPOSE:     MTA fixes class
-- *
-- ****************************************************************************
MTAFixes = inherit(Singleton)

function MTAFixes:constructor()
	self.m_TrailerSyncer = {}
	addEventHandler("onTrailerAttach", root, bind(self.onTrailerAttach, self))
	addEventHandler("onTrailerDetach", root, bind(self.onTrailerDetach, self))
	addEventHandler("onElementStopSync", root, bind(self.onElementStopSync, self))
	addEventHandler("onVehicleStartEnter", root, bind(self.onVehicleStartEnter, self))
end

function MTAFixes:onTrailerAttach(veh)
	local driver = getVehicleOccupant(veh)
	if driver and getElementType(driver) == "player" then
		if self.m_TrailerSyncer[source] ~= driver then
			self.m_TrailerSyncer[source] = driver
			setElementSyncer(source, driver) -- Set Sycronisation
		end
	end
end

function MTAFixes:onTrailerDetach(veh)
	local x, y, z = getElementVelocity(veh)
	setElementVelocity(source, x, y, z) -- Setting Velocity to Source Vehicle Speed to reduce sync problems
end

function MTAFixes:onElementStopSync(oldSyncer)
	if getElementType(source) == "vehicle" then
		self.m_TrailerSyncer[source] = getElementSyncer(source) -- Set new Syncer
	end
end

-- Avoid to kill drivers instant while spamming space
function MTAFixes:onVehicleStartEnter(player, seat, jacked, door)
	if jacked and seat == 0 and door == 1 then
		toggleControl(player, "sprint", false)
		setTimer(toggleControl, 10000, 1, player, "sprint", true)
	end
end
