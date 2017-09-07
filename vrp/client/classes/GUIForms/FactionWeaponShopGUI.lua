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

function FactionWeaponShopGUI:constructor(validWeapons)
	GUIForm.constructor(self, screenWidth/2-370, screenHeight/2-230, 740, 460)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Fraktions Waffenshop - "..localPlayer:getFaction():getShortName(), true, true, self)
	self.m_Window:deleteOnClose(true)
	self.m_Cart = {}

	self.m_WeaponsImage = {}
	self.m_WeaponsName = {}
	self.m_WeaponsMenge = {}
	self.m_WeaponsMunition = {}
	self.m_WeaponsBuyGun = {}
	self.m_WeaponsBuyMunition = {}
	self.m_WaffenAnzahl = 0
	self.m_WaffenRow = 0
	self.m_WaffenColumn = 0

	GUILabel:new(400,220, 320, 35, "Warenkorb:", self.m_Window)
	self.m_CartGrid = GUIGridList:new(400, 250, 320, 180, self.m_Window)
	self.m_CartGrid:addColumn(_"Ware", 0.6)
	self.m_CartGrid:addColumn(_"Anzahl", 0.4)
	self.m_del = GUIButton:new(400, 430, 155, 20,_"Entfernen", self.m_Window)
	self.m_del:setBackgroundColor(Color.Red)
	self.m_del.onLeftClick = bind(self.deleteItemFromCart,self)
	self.m_buy = GUIButton:new(570, 430, 155, 20,_"Bestätigen", self.m_Window)
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
	self.m_validWeapons = validWeapons
	for k,v in pairs(self.m_validWeapons) do
		if v == true then
			self:addWeaponToGUI(k,depotWeapons[k]["Waffe"],depotWeapons[k]["Munition"])
		end
	end
	self.rankWeapons = rankWeapons
	self.depot = depotWeapons
	self:updateButtons()
end

function FactionWeaponShopGUI:addWeaponToGUI(weaponID,Waffen,Munition)
	self.m_WeaponsName[weaponID] = GUILabel:new(25+self.m_WaffenRow*120, 35+self.m_WaffenColumn*200, 100, 25, WEAPON_NAMES[weaponID], self.m_Window)
	self.m_WeaponsName[weaponID]:setAlignX("center")
	self.m_WeaponsImage[weaponID] = GUIImage:new(45+self.m_WaffenRow*120, 70+self.m_WaffenColumn*200, 60, 60, WeaponIcons[weaponID], self.m_Window)
	self.m_WeaponsMenge[weaponID] = GUILabel:new(25+self.m_WaffenRow*120, 135+self.m_WaffenColumn*200, 100, 20, "Waffenlager: "..Waffen, self.m_Window)
	self.m_WeaponsMenge[weaponID]:setAlignX("center")
	self.m_WeaponsMunition[weaponID] = GUILabel:new(25+self.m_WaffenRow*120, 150+self.m_WaffenColumn*200, 100, 20, "Magazine: "..Munition, self.m_Window)
	self.m_WeaponsMunition[weaponID]:setAlignX("center")
	self.m_WeaponsBuyGun[weaponID] = GUIButton:new(25+self.m_WaffenRow*120, 170+self.m_WaffenColumn*200, 100, 20,"+ Waffe", self)
	self.m_WeaponsBuyGun[weaponID]:setBackgroundColor(Color.Red):setFontSize(1)
	self.m_WeaponsBuyGun[weaponID].onLeftClick = bind(self.addItemToCart,self,"weapon",weaponID)

	if weaponID >=22 and weaponID <= 43 then
		self.m_WeaponsBuyMunition[weaponID] = GUIButton:new(25+self.m_WaffenRow*120, 195+self.m_WaffenColumn*200, 100, 20,"+ Magazin", self)
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

	if self.m_WaffenAnzahl == 6 or self.m_WaffenAnzahl == 9 then
		self.m_WaffenRow = 0
		self.m_WaffenColumn = self.m_WaffenColumn+1
	else
		self.m_WaffenRow = self.m_WaffenRow+1
	end

end

function FactionWeaponShopGUI:updateButtons()
	for weaponID,v in pairs(self.m_validWeapons) do
		if v == true then
			local skip = false
			if self.rankWeapons[tostring(weaponID)] == 1 then
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
		function(validWeapons)
			FactionWeaponShopGUI:new(validWeapons)
		end
	)
