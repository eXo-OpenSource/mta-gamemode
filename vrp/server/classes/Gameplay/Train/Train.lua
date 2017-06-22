Train = inherit(Object)

function Train:new(Id, Track, Node, ...)
    local obj = createColSphere(TrainManager:getSingleton():getNode(Track, Node).pos, 200)
	--local vehicle = createVehicle(411, TrainManager:getSingleton():getNode(Track, Node).pos)
	enew(obj, self, ...)
    obj.m_EngineModel = Id
	return obj
end

function Train:constructor(speed, trailers)
	self.m_Manager = TrainManager:getSingleton()
	self.m_Id = #self.m_Manager.Map+1
	self.m_Speed = speed or 0.5
    self.Trailers = trailers
    self.m_Visible = false
	-- Add ref to Manager
	self.m_Manager:addRef(self)
end


function Train:toggleVisibleTrain(state)
    if self.m_Visible ~= state then
        if state then
            self.m_VisibleVehs = {
                createVehicle(self.m_EngineModel, self:getPosition()), --engine
            }
            self.m_GhostDriver = createPed(294, self:getPosition())
            warpPedIntoVehicle(self.m_GhostDriver, self.m_VisibleVehs[1])
            self.m_VisibleVehs[1]:setDirection(true)
            self.m_VisibleVehs[1]:setDerailable(false)
            self.m_VisibleVehs[1]:setLocked(true)
            for i, v in pairs(self.Trailers) do
                nextframe(function ()
                    local trailer = createVehicle(v, self:getPosition())
                    self.m_VisibleVehs[i + 1] = trailer
                    attachTrailerToVehicle(self.m_VisibleVehs[i], trailer)
                end)
            end
            setTimer(function() --fix for trailers sometimes being left behind
                for i = 2, #self.m_VisibleVehs do
                    attachTrailerToVehicle(self.m_VisibleVehs[i-1], self.m_VisibleVehs[i])
                end
            end, 50*(#self.m_VisibleVehs), 1)
        else
            for i,v in pairs(self.m_VisibleVehs) do
                if isElement(v) then v:destroy() end
            end
            self.m_GhostDriver:destroy()
        end
        self.m_Visible = state
    end
end

function Train:destructor()
	self.m_Manager:removeRef(self)
    self.m_RenderCol:destroy()
	if self.m_Visible then
        self:toggleVisibleTrain(false)
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
    
    self:setPosition(x, y, z+2)
    self:toggleVisibleTrain(#getElementsWithinColShape(self, "player") > 0)
    if self.m_Visible then 
        --self.m_VisibleVehs[1]:setTrainSpeed(self.m_Speed/1.398356930606537)
        self.m_VisibleVehs[1]:setTrainSpeed(self.m_Speed*0.99)
    end
    
	local zone = getZoneName(x, y, z, false) --for next update
    if(self.m_Manager.m_SlowPositions[string.lower(zone)]) then
        self.m_Speed = 0.4
    elseif(self.m_Manager.m_VerySlowPositions[string.lower(zone)]) then
        self.m_Speed = 0.2
    else
        self.m_Speed = 0.6
    end

	triggerClientEvent("onTrainSync", self, x, y, z, self.m_Visible and self.m_VisibleVehs[1])
end
