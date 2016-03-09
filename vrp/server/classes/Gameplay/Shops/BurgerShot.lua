-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/BurgerShot.lua
-- *  PURPOSE:     BurgerShot Class
-- *
-- ****************************************************************************
BurgerShot = inherit(FoodShop)

function BurgerShot:constructor(dimension)
	self.m_Marker = createMarker(Vector3(376.60, -68.03, 1000.8), "cylinder", 1, 255, 255, 0, 200)
	self.m_Marker:setInterior(10)
	self.m_Marker:setDimension(dimension)
	self.m_Type = "BurgerShot"
	self.m_Menues = {
		["Small"] = {["Name"] = "Kleines Menü", ["Price"] = 80, ["Health"] = 80},
		["Middle"] = {["Name"] = "Mittleres Menü", ["Price"] = 50, ["Health"] = 50},
		["Big"] = {["Name"] = "Großes Menü", ["Price"] = 30, ["Health"] = 30},
		["Healthy"] = {["Name"] = "Vegetarier Menü", ["Price"] = 50, ["Health"] = 50}
	}

	addEventHandler("onMarkerHit", self.m_Marker, bind(self.onFoodMarkerHit, self))
end
