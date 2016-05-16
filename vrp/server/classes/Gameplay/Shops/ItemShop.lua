-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/Itemshop.lua
-- *  PURPOSE:     Item shop class
-- *
-- ****************************************************************************
ItemShop = inherit(Shop)

function ItemShop:constructor(id, name, position, rotation, typeData, dimension, robable, money, lastRob, owner, price)
	self:create(id, name, position, rotation, typeData, dimension, robable, money, lastRob, owner, price)

	self.m_Type = "ItemShop"
	self.m_Items = {
		["Radio"] = 2000,
		["Zigaretten"] = 10,
		["Wuerfel"] = 10,
		["Kanne"] = 500
	}

	addEventHandler("onMarkerHit", self.m_Marker, bind(self.onItemMarkerHit, self))


end
