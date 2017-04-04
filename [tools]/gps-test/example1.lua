GPS1 = inherit(Object)
GPS1.GraphFile = "files/nodes/sa_nodes.json"
loadPathGraph(GPS1.GraphFile)

function GPS1:constructor()
end

function GPS1:destructor()
end

function GPS1:getRoute(callback, from, to)
	return findShortestPathBetween(from.x, from.y, from.z, to.x, to.y, to.z, callback)
end

function GPS1:asyncGetRoute(from, to)
	if not isGraphLoaded() then error("Graph is not loaded, cannot calculated route!") end

	-- Use A* to calculate the route (Asynchronus)
	print(("Calculating route from %s to %s"):format(tostring(from), tostring(to)))
	self:getRoute(Async.waitFor(), from, to)
	local nodes = Async.wait()
	print(("Done calculating route got %d node!"):format(#nodes))

	for i, v in pairs(nodes) do
		--nodes[i] = normaliseVector(v)
	end

	return nodes
end

print("example1 should not work")
Async.create(
	function()
		local nodes = GPS1:new():asyncGetRoute(Vector3(0, 0, 0), Vector3(3000, 3000, 3))
		print(#nodes)
	end
)
