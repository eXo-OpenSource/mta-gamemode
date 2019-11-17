-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/FactionInterior.lua
-- *  PURPOSE:     Manages Faction Interiors
-- *
-- ****************************************************************************
FactionInterior = inherit(Object)

function FactionInterior:constructor(faction)
	self.m_Id = faction:getId()
	self.m_Faction = faction 

	self.m_Teleporter = InteriorEnterExit:new(evilFactionInteriorEnter[self.m_Id], Vector3(2807.32, -1173.92, 1025.57), 0, 0, 8, DYNAMIC_INTERIOR_DUMMY_DIMENSION)
	
	self.m_Teleporter:addEnterEvent(bind(self.onEnter, self))
	self.m_Teleporter:addExitEvent(bind(self.onExit, self))

	InteriorLoadManager.add(INTERIOR_OWNER_TYPES.FACTION, self.m_Id, bind(self.onInteriorLoad, self))

	if INTERIOR_MIGRATION then 
		self:assignInterior()
	end
end

function FactionInterior:assignInterior() 
	local path = ("%s/faction/default.map"):format(STATIC_INTERIOR_MAP_PATH)
	local instance = Interior:new(InteriorMapManager:getSingleton():getByPath(path, true,  DYANMIC_INTERIOR_PLACE_MODES.KEEP_POSITION))
			:setTemporary(false)
			:setOwner(INTERIOR_OWNER_TYPES.FACTION, self.m_Id)
			:forceSave()
	CustomInteriorManager:getSingleton():add(instance)
	self.m_InteriorId = instance:getId()
	return self
end

function FactionInterior:onInteriorCreate()
	self.m_Teleporter.m_ExitMarker:setInterior(self.m_Interior:getInterior())
	self.m_Teleporter.m_ExitMarker:setDimension(self.m_Interior:getDimension())
	self.m_Teleporter.m_ExitMarker:setPosition(self.m_Interior:getPosition())
	self.m_Teleporter.m_ExitMarker:setColor(0, 0, 0, 0)
	if isValidElement(self.m_Teleporter.ExitPickup) then 
		self.m_Teleporter.ExitPickup:destroy()
	end
	self.m_Teleporter.ExitPickup = Pickup(self.m_Interior:getPosition(), 3, 1318, 0)
	self.m_Teleporter.ExitPickup:setInterior(self.m_Interior:getInterior())
	self.m_Teleporter.ExitPickup:setDimension(self.m_Interior:getDimension())
	self:clean()
	self:parse()
end

function FactionInterior:onInteriorLoad(instance) 
	self.m_Interior = instance 
	self.m_Teleporter:setInterior(instance)
	self.m_Interior:setExit(self.m_Teleporter.m_EnterMarker:getPosition(), self.m_Teleporter.m_EnterMarker:getInterior(), self.m_Teleporter.m_EnterMarker:getDimension())
	self.m_Interior:setCreateCallback(bind(self.onInteriorCreate, self))
end

function FactionInterior:onEnter(player, teleporter) 
	if not self.m_Interior then 
		CustomInteriorManager:getSingleton():loadFromOwner(INTERIOR_OWNER_TYPES.FACTION, self.m_Id)
		return teleporter:enter(player)
	end
end

function FactionInterior:onExit(player, teleporter) 
	if not self.m_Interior then 
		CustomInteriorManager:getSingleton():loadFromOwner(INTERIOR_OWNER_TYPES.FACTION, self.m_Id)
		return teleporter:exit(player)	
	end
end

function FactionInterior:clean() 
	if isValidElement(self.m_Safe) then 
		self.m_Safe:destroy() 
	end
	if isValidElement(self.m_EquipmentDepot) then 
		self.m_EquipmentDepot:destroy() 
	end
	if isValidElement(self.m_ItemDepot) then 
		self.m_ItemDepot:destroy() 
	end
	if isValidElement(self.m_Ped) then 
		self.m_Ped:destroy()
	end
