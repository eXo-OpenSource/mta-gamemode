GPSManager = inherit(Singleton)
GPSManager.Map = {}
GPSManager.GraphPath = "files/nodes/sa_nodes.json"
addRemoteEvents{"initGPSRoute", "updateGPSRoute", "finishGPSRoute"}

function GPSManager:constructor()
	-- Init Graph
	loadPathGraph(GPSManager.GraphPath)


	addEventHandler("initGPSRoute", root, bind(GPSManager.initGPSRoute, self))
	addEventHandler("updateGPSRoute", root, bind(GPSManager.updateGPSRoute, self))
	addEventHandler("finishGPSRoute", root, bind(GPSManager.finishGPSRoute, self))
end

function GPSManager:destructor()

end

function GPSManager.addRef(ref)
	local id = #GPSManager.Map + 1
	GPSManager.Map[id] = ref
	ref:setId(id)

	return ref
end

function GPSManager.removeRef(ref)
	if GPSManager.Map[ref:getId()] then
		GPSManager.Map[ref:getId()] = nil
	end
end

function GPSManager.getRef(refId)
	return GPSManager.Map[refId]
end

function GPSManager:initGPSRoute(from, to, communicationEvent, delay)
	local from, to = normaliseVector(from), normaliseVector(to)
	local instance = GPSManager.addRef(GPSRoute:new(client, from, to, communicationEvent))
	if not delay then
		instance:calculate()
	else
		setTimer(function() instance:calculate() end, delay, 1)
	end
end

function GPSManager:updateGPSRoute(routeId, from)
	if GPSManager.getRef(routeId) then
		GPSManager.getRef(routeId):recalculate(from)
		return
	end
	client:sendError("GPSManager:updateGPSRoute - Invalid route id!")
end

function GPSManager:finishGPSRoute(routeId)
	if GPSManager.getRef(routeId) then
		delete(GPSManager.getRef(routeId))
	end
end
