-- ****************************************************************************
-- *
-- *  PROJECT: vRoleplay
-- *  FILE: server/classes/Vehicles/GPS.lua
-- *  PURPOSE: GPS class
-- *
-- ****************************************************************************
GPS = inherit(Singleton)
addEvent("GPS.calcRoute", true)

function GPS:constructor()
	assert(loadPathGraph, "GPS module not loaded!")
	loadPathGraph("files/paths/sa_nodes.json")

	addEventHandler("GPS.calcRoute", root, bindAsync(self.Event_calcRoute, self))
end

function GPS:destructor()
	unloadPathGraph()
end

function GPS:getRoute(callback, from, to)
	return findShortestPathBetween(from.x, from.y, from.z, to.x, to.y, to.z, callback)
end

function GPS:asyncGetRoute(from, to, dontSerialise)
	-- Use the pathfind module to calculate the route
	self:getRoute(Async.waitFor(), from, to)
	local nodes = Async.wait()

	-- Normalise nodes
	if not dontSerialise then
		for i, v in pairs(nodes) do
			nodes[i] = normaliseVector(v)
		end
	end

	return nodes
end

function GPS:Event_calcRoute(event, from, to)
	local c = client
	local nodes = GPS:getSingleton():asyncGetRoute(normaliseVector(from), normaliseVector(to), true)
	if nodes then
		c:triggerEvent(event, nodes)
	end
end
