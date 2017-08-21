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
	self.m_Furnitures = {}
	self.m_LoadingQueue = AutomaticQueue:new()

	self:loadList(furnitures)
end

function FurnitureCollection:virtual_destructor()
	for i, furniture in pairs(self.m_Furnitures) do
		self:remove(furniture)
		delete(furniture)
	end
end

function FurnitureCollection:load()
	self.m_LoadingQueue:clear()

	local trigger = self.m_LoadingQueue:prepare(THREAD_PRIORITY_HIGHEST)
	for i, furniture in ipairs(self.m_Furnitures) do
		outputDebug(furniture)
		furniture.trigger = function(self, ...) return self:load(...) end
		self.m_LoadingQueue:push(furniture)
	end
	trigger()
end

function FurnitureCollection:unload()
	 for i, furniture in pairs(self.m_Furnitures) do
		furniture:unload()
	 end
end

function FurnitureCollection:findByObject(object)
	for i, furniture in pairs(self.m_Furnitures) do
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
		delete(furniture)
		return true
	end
	return false
end

function FurnitureCollection:removeByObject(object)
	return self:remove(self:findByObject(object))
end

function FurnitureCollection:add(furniture, load)
	table.insert(self.m_Furnitures, furniture)
	if load then
		furniture:load()
	end
	return true
end

function FurnitureCollection:addByData(item, model, position, rotation, dimension, interior, load)
	return self:add(Furniture:new(self.m_House, item, model, position, rotation, dimension, interior), load)
end

function FurnitureCollection:loadList(furnitures)
	for i, objectData in ipairs(furnitures) do
		self:addByData(ItemManager:getSingleton():getInstance(objectData.item), objectData.model, objectData.position, objectData.rotation, objectData.dimension, objectData.interior)
	end
end
