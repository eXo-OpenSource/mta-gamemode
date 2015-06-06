Blip = inherit(Object)
Blip.Map = {}

function Blip:constructor(imagePath, x, y, visibleTo)
	self.m_ImagePath = imagePath
	self.m_PosX, self.m_PosY = x, y
	self.m_VisibleTo = visibleTo or root

	self.m_Id = #Blip.Map + 1
	Blip.Map[self.m_Id] = self

	if self.m_VisibleTo == root then
		for k, player in pairs(getElementsByType("player")) do
			if player:isLoggedIn() then
				player:triggerEvent("blipCreate", self.m_Id, self.m_ImagePath, self.m_PosX, self.m_PosY)
			end
		end
	else
		self.m_VisibleTo:triggerEvent("blipCreate", self.m_Id, self.m_ImagePath, self.m_PosX, self.m_PosY)
	end
end

function Blip:destructor()
	Blip.Map[self.m_Id] = nil

	if self.m_VisibleTo == root then
		triggerClientEvent("blipDestroy", root, self.m_Id)
	else
		self.m_VisibleTo:triggerEvent("blipDestroy", self.m_Id)
	end
end

function Blip.sendAllToClient(player)
	local data = {}
	for k, v in pairs(Blip.Map) do
		if v.m_VisibleTo == root then
			data[k] = {v.m_ImagePath, v.m_PosX, v.m_PosY}
		end
	end
	player:triggerEvent("blipsRetrieve", data)
end
