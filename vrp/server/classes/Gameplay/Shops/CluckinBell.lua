-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/CluckinBell.lua
-- *  PURPOSE:     CluckinBell Class
-- *
-- ****************************************************************************
CluckinBell = inherit(Shop)

function CluckinBell:constructor(id, position, typeData, dimension, robable)
	local interior, intPosition = unpack(typeData["Interior"])
	local pedSkin, pedPosition, pedRotation = unpack(typeData["Ped"])

	InteriorEnterExit:new(position, intPosition, 0, 0, interior, dimension)
	if robable == 1 then
		RobableShop:new(pedPosition, pedRotation, pedSkin, interior, dimension)
	else
		createPed(pedSkin, pedPosition, pedRotation)
	end
	self.m_Marker = createMarker(typeData["Marker"], "cylinder", 1, 255, 255, 0, 200)
	self.m_Marker:setInterior(interior)
	self.m_Marker:setDimension(dimension)
	self.m_Type = "CluckinBell"
	self.m_Menues = {
		["Small"] = {["Name"] = "Kleines Menü", ["Price"] = 30, ["Health"] = 30},
		["Middle"] = {["Name"] = "Mittleres Menü", ["Price"] = 50, ["Health"] = 50},
		["Big"] = {["Name"] = "Großes Menü", ["Price"] = 80, ["Health"] = 80},
		["Healthy"] = {["Name"] = "Vegetarier Menü", ["Price"] = 50, ["Health"] = 50}
	}

	addEventHandler("onMarkerHit", self.m_Marker, bind(self.onFoodMarkerHit, self))
end
