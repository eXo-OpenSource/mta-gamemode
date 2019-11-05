-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/RustyBrown.lua
-- *  PURPOSE:     RustyBrown Class
-- *
-- ****************************************************************************
RustyBrown = inherit(Shop)

function RustyBrown:constructor(id, name, position, rotation, typeData, dimension, robable, money, lastRob, owner, price, ownerType, interior)
	self:create(id, name, position, rotation, typeData, dimension, robable, money, lastRob, owner, price, ownerType, interior)

	self.m_Type = "RustyBrown"
	self.m_Menues = {
		["Small"] = {["Name"] = "Kleines Menü", ["Price"] = 30, ["Health"] = 30},
		["Middle"] = {["Name"] = "Mittleres Menü", ["Price"] = 50, ["Health"] = 50},
		["Big"] = {["Name"] = "Großes Menü", ["Price"] = 80, ["Health"] = 80}
	}
	self.m_Items = {
		["Donutbox"] = 75,
		["Donut"] = 9
	}

	addEventHandler("onMarkerHit", self.m_Marker, bind(self.onFoodMarkerHit, self))

	if self.m_Ped then
		self.m_Ped:setData("clickable",true,true)
		addEventHandler("onElementClicked", self.m_Ped, function(button, state, player)
			if button =="left" and state == "down" then
				self:onFoodMarkerHit(player, true)
			end
		end)
	end
end
