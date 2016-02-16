TrainManager = inherit(Singleton)
TrainManager.Map = {}

function TrainManager:constructor()
	self.m_Tracks = {}
	self.m_TrackFiles = {"files/data/traintracks/tracks.dat"}

	-- Finally load the tracks
	self:loadTracks()
	self:calculateTracksDistance()
end

function TrainManager:destructor()

end

function TrainManager:addRef(ref)
	TrainManager.Map[ref:getId()] = ref
end

function TrainManager:removeRef(ref)
	TrainManager.Map[ref:getId()] = nil
end

function TrainManager:loadTracks()
	outputDebug(("Started loading %d Track(s) for ServerTrains."):format(#self.m_TrackFiles))
	local start = getTickCount()

	for trackIndex, filePath in ipairs(self.m_TrackFiles) do
		local file = fileOpen(filePath, true) -- Open file with "read-only" tag
		local data = file:read(file:getSize())
		file:close()

		for nodeIndex, nodePos in ipairs(split(data, "\r\n")) do
			if nodeIndex ~= 1 then
				self:createNode(trackIndex, nodeIndex-1, Vector3(unpack(split(nodePos, " "))))
			else
				outputDebug(("Loading %d Track node(s) for Track %d."):format(nodePos, trackIndex))
			end
		end
	end

	outputDebug(("Finished loading %d Track(s) for ServerTrains, took %dms."):format(#self.m_TrackFiles, getTickCount()-start))
end

function TrainManager:calculateTracksDistance()
	for trackIndex, Nodes in ipairs(self.m_Tracks) do
		for nodeIndex, nodeData in ipairs(Nodes) do
			local prevTrackData = self:getNode(trackIndex, nodeIndex-1) or self:getNode(trackIndex, #self:getNode(trackIndex))
			prevTrackData.distanceToNext = getDistanceBetweenPoints3D(prevTrackData.pos, nodeData.pos)
		end
	end
end

function TrainManager:createNode(trackIndex, nodeIndex, pos)
	if not self.m_Tracks[trackIndex] then self.m_Tracks[trackIndex] = {} end
	if self.m_Tracks[trackIndex][nodeIndex] then return false end

	local node = {index = nodeIndex, track = trackIndex, pos = pos}
	self.m_Tracks[trackIndex][nodeIndex] = node

	if DEBUG then
		local marker = Marker.create(node.pos, "cylinder", 2)
		marker:setColor(6, 163, 212, 150)

		addEventHandler("onMarkerHit", marker, function (hitElement, matchingDim)
			if matchingDim and hitElement:getType() == "vehicle" then
				self:outputNodeInfo(node.track, node.index)
			end
		end)
	end

	return node
end

function TrainManager:getNode(trackIndex, nodeIndex)
	if not trackIndex then return self.m_Tracks end
	if not nodeIndex then return self.m_Tracks[trackIndex] end
	if not self.m_Tracks[trackIndex] then return false end
	if not self.m_Tracks[trackIndex][nodeIndex] then return false end

	return self.m_Tracks[trackIndex][nodeIndex]
end

-- DEBUG
function TrainManager:outputNodeInfo(...)
	local node = self:getNode(...)
	if node then
		outputDebug(("Found new node. Node: %s NodeDistanceToNext: %s (Track: %s)"):format(tostring(node.index), tostring(node.distanceToNext), tostring(node.track)))
	end
end
