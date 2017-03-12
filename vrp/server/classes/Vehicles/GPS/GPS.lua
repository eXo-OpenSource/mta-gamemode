GPS = inherit(Singleton)

function GPS:constructor()
	loadPathGraph("files/nodes/sa_nodes.json")
end

function GPS:destructor()
	unloadPathGraph()
end

function GPS:getRoute(callback, from, to)
	return findShortestPathBetween(from.x, from.y, from.z, to.x, to.y, to.z, callback)
end

function GPS:asyncGetRoute(from, to, dontNormalise)
	-- Use A* to calc route
	self:getRoute(Async.waitFor(), from, to)
	local nodes = Async.wait()

	if not dontNormalise then
		-- normalise Nodes
		for i, v in pairs(nodes) do
			nodes[i] = normaliseVector(v)
		end
	end

	return nodes
end

addEvent("GPS.calcRoute", true)
addEventHandler("GPS.calcRoute",
	function (event, from, to)
		Async.create(function()
			local nodes = GPS:getSingleton():asyncGetRoute(from, to, true)
			if nodes then
				client:triggerEvent(event, nodes)
			end
		end)()
	end)
