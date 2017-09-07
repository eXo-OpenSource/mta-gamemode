-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/FactionWeaponShopGUI.lua
-- *  PURPOSE:     Faction Weapon Shop GUI class
-- *
-- ****************************************************************************
FactionWeaponShopGUI = inherit(GUIForm)
inherit(Singleton, FactionWeaponShopGUI)

addRemoteEvents{"showFactionWeaponShopGUI","updateFactionWeaponShopGUI"}

function FactionWeaponShopGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-370, screenHeight/2-230, 740, 460)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Fraktions Waffenshop - "..localPlayer:getFaction():getShortName(), true, true, self)
	self.m_Window:deleteOnClose(true)
	self.m_Cart = {}

	self.m_WeaponArea = GUIScrollableArea:new(25, 35, 465, 400, 465, 0, true, false, self.m_Window, 35)

	self.m_WeaponsImage = {}
	self.m_WeaponsName = {}
	self.m_WeaponsMenge = {}
	self.m_WeaponsMunition = {}
	self.m_WeaponsBuyGun = {}
	self.m_WeaponsBuyMunition = {}
	self.m_WaffenAnzahl = 0
	self.m_WaffenRow = 0
	self.m_WaffenColumn = 0

	GUILabel:new(500, 35, 230, 35, "Warenkorb:", self.m_Window)
	self.m_CartGrid = GUIGridList:new(500, 70, 210, 350, self.m_Window)
	self.m_CartGrid:addColumn(_"Ware", 0.7)
	self.m_CartGrid:addColumn(_"Anzahl", 0.3)
	self.m_del = GUIButton:new(500, 425, 100, 25,_"Entfernen", self.m_Window)
	self.m_del:setBackgroundColor(Color.Red)
	self.m_del.onLeftClick = bind(self.deleteItemFromCart,self)
	self.m_buy = GUIButton:new(610, 425, 100, 25,_"Bestätigen", self.m_Window)
	self.m_buy.onLeftClick = bind(self.factionWeaponShopBuy,self)

	addEventHandler("updateFactionWeaponShopGUI", root, bind(self.Event_updateFactionWeaponShopGUI, self))

	self:getPlayerWeapons()
	self:factionReceiveWeaponShopInfos()
end

function FactionWeaponShopGUI:virtual_destructor()
	removeEventHandler("updateFactionWeaponShopGUI", root, bind(self.Event_updateFactionWeaponShopGUI, self))
	GUIForm.destructor(self)
end

--[[function FactionWeaponShopGUI:onShow()
	AntiClickSpam:getSingleton():setEnabled(false)
end

function FactionWeaponShopGUI:onHide()
	AntiClickSpam:getSingleton():setEnabled(true)
end]]

function FactionWeaponShopGUI:Event_updateFactionWeaponShopGUI(validWeapons, depotWeaponsMax, depotWeapons, rankWeapons)
	self.m_ValidWeapons = validWeapons
	self.m_SpecialWeapons = {}
	self.m_GUIWeapons = {}

	for k,v in pairs(self.m_ValidWeapons) do
		if v == true then
			self:addWeaponToGUI(k, depotWeapons[k]["Waffe"], depotWeapons[k]["Munition"])
		end
	end
	if localPlayer:getFaction():isEvilFaction() then
		for weaponId, data in pairs(depotWeapons) do
			if not self.m_WeaponsName[weaponId] and (data["Waffe"] > 0 or data["Munition"] > 0)  then
				self:addWeaponToGUI(weaponId, depotWeapons[weaponId]["Waffe"], depotWeapons[weaponId]["Munition"])
				self.m_SpecialWeapons[weaponId] = true
			end
		end
	end

	self.m_WeaponArea:resize(465, 155+self.m_WaffenColumn*200)
	self.rankWeapons = rankWeapons
	self.depot = depotWeapons
	self:updateButtons()
end

function FactionWeaponShopGUI:addWeaponToGUI(weaponID,Waffen,Munition)
	self.m_GUIWeapons[weaponID] = true
	self.m_WeaponsName[weaponID] = GUILabel:new(self.m_WaffenRow*120, self.m_WaffenColumn*200, 100, 25, WEAPON_NAMES[weaponID], self.m_WeaponArea)
	self.m_WeaponsName[weaponID]:setAlignX("center")
	self.m_WeaponsImage[weaponID] = GUIImage:new(20+self.m_WaffenRow*120, 35+self.m_WaffenColumn*200, 60, 60, WeaponIcons[weaponID], self.m_WeaponArea)
	self.m_WeaponsMenge[weaponID] = GUILabel:new(self.m_WaffenRow*120, 100+self.m_WaffenColumn*200, 100, 20, "Waffenlager: "..Waffen, self.m_WeaponArea)
	self.m_WeaponsMenge[weaponID]:setAlignX("center")
	self.m_WeaponsMunition[weaponID] = GUILabel:new(self.m_WaffenRow*120, 115+self.m_WaffenColumn*200, 100, 20, "Magazine: "..Munition, self.m_WeaponArea)
	self.m_WeaponsMunition[weaponID]:setAlignX("center")
	self.m_WeaponsBuyGun[weaponID] = GUIButton:new(self.m_WaffenRow*120, 135+self.m_WaffenColumn*200, 100, 20,"+ Waffe", self.m_WeaponArea)
	self.m_WeaponsBuyGun[weaponID]:setBackgroundColor(Color.Red):setFontSize(1)
	self.m_WeaponsBuyGun[weaponID].onLeftClick = bind(self.addItemToCart,self,"weapon",weaponID)

	if weaponID >=22 and weaponID <= 43 then
		self.m_WeaponsBuyMunition[weaponID] = GUIButton:new(self.m_WaffenRow*120, 160+self.m_WaffenColumn*200, 100, 20,"+ Magazin", self.m_WeaponArea)
		self.m_WeaponsBuyMunition[weaponID]:setBackgroundColor(Color.Blue):setFontSize(1)
		self.m_WeaponsBuyMunition[weaponID].onLeftClick = bind(self.addItemToCart,self,"munition",weaponID)
		if not self.m_playerWeapons[weaponID] then
			self.m_WeaponsBuyMunition[weaponID]:setEnabled(false)
		end
	end

	if not(self.m_Cart[weaponID]) then
		self.m_Cart[weaponID] = {}
		self.m_Cart[weaponID]["Waffe"] = 0
		self.m_Cart[weaponID]["Munition"] = 0
	end

	self.m_WaffenAnzahl = self.m_WaffenAnzahl+1

	if self.m_WaffenAnzahl == 4 or self.m_WaffenAnzahl == 8 or self.m_WaffenAnzahl == 12 then
		self.m_WaffenRow = 0
		self.m_WaffenColumn = self.m_WaffenColumn+1
	else
		self.m_WaffenRow = self.m_WaffenRow+1
	end



