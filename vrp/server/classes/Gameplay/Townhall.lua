Townhall = inherit(Singleton)

function Townhall:constructor()
	self.m_Blip = Blip:new("Stadthalle.png", 1481.22, -1749.11, root, 600)
	self.m_Blip:setDisplayText("Stadthalle")
	self.m_Blip:setOptionalColor({7, 161, 213})
	--local elevator = Elevator:new()
	--elevator:addStation("Ausgang", Vector3(1788.389, -1297.811, 13.375))
	--elevator:addStation("Stadthalle", Vector3(1786.800, -1301.099, 120.300), 120)
	self:createGarage()
	self.m_EnterExit = InteriorEnterExit:new(Vector3(1481.09, -1770.12, 18.80), Vector3(2758.5, -2422.8994140625, 816), 0, 0, DYNAMIC_INTERIOR_DUMMY_DIMENSION)
	self.m_EnterExit:addEnterEvent(bind(self.onEnter, self))
	self.m_EnterExit:addExitEvent(bind(self.onExit, self))

	addEventHandler("onCustomInteriorEnter", root, bind(self.Event_onEnter, self))
	addEventHandler("onCustomInteriorLeave", root, bind(self.Event_onExit, self))

	InteriorLoadManager.add(INTERIOR_OWNER_TYPES.SERVER, 2, bind(self.onInteriorLoad, self))
	if INTERIOR_MIGRATION then 
		self:assignInterior()
	end

end


function Townhall:Event_onEnter(id) 
	if self.m_Interior then 
		if self.m_Interior:getId() == id then 
			source:triggerEvent("Townhall:applyTexture") 
		end
	end
end

function Townhall:Event_onExit(id) 
	if self.m_Interior then 
		if self.m_Interior:getId() == id then 
			source:triggerEvent("Townhall:removeTexture") 
		end
	end
end

function Townhall:assignInterior() 
	local path = ("%s/public/%s%s"):format(STATIC_INTERIOR_MAP_PATH, "townhall", ".map")
	local instance = Interior:new(InteriorMapManager:getSingleton():getByPath(path, true,  DYANMIC_INTERIOR_PLACE_MODES.KEEP_POSITION))
			:setTemporary(false)
			:setOwner(INTERIOR_OWNER_TYPES.SERVER, 2)
			:forceSave()
	CustomInteriorManager:getSingleton():add(instance)
	self.m_InteriorId = instance:getId()
	return self
end

function Townhall:onInteriorCreate()
	self.m_EnterExit.m_ExitMarker:setInterior(self.m_Interior:getInterior())
	self.m_EnterExit.m_ExitMarker:setDimension(self.m_Interior:getDimension())
end

function Townhall:onInteriorLoad(instance) 
	self.m_Interior = instance 
	self.m_EnterExit:setInterior(instance)
	self.m_Interior:setExit(self.m_EnterExit.m_EnterMarker:getPosition(), self.m_EnterExit.m_EnterMarker:getInterior(), self.m_EnterExit.m_EnterMarker:getDimension())
	self.m_Interior:setCreateCallback(bind(self.onInteriorCreate, self))
end

function Townhall:onEnter(player, teleporter) 
	
	if not self.m_Interior then 
		CustomInteriorManager:getSingleton():loadFromOwner(INTERIOR_OWNER_TYPES.SERVER, 2)
		return teleporter:enter(player)
	end
end

function Townhall:onExit(player, teleporter) 
	if not self.m_Interior then 
		CustomInteriorManager:getSingleton():loadFromOwner(INTERIOR_OWNER_TYPES.SERVER, 2)
		return teleporter:exit(player)	
	end
end

function Townhall:createGarage()
	VehicleTeleporter:new(Vector3(1403.63, -1503.30, 13.57), Vector3(2108.466796875, 959.41778564453, 3398.7609863281), Vector3(0, 0, 270), Vector3(0, 0, 180), 9, 0, "cylinder" , 5, Vector3(0,0,3))
	InteriorEnterExit:new(Vector3(1397.12, -1571.02, 14.27), Vector3(2118.47, 909.90, 3389.54), 180, 0, 9, 0)
	local blip = Blip:new("Parking.png", 1403.63, -1503.30, root, 400)
	blip:setDisplayText("Parkhaus", BLIP_CATEGORY.VehicleMaintenance)
	blip:setOptionalColor({0, 83, 135})
	local col = createColCuboid(2069.40, 886.28, 3388.49, 2169.50-2086.40+20, 964.03-886.28, 12)
	col:setInterior(9)
	ParkGarageZone:new(col)
end

function Townhall:destructor()
	delete(self.m_EnterExit)
	delete(self.m_Blip)
end
