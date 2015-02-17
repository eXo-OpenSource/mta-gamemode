RadarArea = inherit(Object)
RadarArea.Map = {}

function RadarArea:constructor(x, y, width, height, color)
	self.m_PosX, self.m_PosY = x, y
	self.m_Width, self.m_Height = width, height
	self.m_Color = color
	
	table.insert(RadarArea.Map, self)
	for k, player in ipairs(getElementsByType("player")) do
		if player:isLoggedIn() then
			player:triggerEvent("radarAreaCreate", #RadarArea.Map, self.m_PosX, self.m_PosY, self.m_Width, self.m_Height, self.m_Color)
		end
	end
end

function RadarArea:destructor()
	local idx = table.find(RadarArea.Map, self)
	if not idx then return end
	
	table.remove(RadarArea.Map, idx)
	triggerClientEvent("radarAreaDestroy", root, idx)
end

function RadarArea.sendAllToClient(player)
	local data = {}
	for k, v in ipairs(RadarArea.Map) do
		data[k] = {v.m_PosX, v.m_PosY, v.m_Width, v.m_Height, v.m_Color}
	end
	player:triggerEvent("radarAreasRetrieve", data)
end
