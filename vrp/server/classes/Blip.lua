Blip = inherit(Object)
Blip.Map = {}

function Blip:constructor(imagePath, x, y)
	self.m_ImagePath = imagePath
	self.m_PosX, self.m_PosY = x, y
	
	table.insert(Blip.Map, self)
	triggerClientEvent("blipCreate", root, #Blip.Map, self.m_ImagePath, self.m_PosX, self.m_PosY)
end

function Blip:destructor()
	local idx = table.find(Blip.Map, self)
	if not idx then return end
	
	table.remove(Blip.Map, idx)
	triggerClientEvent("blipDestroy", root, idx)
end

function Blip.sendAllToClient()
	local data = {}
	for k, v in ipairs(Blip.Map) do
		data[k] = {v.m_ImagePath, v.m_PosX, v.m_PosY}
	end
	triggerClientEvent("blipsRetrieve", root, data)
end
