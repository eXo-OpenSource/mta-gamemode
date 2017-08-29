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

function Shop:create(id, name, position, rotation, typeData, dimension, robable, money, lastRob, owner, price, ownerType)
	self.m_Id = id
	self.m_Name = name
	self.m_BuyAble = price > 0 and true or false
	self.m_Price = price
	self.m_LastRob = lastRob
	self.m_OwnerId = owner
	self.m_OwnerType = ownerType or 0
	self.m_Money = money
	self.m_Position = position or nil
	self.m_TypeName = "Shop"
	self.m_TypeDataName = typeData["Name"]


	self.m_ShopGUIBind = bind(self.openManageGUI, self)

	if self.m_BuyAble == true and self.m_OwnerId > 0 then
		self:loadOwner()
	end

	local interior, intPosition = unpack(typeData["Interior"])

	self.m_Interior = interior
	self.m_Dimension = dimension

	if interior > 0 then
		local teleporter = InteriorEnterExit:new(position, intPosition, 0, rotation, interior, dimension)
		teleporter:addEnterEvent(bind(self.onEnter, self))
		teleporter:addExitEvent(bind(self.onExit, self))
	else
		if self.m_BuyAble then
			self.m_Colshape = createColSphere(self.m_Position, 3)
			addEventHandler("onColShapeHit", self.m_Colshape, function(hitElement, dim)
				if hitElement:getType() == "player" and dim then
					self:onEnter(hitElement)
				end
			end)
			addEventHandler("onColShapeLeave", self.m_Colshape, function(hitElement, dim)
				if hitElement:getType() == "player" and dim then
					self:onExit(hitElement)
				end
			end)
		end
	end

	if typeData["Ped"] then
		local pedSkin, pedPosition, pedRotation = unpack(typeData["Ped"])

		if robable == 1 then
			RobableShop:new(self, pedPosition, pedRotation, pedSkin, interior, dimension)
		else
			self.m_NPC = NPC:new(pedSkin, pedPosition.x, pedPosition.y, pedPosition.z, pedRotation)
			self.m_NPC:setImmortal(true)
			self.m_NPC:setInterior(interior)
			self.m_NPC:setDimension(dimension)
		end
	end

	if typeData["Marker"] then
		self.m_Marker = createMarker(typeData["Marker"], "cylinder", 1, 255, 255, 0, 175)
		self.m_Marker:setInterior(interior)
		self.m_Marker:setDimension(dimension)
	end
end

function Shop:loadOwner()
	if self.m_OwnerType == SHOP_OWNER_TYPES.Group then
		local group = GroupManager:getSingleton():getFromId(self.m_OwnerId)
		if group then
			self.m_Owner = group

			-- Add ref to group
			group:addShop(self)
		end
	else
		self.m_Owner:removeShop(self)
		self.m_Owner = nil
	end
end

function Shop:onEnter(player)
	if self.m_BuyAble then
		player:sendInfo(_("Drücke 'F6' um das %s-Menü zu öffnen!", player, self.m_TypeName))
		bindKey(player, "f6", "down", self.m_ShopGUIBind)
	end
	if self.onShopEnter then self:onShopEnter(player) end
end

function Shop:onExit(player)
	if self.m_BuyAble then
		unbindKey(player, "f6", "down", self.m_ShopGUIBind)
		player:triggerEvent("shopCloseManageGUI")
		player:triggerEvent("shopCloseGUI")
	end
	if self.onShopExit then self:onShopExit(player) end
end

function Shop:openManageGUI(player)
	if player:getInterior() >= 0 or player:getDimension() >= 0 then
		player:triggerEvent("shopOpenManageGUI", self.m_Id, self.m_Name, self.m_TypeName, self.m_OwnerId, self:getOwnerName(), self.m_Price, self.m_SoundUrl, self.m_StripperEnabled)
	else
		unbindKey(player, "f6", "down", self.m_ShopGUIBind)
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

function Shop:onGasStationMarkerHit(hitElement, dim)
	if dim and hitElement:getType() == "player" then
		if not self.m_Marker.m_Disable then
			hitElement:triggerEvent("showGasStationShopGUI", self.m_Name)
			triggerClientEvent(hitElement, "refreshGasStationShopGUI", hitElement, self.m_Id, self.m_Items)
		end
	end
end

function Shop:getName()
	return self.m_Name
