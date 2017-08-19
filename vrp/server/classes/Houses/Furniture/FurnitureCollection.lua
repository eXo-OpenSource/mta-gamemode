-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Houses/Furniture/FurnitureCollection.lua
-- *  PURPOSE:     Abstract FurnitureCollection class
-- *
-- ****************************************************************************
FurnitureCollection = inherit(Object)
FurnitureCollection.constructor = pure_virtual
FurnitureCollection.destructor = pure_virtual

function FurnitureCollection:virtual_constructor(house, furnitures)
	self.m_House = house
	self.m_Furnitures = self.loadList(self.m_House, furnitures)
	self.m_LoadingQueue = AutomaticQueue:new()
end

function FurnitureCollection:virtual_destructor()

end

function FurnitureCollection:load()
	self.m_LoadingQueue:clear()

	local trigger = self.m_LoadingQueue:prepare(THREAD_PRIORITY_HIGHEST)
	for i, furniture in ipairs(self.m_Furnitures) do
		furniture.trigger = function(self, ...) return self:load(...) end
		self.m_LoadingQueue:push(furniture)
	end
	pcall(trigger)
end

function FurnitureCollection:unload()
	 for i, furniture in pairs(self.m_Furnitures) do
		furniture:unload()
	 end
end

function FurnitureCollection:findByObject(object)
	for i, furniture in pars(self.m_Furnitures) do
		if furniture:getObject() == object then
			return furniture
		end
	end
	return false
end

function FurnitureCollection:remove(furniture)
	local idx = table.find(self.m_Furnitures, furniture)
	if idx then
		table.remove(self.m_Furnitures, idx)
		return true
	end
	return false
end

function FurnitureCollection:removeByObject(object)
	return self:remove(self:findByObject(object))
end

function FurnitureCollection:add(furniture)
	table.insert(self.m_Furnitures, furniture)
	return true
end

function FurnitureCollection:addByData(model, position, rotation, dimension, interior)
	return self:add(Furniture:new(self.m_House, model, position, rotation, dimension, interior))
end

function FurnitureCollection.loadList(house, furnitures)
	local tab = {}
	for i, objectData in ipairs(furnitures) do
		tab[i] = Furniture:new(house, objectData.model, objectData.position, objectData.rotation, objectData.dimension, objectData.interior)
	end
	return tab
end
