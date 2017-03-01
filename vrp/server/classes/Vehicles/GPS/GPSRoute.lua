GPSRoute = inherit(Object)
local MIN_TIME_RECALC = 5000

function GPSRoute:constructor(client, from, to, communicationEvent)
	self.m_Client = client
	self.m_Start = from
	self.m_End = to
	self.m_CommunicationEvent = communicationEvent
	self.m_LastUpdate = 0
	self.m_Graph = {}
end

function GPSRoute:destructor()
	GPSManager.removeRef(self)
end

function GPSRoute:calculate()
	-- lets get started with calculating the route
	findShortestPathBetween(self.m_Start.x, self.m_Start.y, self.m_Start.z, self.m_End.x, self.m_End.y, self.m_End.z, bind(GPSRoute.onRouteFound, self))
end

function GPSRoute:onRouteFound(nodes)
	if #self.m_Graph > 0 then -- delete old graph
		self.m_Graph = {}
	end

	for i, v in pairs(nodes) do
		self.m_Graph[i] = Vector3(v[1], v[2], v[3])
	end

	-- tell the client
	self:sendToClient()
end

function GPSRoute:recalculate(from)
	if (getTickCount() - self.m_LastUpdate) >= MIN_TIME_RECALC then
		self.m_LastUpdate = getTickCount()
		self.m_Start = from
		self:calculate()
	end
end

function GPSRoute:sendToClient()
	local tab = {}
	for i, v in pairs(self.m_Graph) do
		tab[i] = serialiseVector(v)
	end
	triggerClientEvent(self.m_Client, self.m_CommunicationEvent or "onGPSRouteCalculated", self.m_Client, self.m_Id, tab)
end
