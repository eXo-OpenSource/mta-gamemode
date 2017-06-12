Collector = inherit(Object)

function Collector:constructor()
	self.m_Clients = {}
end

function Collector:destructor()

end

function Collector:refresh()
	self.m_Clients = {}
	for i, v in pairs(getElementsByType("player")) do
		self.m_Clients[v] = {
			data = {},
			lastUpdated = math.huge
		}
	end
end

function Collector:Event_receiveData(data, client)
	if self.m_Clients[client] then

	else
		self:refresh()
		self:Event_receiveData(data, client)
	end
end