end

function FactionInterior:parse() 
	if self.m_Interior then 
		if self.m_Interior:getMapNode() then 
			if self.m_Interior:getMapNode():getData() then 
				self.m_Interior:setMapNode(MapParser:new(self.m_Interior:getMap():getPath())) -- we need to clone the map-data for the following operation
				local removeIds = {}
				for index, data in ipairs(self.m_Interior:getMapNode():getData()) do
					if data.type == "ped" then 
						self.m_Ped = NPC:new(FactionManager:getFromId(self.m_Id):getRandomSkin(), data.x, data.y, data.z, data.rz)
						self.m_Ped:setInterior(data.interior)
						self.m_Ped:setFrozen(true)
						self.m_Ped:setImmortal(true)
						self.m_Ped:setDimension(self.m_Interior:getDimension())
						self.m_Ped:setData("clickable", true, true)
						self.m_Ped.Faction = self.m_Faction
						self.m_Ped.Info = ElementInfo:new(self.m_Ped, "Waffenlager")
						addEventHandler("onElementClicked", self.m_Ped, bind(FactionEvil.onWeaponPedClicked, FactionEvil:getSingleton()))
					else 
						if data.model == FACTION_INTERIOR_ITEM_DEPOT_MODEL then
							self.m_ItemDepot = createObject(FACTION_INTERIOR_ITEM_DEPOT_MODEL, data.x, data.y, data.z, data.rx, data.ry, data.rz)
							self.m_ItemDepot:setInterior(data.interior)
							self.m_ItemDepot:setDimension(self.m_Interior:getDimension())
							self.m_ItemDepot.Faction = self.m_Faction
							self.m_ItemDepot:setData("clickable", true, true)
							addEventHandler("onElementClicked", self.m_ItemDepot, bind(FactionEvil.onDepotClicked, FactionEvil:getSingleton()))
							self.m_ItemDepot.Info = ElementInfo:new(self.m_ItemDepot, "Itemlager")
						elseif data.model == FACTION_INTERIOR_EQUIPMENT_MODEL then
							self.m_EquipmentDepot = createObject(FACTION_INTERIOR_EQUIPMENT_MODEL, data.x, data.y, data.z, data.rx, data.ry, data.rz)
							self.m_EquipmentDepot:setInterior(data.interior)
							self.m_EquipmentDepot:setDimension(self.m_Interior:getDimension())
							self.m_EquipmentDepot.Faction = self.m_Faction
							self.m_EquipmentDepot:setData("clickable", true, true)
							addEventHandler("onElementClicked", self.m_EquipmentDepot, bind(FactionEvil.onEquipmentDepotClicked, FactionEvil:getSingleton()))
							self.m_EquipmentDepot.Info = ElementInfo:new(self.m_EquipmentDepot, "Ausrüstungslager")

						elseif data.model == FACTION_INTERIOR_SAFE_MODEL then
							self.m_Safe = createObject(FACTION_INTERIOR_SAFE_MODEL, data.x, data.y, data.z, data.rx, data.ry, data.rz)
							self.m_Safe:setInterior(data.interior)
							self.m_Safe:setDimension(self.m_Interior:getDimension())
							self.m_Faction:setSafe(self.m_Safe)
						end 
					end
				end
				for i = 1, 4 do
					for index, data in pairs(self.m_Interior:getMapNode():getData()) do 
						if data.type == "ped" then 
							table.remove(self.m_Interior:getMapNode():getData(), index)
						else
							if data.model == FACTION_INTERIOR_ITEM_DEPOT_MODEL or data.model == FACTION_INTERIOR_EQUIPMENT_MODEL or data.model == FACTION_INTERIOR_SAFE_MODEL then 
								table.remove(self.m_Interior:getMapNode():getData(), index)
							end
						end
					end
				end
			end
		end
	end
end

function FactionInterior:destructor() 

end


