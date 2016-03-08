-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/PizzaStack.lua
-- *  PURPOSE:     PizzaStack Class
-- *
-- ****************************************************************************
PizzaStack = inherit(FoodShop)

function PizzaStack:constructor(pos, dimension, interior)
	self.m_Marker = createMarker(pos, "cylinder", 1, 255, 255, 0, 200)
	self.m_Marker:setInterior(interior)
	self.m_Marker:setDimension(dimension)
	self.m_Type = "PizzaStack"
	self.m_Menues = {
		["Small"] = {["Name"] = "Kleines Menü", ["Price"] = 80, ["Health"] = 80},
		["Middle"] = {["Name"] = "Mittleres Menü", ["Price"] = 50, ["Health"] = 50},
		["Big"] = {["Name"] = "Großes Menü", ["Price"] = 30, ["Health"] = 30},
		["Healthy"] = {["Name"] = "Vegetarier Menü", ["Price"] = 50, ["Health"] = 50}
	}
	self.m_Items = {["Burger"] = 50}

	addEventHandler("onMarkerHit", self.m_Marker, bind(self.onFoodMarkerHit, self))

end