end

function Shop:getId()
	return self.m_Id
end

function Shop:isManageAllowed(player)
	if self.m_OwnerType == SHOP_OWNER_TYPES.Group then
		if player:getGroup() and player:getGroup() == self.m_Owner then
			local group = player:getGroup()
			if group:getPlayerRank(player) >= GroupRank.Manager then
				return true
			end
		end
	end
	return false
end

function Shop:isOwnerMember(player)
	if self.m_OwnerType == SHOP_OWNER_TYPES.Group then
		if player:getGroup() and player:getGroup() == self.m_Owner then
			return true
		end
	end
	return false
end

function Shop:buy(player)
	if self.m_BuyAble == true and self.m_OwnerId == 0 then
		if self.m_OwnerType == SHOP_OWNER_TYPES.Group then
			if player:getGroup() and player:getGroup():getType() == "Firma" then
				local group = player:getGroup()
				if group:getPlayerRank(player) >= GroupRank.Manager then
					if group:getMoney() >= self.m_Price then
						group:takeMoney(self.m_Price, "Shop-Kauf")
						group:sendMessage(_("[FIRMA] %s hat den Shop '%s' für %d$ gekauft!", player, player:getName(), self.m_Name, self.m_Price), 0, 255, 0)
						group:addLog(player, "Immobilien", _("hat den Shop '%s' für %d$ gekauft!", player, self.m_Name, self.m_Price))
						self.m_OwnerId = group:getId()
						self:loadOwner()
						self:save()
					else
						player:sendError(_("In der Firmenkasse ist nicht genug Geld! (%d$)", player, self.m_Price))
					end
				else
					player:sendError(_("Nur Leader und Co-Leader deiner Firma können den Shop kaufen!", player))
				end
			else
				player:sendError(_("Du bist in keiner privaten Firma!", player))
			end
		else
			player:sendError(_("Dieser Shop kann nur von privaten Firmen gekauft werden!", player))
		end
	else
		player:sendError(_("Dieser Shop kann nicht gekauft werden!", player))
	end
end

function Shop:sell(player)
	if self.m_OwnerType == SHOP_OWNER_TYPES.Group then
		if player:getGroup() and player:getGroup() == self.m_Owner then
			local group = player:getGroup()
			if group:getPlayerRank(player) >= GroupRank.Manager then
				local money = math.floor((self.m_Price*0.75))
				group:giveMoney(money, "Shop-Verkauf")
				group:sendMessage(_("[FIRMA] %s hat den Shop '%s' für %d$ verkauft!", player, player:getName(), self.m_Name, money), 255, 0, 0)
				group:addLog(player, "Immobilien", _("hat den Shop '%s' für %d$ verkauft!", player, self.m_Name, money))
				self.m_OwnerId = 0
				self:loadOwner()
				self:save()
			else
				player:sendError(_("Nur Leader und Co-Leader deiner Firma können den Shop verkaufen!", player))
			end
		else
			player:sendError(_("Dieser Shop gehört nicht deiner Firma!", player))
		end
	end
end

function Shop:getOwnerName()
	if self.m_Owner then
		return self.m_Owner:getName()
	end
	return "Keiner"
end


function Shop:addBlip(blip)
	local b = Blip:new(blip, self.m_Position.x, self.m_Position.y, root, 600)
	if blip == "Bar.png" then
		b:setDisplayText("Bar / Club", BLIP_CATEGORY.Leisure)
		b:setOptionalColor({245, 160, 199})
	else
		b:setDisplayText(self.m_TypeDataName, BLIP_CATEGORY.Shop)
	end
	return b
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

function Shop:openBankGui(player)
	player:triggerEvent("bankAccountGUIShow", self:getName(), "shopBankDeposit", "shopBankWithdraw", self.m_Id)
	self:refreshBankGui(player)
end

function Shop:refreshBankGui(player)
	player:triggerEvent("bankAccountGUIRefresh", self:getMoney())
end

function Shop:save()
	if sql:queryExec("UPDATE ??_shops SET Money = ?, LastRob = ?, Owner = ? WHERE Id = ?", sql:getPrefix(), self.m_Money, self.m_LastRob, self.m_OwnerId, self.m_Id) then
	else
		outputDebug(("Failed to save Shop '%s' (Id: %d)"):format(self.m_Name, self.m_Id))
	end
end
