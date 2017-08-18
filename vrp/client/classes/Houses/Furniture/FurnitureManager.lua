FurnitureManager = inherit(Singleton)

function FurnitureManager:constructor()
	self.m_Map = {}
end

function FurnitureManager:desturctor()
	for houseId, objectList in pairs(self.m_Map) do
		for objectId, object in pairs(objectList) do
			object:destroy()
		end
	end
end

function FurnitureManager:addRef(house, obj)
	if not self.m_Map[house] then
		self.m_Map[house] = {}
	end
	table.insert(self.m_Map[house], obj)
end

function FurnitureManager:loadFurniture(houseId, objectList)
	local queue = AutomaticQueue:new()
	local trigger = queue:prepare()
	for index, objectData in pairs(objectList) do
		local obj = {
			data = {
				objectData.model,
				objectData.position,
				objectData.rotation,
				objectData.dimension,
				objectData.rotation,
			},
			trigger = function(self)
				self:addRef(houseId, Furniture.create(unpack(self.data)))
				return true
			end
		}

		queue:push(obj)
	end
	trigger()
end

function FurnitureManager:unloadFurniture(houseId)
	for index, object in pairs(self.m_Map[houseId]) do
		object:destroy()
	end
	self.m_Map[houseId] = nil
end

function FurnitureManager.disableGTAFurniture()
	for i = 1, 4, 1 do
		setInteriorFurnitureEnabled(i, false)
	end
end

function Furniture.enableGTAFurniture()
	for i = 1, 4, 1 do
		setInteriorFurnitureEnabled(i, true)
	end
end

addEvent("FurnitureManager:load", true)
addEventHandler("FurnitureManager:load", root,
	function(...)
		Furniture.disableGTAFurniture()
		FurnitureManager:getSingleton():loadFurniture(...)
	end
)

addEvent("FurnitureManager:unload", true)
addEventHandler("FurnitureManager:unload", root,
	function(...)
		FurnitureManager:getSingleton():unloadFurniture(...)
		Furniture.enableGTAFurniture()
	end
)
