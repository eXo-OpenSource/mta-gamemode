-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/PizzaStack.lua
-- *  PURPOSE:     PizzaStack Class
-- *
-- ****************************************************************************
PizzaStack = inherit(Shop)

function PizzaStack:constructor(id, name, position, typeData, dimension, robable, money, lastRob, owner, price)
	self:create(id, name, position, typeData, dimension, robable, money, lastRob, owner, price)

	self.m_Type = "PizzaStack"
	self.m_Menues = {
		["Small"] = {["Name"] = "Kleines Menü", ["Price"] = 30, ["Health"] = 30},
		["Middle"] = {["Name"] = "Mittleres Menü", ["Price"] = 50, ["Health"] = 50},
		["Big"] = {["Name"] = "Großes Menü", ["Price"] = 80, ["Health"] = 80},
		["Healthy"] = {["Name"] = "Vegetarier Menü", ["Price"] = 50, ["Health"] = 50}
	}
	self.m_Items = {}

	addEventHandler("onMarkerHit", self.m_Marker, bind(self.onFoodMarkerHit, self))
end
