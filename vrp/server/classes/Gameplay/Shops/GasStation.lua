-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/GasStation.lua
-- *  PURPOSE:     Gas Station Shop class
-- *
-- ****************************************************************************
GasStation = inherit(Shop)

function GasStation:constructor(id, name, position, rotation, typeData, dimension, robable, money, lastRob, owner, price, ownerType)
	self:create(id, name, position, rotation, typeData, dimension, robable, money, lastRob, owner, price, ownerType)

	self.m_Type = "ItemShop"
	self.m_Items = SHOP_ITEMS[typeData["Name"]]

	if self.m_Marker then
		addEventHandler("onMarkerHit", self.m_Marker, bind(self.onItemMarkerHit, self))
	end

	if SHOP_FUEL[self.m_Name] then
		local pos = SHOP_FUEL[self.m_Name]["Marker"]
		self.m_GasBlip = Blip:new("Fuelstation.png", pos.x, pos.y, root, 300)
		self.m_FillMarker = createMarker(pos, "cylinder", 5, 255, 255, 0, 100)
		addEventHandler("onMarkerHit", self.m_FillMarker, bind(self.onFillMarkerHit, self))
		addEventHandler("onMarkerLeave", self.m_FillMarker, bind(self.onFillMarkerLeave, self))

		local x, y, z, rot = unpack(SHOP_FUEL[self.m_Name]["FuelStation"])
		self.m_GasStation = createObject(1676, x, y, z,0,0, rot)
		--self.m_GasStation:setCollisionsEnabled(false)
	else
		outputDebugString("Shoperror: Gas-Station Data for "..self.m_Id.." not found!")
	end

end

function GasStation:getFuelStation()
	return self.m_GasStation
end

function GasStation:onFillMarkerHit(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension and getPedOccupiedVehicleSeat(hitElement) == 0 then
		hitElement:triggerEvent("gasStationStart", self.m_Id)
	end
end

function GasStation:onFillMarkerLeave(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension then
		hitElement:triggerEvent("gasStationReset")
	end
end

