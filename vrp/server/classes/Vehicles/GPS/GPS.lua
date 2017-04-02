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
	-- Check if module is loaded
	if not loadPathGraph then
		outputDebugString("GPS module not loaded. Continuing without...", 2)
		return
	end

	-- Load path graph
	loadPathGraph("files/paths/sa_nodes.json")

	-- Add events
	addEventHandler("GPS.calcRoute", root, bindAsync(self.Event_calcRoute, self))
end

function GPS:destructor()
	if unloadPathGraph then
		unloadPathGraph()
	end
end

function GPS:getRoute(callback, from, to)
	if not findShortestPathBetween then
		return false
	end
	return findShortestPathBetween(from.x, from.y, from.z, to.x, to.y, to.z, callback)
end

function GPS:asyncGetRoute(from, to, dontUnserialise)
	-- Use the pathfind module to calculate the route
	self:getRoute(Async.waitFor(), from, to)
	local nodes = Async.wait()

	-- Unserialise nodes
	if not dontUnserialise then
		nodes = table.map(nodes, normaliseVector)
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
