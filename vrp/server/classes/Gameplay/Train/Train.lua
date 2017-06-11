Train = inherit(Object)

function Train:new(Id, Track, Node, ...)
	-- 449: Tram
	local vehicle = createVehicle(Id, TrainManager:getSingleton():getNode(Track, Node).pos)
	enew(vehicle, self, ...)

	vehicle:setDirection(true)
	vehicle:setDerailable(false)
	setVehicleLocked(true)
	vehicle.getMileage = function () end
	return vehicle
end

function Train:constructor(speed)
	self.m_Manager = TrainManager:getSingleton()
	self.m_Id = #self.m_Manager.Map+1
	self.m_Speed = speed or 0.5

	-- Add ref to Manager
	self.m_Manager:addRef(self)

	-- Disable Sync
	addEventHandler("onElementStartSync", self,
		function (syncer)
			--setElementSyncer(self, nil)
			--cancelEvent()
			for i, v in pairs(self.m_Manager.Map) do
				setElementSyncer(v, syncer)
			end
		end
	)
end

function Train:destructor()
	self.m_Manager:removeRef(self)

	-- Destroy Trailer
	for i, v in pairs(self.Trailers or {}) do
		v:destroy()
	end
end

-- Originally from https://github.com/ReWrite94/iLife/blob/master/server/Classes/Vehicle/cServerTrains.lua#L131-#L178
-- Adjusted a bit for eXo
function Train:update()
	if not self.m_CurrentNode then
		self.m_CurrentNode, self.m_CurrentTrack = self.m_Manager:getClosestNodeToPoint(self:getPosition())
		self.m_CurrentDistance = self.m_CurrentNode.distance
	end

	local nextNode = self.m_Manager:getNode(self.m_CurrentTrack, self.m_CurrentNode.index+1) or self.m_Manager:getNode(self.m_CurrentTrack, 1)
	local deltaTrackDistance = self.m_Speed * 50 * self.m_Manager.m_UpdateInterval / 1000

	self.m_CurrentDistance = self.m_CurrentDistance + deltaTrackDistance
	while self.m_CurrentDistance > nextNode.distance do
		self.m_CurrentNode = nextNode
		nextNode = self.m_Manager:getNode(self.m_CurrentTrack, self.m_CurrentNode.index+1)

		if not nextNode then
			nextNode = self.m_Manager:getNode(self.m_CurrentTrack, 1)
			self.m_CurrentNode = self.m_Manager:getNode(self.m_CurrentTrack, 2)
			self.m_CurrentDistance = self.m_CurrentNode.distance
			break
		end
	end

	local deltaNodes = getDistanceBetweenPoints3D(self.m_CurrentNode.pos, nextNode.pos)
	local progress = (self.m_CurrentDistance - self.m_CurrentNode.distance) / deltaNodes
	local x, y, z = interpolateBetween(self.m_CurrentNode.pos, nextNode.pos, progress, "Linear")

	local zone = getZoneName(x, y, z, false)
    if(self.m_Manager.m_SlowPositions[string.lower(zone)]) then
        self.m_Speed = 0.4
    elseif(self.m_Manager.m_VerySlowPositions[string.lower(zone)]) then
        self.m_Speed = 0.15
    elseif(self.m_Manager.m_VeryFastPositions[string.lower(zone)]) then
        self.m_Speed = 1.1
    else
        self.m_Speed = 0.8
    end

	 triggerClientEvent("onTrainSync", self, x, y, z, self.m_Speed/1.398356930606537) -- Speed = 1 => TrainSpeed = 0.715125
end
