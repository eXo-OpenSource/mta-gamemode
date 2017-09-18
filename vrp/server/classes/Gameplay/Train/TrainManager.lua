TrainManager = inherit(Singleton)
TrainManager.Map = {}

function TrainManager:constructor()
	self.m_Tracks = {}
	self.m_TrackFiles = {
		"files/data/traintracks/tracks.dat",
		--"files/data/traintracks/tracks2.dat",
		--"files/data/traintracks/tracks3.dat",
		--"files/data/traintracks/tracks4.dat",
	}

	self.m_UpdateInterval = 1000

    self.m_VerySlowPositions =
    {
        ["unity station"]   = true,
		["el corona"]       = true,
        ["jefferson"]       = true,
        ["east los santos"] = true,
        ["idlewood"]        = true,
        ["willowfield"]     = true,
        ["las colinas"]     = true,
    }
    self.m_SlowPositions =
    {
        ["doherty"]         	= true,
        ["prickle pine"]    	= true,
        ["linden side"]    		= true,
        ["verdant bluffs"]  	= true,
        ["conference center"]  	= true,
        ["marina"]  			= true,
        ["market"]  			= true,
        ["market station"]  	= true,
		["verona beach"]		= true,
		["vinewood"]			= true,
		["cranberry station"]   = true,
        ["linden station"]      = true,
        ["sobell rail yards"]   = true,
        ["yellow bell station"] = true,
    }

	-- Finally load the tracks
	Thread:newPromise(
		function ()
			self:loadTracks()
			self:calculateNodeDistances()
		end, THREAD_PRIORITY_HIGHEST
	).done(
		function () TrainManager.onInitFinished() end,
		function () end -- should never get called!
	)

	-- Start the update Timer
	self.m_Timer = setTimer(bind(self.updateTrains, self), self.m_UpdateInterval, 0)
end

function TrainManager:destructor()
	if isTimer(self.m_Timer) then
		killTimer(self.m_Timer)
	end
	for trackIndex, Nodes in pairs(self.m_Tracks) do
		for nodeIndex, nodeData in pairs(Nodes) do
			if nodeData.DEBUG then
				if nodeData.DEBUG.Marker then
					nodeData.DEBUG.Marker:destroy()
				end
			end
		end
	end
	for i, v in pairs(self.Map) do
		if isElement(v) then
			v:destroy()
		end
	end

	self.m_Tracks = {}
end

function TrainManager:addRef(ref)
	TrainManager.Map[ref:getId()] = ref
end

function TrainManager:removeRef(ref)
	TrainManager.Map[ref:getId()] = nil
end

function TrainManager:loadTracks()
	for trackIndex, filePath in ipairs(self.m_TrackFiles) do
		local file = fileOpen(filePath, true) -- Open file with "read-only" tag
		local data = file:read(file:getSize())
		file:close()

		local runs = 1
		for nodeIndex, nodePos in ipairs(split(data, "\r\n")) do
			if nodeIndex ~= 1 then
				self:createNode(trackIndex, nodeIndex-1, Vector3(unpack(split(nodePos, " "))))
			end

			runs = runs + 1
			if runs%100 == 0 then
				Thread.pause()
			end
		end
	end
end

function TrainManager:calculateNodeDistances()
	for trackIndex, Nodes in ipairs(self.m_Tracks) do
		local distance = 0
		for nodeIndex, nodeData in ipairs(Nodes) do
			local prevNode = self:getNode(trackIndex, nodeIndex-1) or self:getNode(trackIndex, #self:getNode(trackIndex))
			distance = distance + getDistanceBetweenPoints3D(nodeData.pos, prevNode.pos)
			nodeData.distance = distance
		end
	end
end

function TrainManager:createNode(trackIndex, nodeIndex, pos)
	if not self.m_Tracks[trackIndex] then self.m_Tracks[trackIndex] = {} end
	if self.m_Tracks[trackIndex][nodeIndex] then return false end

	local node = {index = nodeIndex, track = trackIndex, pos = pos}
	self.m_Tracks[trackIndex][nodeIndex] = node


	--[[if DEBUG then
		local marker = Marker.create(node.pos, "cylinder", 2)
		marker:setColor(6, 163, 212, 150)

		addEventHandler("onMarkerHit", marker, function (hitElement, matchingDim)
			if matchingDim and hitElement:getType() == "vehicle" then
				self:outputNodeInfo(node.track, node.index, hitElement)
			end
		end)

		node.DEBUG = {Marker = marker}
	end]]

	return node
end

function TrainManager:getNode(trackIndex, nodeIndex)
	if not trackIndex then return self.m_Tracks end
	if not self.m_Tracks[trackIndex] then return false end
	if not nodeIndex then return self.m_Tracks[trackIndex] end
	if not self.m_Tracks[trackIndex][nodeIndex] then return false end

	return self.m_Tracks[trackIndex][nodeIndex]
end

function TrainManager:getRandomNode(trackIndex)
	if not trackIndex then return false end
	return Randomizer:getRandomTableValue(self:getNode(trackIndex))
end

function TrainManager:getClosestNodeToPoint(pos)
    local minDistance = math.huge
    local closestNode, closestTrack

    for trackIndex, Nodes in ipairs(self.m_Tracks) do
        for nodeIndex, nodeData in ipairs(Nodes) do
            local distance = getDistanceBetweenPoints3D(pos, nodeData.pos)
            if distance < minDistance then
                minDistance = distance
                closestNode = nodeData
                closestTrack = trackIndex
            end
        end
    end

    return closestNode, closestTrack
end

function TrainManager:updateTrains()
	for i, Train in pairs(self.Map) do
		if Train and Train.update then
			Train:update()
		else
			self.Map[i] = nil
		end
	end
end

function TrainManager.onInitFinished()
	Train:new(537, 1, 255, 0.8, {
        569,
        569,
        569,
        569,
        569,
        590,
    })
end


function TrainManager:outputNodeInfo(trackIndex, nodeIndex, hitElement)
	local node = self:getNode(trackIndex, nodeIndex)
	if node and hitElement:getOccupant() then
		--outputDebug(("Found new node.\nNode: %s NodeDistanceData: %s (Track: %s)"):format(tostring(node.index), tostring(node.distance), tostring(node.track)))
		hitElement:getOccupant():sendShortMessage(("TrainTrack Node:\nNode: %s\nNodeDistanceData: %s\nTrack: %s"):format(tostring(node.index), tostring(node.distance), tostring(node.track)), "TrainManager - Nerd Statistics", nil, 5000)
	end
end

