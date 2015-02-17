Blip = inherit(Object)
Blip.Map = {}

function Blip:constructor(imagePath, x, y, visibleTo)
	self.m_ImagePath = imagePath
	self.m_PosX, self.m_PosY = x, y
	self.m_VisibleTo = visibleTo or root
	
	table.insert(Blip.Map, self)
	
	if self.m_VisibleTo == root then
		for k, player in pairs(getElementsByType("player")) do
			if player:isLoggedIn() then
				player:triggerEvent("blipCreate", #Blip.Map, self.m_ImagePath, self.m_PosX, self.m_PosY)
			end
		end
	else
		outputDebug("Creating blip for "..getPlayerName(self.m_VisibleTo))
		self.m_VisibleTo:triggerEvent("blipCreate", #Blip.Map, self.m_ImagePath, self.m_PosX, self.m_PosY)
	end
end

function Blip:destructor()
	local idx = table.find(Blip.Map, self)
	if not idx then return end
	
	table.remove(Blip.Map, idx)
	if self.m_VisibleTo == root then
		triggerClientEvent("blipDestroy", root, idx)
	else
		self.m_VisibleTo:triggerEvent("blipDestroy", idx)
	end
end

function Blip.sendAllToClient(player)
	local data = {}
	for k, v in ipairs(Blip.Map) do
		if v.m_VisibleTo == root then
			data[k] = {v.m_ImagePath, v.m_PosX, v.m_PosY}
		end
	end
	player:triggerEvent("blipsRetrieve", data)
end
