GPS2 = inherit(Object)
GPS2.GraphFile = "files/nodes/sa_nodes.json"

function GPS2:constructor()
end

function GPS2:destructor()
end

function GPS2:getRoute(from, to)
	print(("Calculating route from %s to %s"):format(tostring(from), tostring(to)))
	return findShortestPathBetween(from.x, from.y, from.z, to.x, to.y, to.z, bind(GPS2.getRouteCallback, self))
end

function GPS2:getRouteCallback(nodes)
	print(("Done calculating route got %d node!"):format(#nodes))

	for i, v in pairs(nodes) do
		--nodes[i] = normaliseVector(v)
	end

	return nodes
end

print("example2 should work")
GPS2:new():getRoute(Vector3(0, 0, 0), Vector3(3000, 3000, 3))