end

function FactionWeaponShopGUI:updateButtons()
	for weaponID,v in pairs(self.m_GUIWeapons) do
		if v == true then
			local skip = false
			if (self.rankWeapons[tostring(weaponID)] == 1) or (self.m_SpecialWeapons[weaponID] and  self.rankWeapons[tostring(0)] == 1) then
				self.m_WeaponsBuyGun[weaponID]:setEnabled(true)
				if self.m_WeaponsBuyMunition[weaponID] then
					self.m_WeaponsBuyMunition[weaponID]:setEnabled(true)
				end
			else
				self.m_WeaponsBuyGun[weaponID]:setEnabled(false)
				if self.m_WeaponsBuyMunition[weaponID] then
					self.m_WeaponsBuyMunition[weaponID]:setEnabled(false)
				end
				skip = true
			end
			if not skip then
				if self.m_playerWeapons[weaponID] or self.m_Cart[weaponID]["Waffe"] > 0 then
					if self.m_WeaponsBuyMunition[weaponID] then
						self.m_WeaponsBuyMunition[weaponID]:setEnabled(true)
					end
					self.m_WeaponsBuyGun[weaponID]:setEnabled(false)
				else
					self.m_WeaponsBuyGun[weaponID]:setEnabled(true)
					if self.m_WeaponsBuyMunition[weaponID] then
						self.m_WeaponsBuyMunition[weaponID]:setEnabled(false)
						self.m_Cart[weaponID]["Munition"] = 0
					end
				end

				if self.depot[weaponID]["Waffe"]-self.m_Cart[weaponID]["Waffe"] <= 0 then
					self.m_WeaponsBuyGun[weaponID]:setEnabled(false)
				end

				if self.depot[weaponID]["Munition"]-self.m_Cart[weaponID]["Munition"] <= 0 then
					if self.m_WeaponsBuyMunition[weaponID] then
						self.m_WeaponsBuyMunition[weaponID]:setEnabled(false)
					end
				end
			end
		end
	end
	self:updateCart()
end

function FactionWeaponShopGUI:getPlayerWeapons()
	self.m_playerWeapons = {}
	for i=1, 12 do
		if getPedWeapon(localPlayer,i) > 0 then
			self.m_playerWeapons[getPedWeapon(localPlayer,i)] = true
		end
	end
end

function FactionWeaponShopGUI:updateCart()
	self.m_CartGrid:clear()
	local name,item
	for weaponID,v in pairs(self.m_Cart) do
		for typ,amount in pairs(self.m_Cart[weaponID]) do
			if amount > 0 then
				if typ == "Waffe" then
					name = WEAPON_NAMES[weaponID]
				elseif typ == "Munition" then
					name = WEAPON_NAMES[weaponID].." Magazin"
				end
				item = self.m_CartGrid:addItem(name,amount)
				item.typ = typ
				item.id = weaponID
			end
		end
	end
end

function FactionWeaponShopGUI:clearCart()
	for key, item in ipairs( self.m_CartGrid:getItems()) do
		self.m_Cart[item.id][item.typ] = self.m_Cart[item.id][item.typ]-1
		self:updateCart()
		self:updateButtons()
	end
	self.m_CartGrid:clear()
end

function FactionWeaponShopGUI:deleteItemFromCart()
	local item = self.m_CartGrid:getSelectedItem()
	if item then
		self.m_Cart[item.id][item.typ] = self.m_Cart[item.id][item.typ]-1

		self:updateCart()
		self:updateButtons()
	end
end

function FactionWeaponShopGUI:addItemToCart(typ,weapon)
	if typ == "weapon" then self.m_Cart[weapon]["Waffe"] = self.m_Cart[weapon]["Waffe"]+1 end
	if typ == "munition" then self.m_Cart[weapon]["Munition"] = self.m_Cart[weapon]["Munition"]+1 end

	self:updateCart()
	self:updateButtons()
end

function FactionWeaponShopGUI:addMunitionToCart(weapon)
	self.m_Cart[weapon]["Magazin"] = self.m_Cart[weapon]["Magazin"]+1
	self:updateCart()
end

function FactionWeaponShopGUI:factionReceiveWeaponShopInfos()
	triggerServerEvent("factionReceiveWeaponShopInfos",localPlayer)
end

function FactionWeaponShopGUI:factionWeaponShopBuy()
	triggerServerEvent("factionWeaponShopBuy",root,self.m_Cart)
	delete(self)
end

addEventHandler("showFactionWeaponShopGUI", root,
		function()
			FactionWeaponShopGUI:new()
		end
	)
