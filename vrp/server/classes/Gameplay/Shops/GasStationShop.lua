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
		--outputDebugString("Shoperror: Gas-Station Data for "..self.m_Id.." not found!")
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

--[[
    <object id="object (washgaspump) (7)" breakable="true" interior="0" collisions="true" alpha="255" model="1676" doublesided="false" scale="1" dimension="0" posX="2370.3" posY="-2557.2" posZ="2.51" rotX="0" rotY="0" rotZ="270"></object>

    <object id="object (washgaspump) (8)" breakable="true" interior="0" collisions="true" alpha="255" model="1676" doublesided="false" scale="1" dimension="0" posX="1941.7001" posY="-1776.6" posZ="14.17" rotX="0" rotY="0" rotZ="90"></object>

    <object id="object (washgaspump) (9)" breakable="true" interior="0" collisions="true" alpha="255" model="1676" doublesided="false" scale="1" dimension="0" posX="1941.7001" posY="-1769.4" posZ="14.17" rotX="0" rotY="0" rotZ="90"></object>

    <object id="object (washgaspump) (1)" breakable="true" interior="0" collisions="true" alpha="255" model="1676" doublesided="false" scale="1" dimension="0" posX="-96.90039" posY="-1173.4004" posZ="3" rotX="0" rotY="0" rotZ="68"></object>

    <object id="object (washgaspump) (2)" breakable="true" interior="0" collisions="true" alpha="255" model="1676" doublesided="false" scale="1" dimension="0" posX="-92.15039" posY="-1162.2002" posZ="2.97" rotX="0" rotY="0" rotZ="245.995"></object>

    <object id="object (washgaspump) (3)" breakable="true" interior="0" collisions="true" alpha="255" model="1676" doublesided="false" scale="1" dimension="0" posX="-85.5" posY="-1165.1" posZ="2.8" rotX="0" rotY="0" rotZ="247.995"></object>

    <object id="object (washgaspump) (4)" breakable="true" interior="0" collisions="true" alpha="255" model="1676" doublesided="false" scale="1" dimension="0" posX="-90.1" posY="-1176.1" posZ="2.75" rotX="0" rotY="0" rotZ="245.994"></object>
 ]]
