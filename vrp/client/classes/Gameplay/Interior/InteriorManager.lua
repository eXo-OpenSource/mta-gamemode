-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Interior/InteriorManager.lua
-- *  PURPOSE:     Manages custom interiors 
-- *
-- ****************************************************************************
InteriorManager = inherit(Singleton)
InteriorManager.Map = {}

function InteriorManager:constructor() 
	addRemoteEvents{"InteriorManager:onStartMap", "InteriorManager:onEnter",  "InteriorManager:onExit"}
	addEventHandler("InteriorManager:onStartMap", root, bind(self.Event_onStartMap, self))
	addEventHandler("InteriorManager:onEnter", root, bind(self.Event_onEnter, self))
	addEventHandler("InteriorManager:onExit", root, bind(self.Event_onExit, self))

	self.m_UpdateBind = bind(self.check, self)
end

function InteriorManager:Event_onStartMap(mapSize) 
	self.m_MapSize = mapSize
end

function InteriorManager:Event_onEnter(data)
	self:clean()
	self.m_AntiFall = Antifall:new()
	self:initialise(data)
end 

function InteriorManager:Event_onExit() 
	self:clean()
	removeEventHandler("onClientPreRender", root, self.m_UpdateBind)
end

function InteriorManager:initialise(data) 
	local map = data.map 
	self.m_Position = Vector3(data.position.x, data.position.y, data.position.z)
	self.m_Dimension = data.dimension 
	self.m_Interior = data.interior
	self.m_Count = 0
	self:create(map, self:getDimension())
end

function InteriorManager:create(map, dimension) 
	if map then  
		self.m_Map = MapParser:new(nil, map) 
		if self:getMap() then 
			self:shift(self:getPosition())
			local thread = Thread:new(bind(self.thread, self), THREAD_PRIORITY_HIGHEST)
			nextframe(function() thread:start() end)
		end
	end
end

function InteriorManager:onMapComplete()
	self:getMap():setInterior(self:getInterior(), 1)
	self:getMap():setDimension(self:getDimension(), 1)
	removeEventHandler("onClientPreRender", root, self.m_UpdateBind)
	addEventHandler("onClientPreRender", root, self.m_UpdateBind)
end

function InteriorManager:find()
	for k, info in pairs(self:getMap():getData()) do
		if info.markertype == DYNAMIC_INTERIOR_ENTRANCE_OBJECT_TYPE then
			return self:setVirtualEntrance({position = Vector3(info.x, info.y, info.z), interior = info.interior})
		end
	end
end

function InteriorManager:thread() 
	for k, info in pairs(self:getMap():getData()) do
		self:getMap():createSingle(info, self.m_Dimension)
		self:increaseIterateCount()
		Thread.pause()
		if self:getIterateCount() == table.size(self:getMap():getData()) then 
			self:onMapComplete()
		end
	end
end

function InteriorManager:shift(position)
	if self:find() then 
		local start =  self:getVirtualEntrance().position 
		local move = (position - start)
		for k, info in pairs(self:getMap():getData()) do
			info.x = info.x + move.x
			info.y = info.y + move.y 
			info.z = info.z + move.z  
		end
	end
end

function InteriorManager:clean() 
	if self:getMap() then 
		self:getMap():delete()
	end
	if self.m_AntiFall then 
		self.m_AntiFall:delete()
	end
end


function InteriorManager:check() 
	if localPlayer:getDimension() ~= self:getDimension() or localPlayer:getInterior() ~= self:getInterior() then 
		removeEventHandler("onClientPreRender", root, self.m_UpdateBind)
		triggerServerEvent("InteriorManager:onDetectLeave", localPlayer, self:getInterior(), self:getDimension())
	end
end

function InteriorManager:setVirtualEntrance(data) 
	self.m_VirtualEntrance = data
	return data
end

function InteriorManager:setEntrance(element)
	self.m_Entrance = element
	return element
end

function InteriorManager:getEntrance()
	return self.m_Entrance
end

function InteriorManager:getVirtualEntrance() 
	return self.m_VirtualEntrance
end

function InteriorManager:getMap()
	return self.m_Map
end

function InteriorManager:getElements() 
	return #self:getMap():getElements()
end

function InteriorManager:getIterateCount() 
	return self.m_Count
end

function InteriorManager:getInterior() return self.m_Interior end 
function InteriorManager:getDimension() return self.m_Dimension end 
function InteriorManager:getPosition() return self.m_Position end 

function InteriorManager:increaseIterateCount() 
	self.m_Count = self.m_Count + 1
end

function InteriorManager:destructor() 

end

