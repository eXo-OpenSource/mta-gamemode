-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/GasStationShop.lua
-- *  PURPOSE:     Gas Station Shop class
-- *
-- ****************************************************************************
GasStationShop = inherit(Shop)

function GasStationShop:constructor(id, name, position, rotation, typeData, dimension, robable, money, lastRob, owner, price, ownerType)
	self:create(id, name, position, rotation, typeData, dimension, robable, money, lastRob, owner, price, ownerType)

	self.m_Type = "ItemShop"
	self.m_Items = SHOP_ITEMS[typeData["Name"]]

	if self.m_Marker then
		addEventHandler("onMarkerHit", self.m_Marker, bind(self.onGasStationMarkerHit, self))
	end

	if GasStationManager.Shops[self.m_Name] then
		GasStationManager.Shops[self.m_Name]:addShopRef(self)
		self.m_GasBlip = Blip:new("Fuelstation.png", position.x, position.y, root, 300):setDisplayText("Tankstelle", BLIP_CATEGORY.VehicleMaintenance):setOptionalColor({0, 150, 136})
	else
		outputConsole(("Shop: Gas-Station Data for %s: %s not found!"):format(tostring(self.m_Id), tostring(self.m_Name)))
	end
end

function GasStationShop:onFillMarkerHit(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension and getPedOccupiedVehicleSeat(hitElement) == 0 then
		hitElement:triggerEvent("gasStationStart", self.m_Id)
	end
end

function GasStationShop:onFillMarkerLeave(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension then
		hitElement:triggerEvent("gasStationReset")
	end
end
