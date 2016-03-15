-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/RustyBrown.lua
-- *  PURPOSE:     RustyBrown Class
-- *
-- ****************************************************************************
RustyBrown = inherit(FoodShop)

function RustyBrown:constructor(dimension)
	self.m_Marker = createMarker(Vector3(379.34, -190.71, 999.9), "cylinder", 1, 255, 255, 0, 200)
	self.m_Marker:setInterior(17)
	self.m_Marker:setDimension(dimension)
	self.m_Type = "RustyBrown"
	self.m_Menues = {
		["Small"] = {["Name"] = "Kleines Menü", ["Price"] = 30, ["Health"] = 30},
		["Middle"] = {["Name"] = "Mittleres Menü", ["Price"] = 50, ["Health"] = 50},
		["Big"] = {["Name"] = "Großes Menü", ["Price"] = 80, ["Health"] = 80}
	}

	addEventHandler("onMarkerHit", self.m_Marker, bind(self.onFoodMarkerHit, self))

end
