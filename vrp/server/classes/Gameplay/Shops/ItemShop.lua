-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/Itemshop.lua
-- *  PURPOSE:     Item shop class
-- *
-- ****************************************************************************
ItemShop = inherit(Shop)

function ItemShop:constructor(id, name, position, rotation, typeData, dimension, robable, money, lastRob, owner, price, ownerType)
	self:create(id, name, position, rotation, typeData, dimension, robable, money, lastRob, owner, price, ownerType)

	self.m_Type = "ItemShop"
	self.m_Items = SHOP_ITEMS[typeData["Name"]]

	if self.m_Marker then
		addEventHandler("onMarkerHit", self.m_Marker, bind(self.onItemMarkerHit, self))
	end

end
