-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/CluckinBell.lua
-- *  PURPOSE:     CluckinBell Class
-- *
-- ****************************************************************************
CluckinBell = inherit(Shop)

function CluckinBell:constructor(id, position, typeData, dimension, robable)
	self:createShop(id, position, typeData, dimension, robable)

	self.m_Type = "CluckinBell"
	self.m_Menues = {
		["Small"] = {["Name"] = "Kleines Menü", ["Price"] = 30, ["Health"] = 30},
		["Middle"] = {["Name"] = "Mittleres Menü", ["Price"] = 50, ["Health"] = 50},
		["Big"] = {["Name"] = "Großes Menü", ["Price"] = 80, ["Health"] = 80},
		["Healthy"] = {["Name"] = "Vegetarier Menü", ["Price"] = 50, ["Health"] = 50}
	}
	self.m_Items = {}

	addEventHandler("onMarkerHit", self.m_Marker, bind(self.onFoodMarkerHit, self))
end
