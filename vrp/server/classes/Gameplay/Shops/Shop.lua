-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Shops/Shop.lua
-- *  PURPOSE:     Shop Super Class
-- *
-- ****************************************************************************
Shop = inherit(Object)

function Shop:constructor()

end

function Shop:create(id, name, position, rotation, typeData, dimension, robable, money, lastRob, owner, price)
	self.m_Id = id
	self.m_Name = name
	self.m_BuyAble = price > 0 and true or false
	self.m_Price = price
	self.m_LastRob = lastRob
	self.m_OwnerId = owner
	self.m_Money = money
	self.m_Position = position or nil

	local interior, intPosition = unpack(typeData["Interior"])

	self.m_Interior = interior
	self.m_Dimension = dimension

	if interior > 0 then
		InteriorEnterExit:new(position, intPosition, 0, rotation, interior, dimension)
	end

	if typeData["Ped"] then
		local pedSkin, pedPosition, pedRotation = unpack(typeData["Ped"])

		if robable == 1 then
			RobableShop:new(self, pedPosition, pedRotation, pedSkin, interior, dimension)
		else
			local ped = createPed(pedSkin, pedPosition, pedRotation)
			ped:setInterior(interior)
			ped:setDimension(dimension)
		end
	end

	if typeData["Marker"] then
		self.m_Marker = createMarker(typeData["Marker"], "cylinder", 1, 255, 255, 0, 200)
		self.m_Marker:setInterior(interior)
		self.m_Marker:setDimension(dimension)
	end
end

function Shop:onFoodMarkerHit(hitElement, dim)
	if dim and hitElement:getType() == "player" then
		if not self.m_Marker.m_Disable then
			hitElement:triggerEvent("showFoodShopMenu")
			triggerClientEvent(hitElement, "refreshFoodShopMenu", hitElement, self.m_Id, self.m_Type, self.m_Menues, self.m_Items)
		end
	end
end

function Shop:onItemMarkerHit(hitElement, dim)
	if dim and hitElement:getType() == "player" then
		if self.m_Marker then
			if not self.m_Marker.m_Disable then
				hitElement:triggerEvent("showItemShopGUI")
				triggerClientEvent(hitElement, "refreshItemShopGUI", hitElement, self.m_Id, self.m_Items)
			end
		else
			hitElement:triggerEvent("showItemShopGUI")
			triggerClientEvent(hitElement, "refreshItemShopGUI", hitElement, self.m_Id, self.m_Items)
		end
	end
end

function Shop:getName()
	return self.m_Name
end

function Shop:addBlip(blip)
	return Blip:new(blip, self.m_Position.x, self.m_Position.y,root, 600)
end

function Shop:giveMoney(amount, reason)
	if amount > 0 then self.m_Money = self.m_Money + amount end
end

function Shop:takeMoney(amount, reason)
	if amount > 0 then self.m_Money = self.m_Money - amount end
end

function Shop:getMoney()
	return self.m_Money
end

function Shop:save()
	if sql:queryExec("UPDATE ??_shops SET Money = ?, LastRob = ?, Owner = ? WHERE Id = ?", sql:getPrefix(), self.m_Money, self.m_LastRob, self.m_Owner, self.m_Id) then
	else
		outputDebug(("Failed to save Shop '%s' (Id: %d)"):format(self.m_Name, self.m_Id))
	end
end
