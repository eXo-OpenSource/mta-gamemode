-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/BarShop.lua
-- *  PURPOSE:     BarShop Class
-- *
-- ****************************************************************************
BarShop = inherit(Shop)

function BarShop:constructor(id, name, position, rotation, typeData, dimension, robable, money, lastRob, owner, price)
	self:create(id, name, position, rotation, typeData, dimension, robable, money, lastRob, owner, price)

	self.m_Type = "Bar"
	self.m_Items = SHOP_ITEMS["Bar"]
	if self.m_Marker then
		addEventHandler("onMarkerHit", self.m_Marker, bind(self.onBarMarkerHit, self))
	end

end

function BarShop:onBarMarkerHit(hitElement, dim)
	if dim and hitElement:getType() == "player" then
		if self.m_Marker then
			if not self.m_Marker.m_Disable then
				hitElement:triggerEvent("showBarGUI")
				triggerClientEvent(hitElement, "refreshItemShopGUI", hitElement, self.m_Id, self.m_Items)
			end
		else
			hitElement:triggerEvent("showBarGUI")
			triggerClientEvent(hitElement, "refreshItemShopGUI", hitElement, self.m_Id, self.m_Items)
		end
	end
end
