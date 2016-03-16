-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/RustyBrown.lua
-- *  PURPOSE:     RustyBrown Class
-- *
-- ****************************************************************************
RustyBrown = inherit(Shop)

function RustyBrown:constructor(id, name, position, typeData, dimension, robable, money, lastRob, owner, price)
	self:create(id, name, position, typeData, dimension, robable, money, lastRob, owner, price)

	self.m_Type = "RustyBrown"
	self.m_Menues = {
		["Small"] = {["Name"] = "Kleines Menü", ["Price"] = 30, ["Health"] = 30},
		["Middle"] = {["Name"] = "Mittleres Menü", ["Price"] = 50, ["Health"] = 50},
		["Big"] = {["Name"] = "Großes Menü", ["Price"] = 80, ["Health"] = 80}
	}
	self.m_Items = {}

	addEventHandler("onMarkerHit", self.m_Marker, bind(self.onFoodMarkerHit, self))

end
