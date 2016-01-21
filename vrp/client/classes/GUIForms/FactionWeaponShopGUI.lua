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
	GUIForm.constructor(self, screenWidth/2-310, screenHeight/2-230, 620, 460)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Fraktions Waffenshop", true, true, self)
	
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
	self.m_validWeapons = validWeapons
	
	
	
	GUILabel:new(280,220, 320, 35, "Warenkorb:", self.m_Window)
	self.m_CartGrid = GUIGridList:new(280, 250, 320, 180, self.m_Window)
	self.m_CartGrid:addColumn(_"Ware", 0.6)
	self.m_CartGrid:addColumn(_"Anzahl", 0.4)
	self.m_del = GUIButton:new(280, 430, 155, 20,_"entfernen", self.m_Window)
	self.m_del.onLeftClick = bind(self.deleteItemFromCart,self)
	self.m_buy = GUIButton:new(450, 430, 155, 20,_"Check out", self.m_Window)
	--addRemoteEvents{"depotRetrieveInfo"}
	--addEventHandler("depotRetrieveInfo", root, bind(self.Event_depotRetrieveInfo, self))
	addEventHandler("updateFactionWeaponShopGUI", root, bind(self.Event_updateFactionWeaponShopGUI, self))
	
	self:getPlayerWeapons()
	self:factionReceiveWeaponShopInfos()
	
end

function FactionWeaponShopGUI:Event_updateFactionWeaponShopGUI(depotWeapons)
	for k,v in pairs(self.m_validWeapons) do
		if v == true then
			self:addWeaponToGUI(k,depotWeapons[k]["Waffe"],depotWeapons[k]["Munition"])
		end
	end
	self.depot = depotWeapons
	self:updateButtons()
end

function FactionWeaponShopGUI:addWeaponToGUI(weaponID,Waffen,Munition)
	self.m_WeaponsName[weaponID] = GUILabel:new(25+self.m_WaffenRow*120, 35+self.m_WaffenColumn*200, 100, 25, getWeaponNameFromID(weaponID), self.m_Window)
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
	
	self.m_WaffenAnzahl = self.m_WaffenAnzahl+1
	
	if self.m_WaffenAnzahl == 5 or self.m_WaffenAnzahl == 7 then
		self.m_WaffenRow = 0
		self.m_WaffenColumn = self.m_WaffenColumn+1
	else
		self.m_WaffenRow = self.m_WaffenRow+1
	end
end

function FactionWeaponShopGUI:updateButtons()
	for k,v in pairs(self.m_validWeapons) do
		if v == true then
			if self.m_playerWeapons[k] or (self.m_Cart[k] and self.m_Cart[k]["Waffe"] > 0) then
				if self.m_WeaponsBuyMunition[k] then
					self.m_WeaponsBuyMunition[k]:setEnabled(true)
				end
				self.m_WeaponsBuyGun[k]:setEnabled(false)
			else
				self.m_WeaponsBuyGun[k]:setEnabled(true)
				if self.m_WeaponsBuyMunition[k] then
					self.m_WeaponsBuyMunition[k]:setEnabled(false)
					if self.m_Cart[k] then
						self.m_Cart[k]["Munition"] = 0
					end
				end
			end

			if self.depot[k]["Waffe"] == 0 then
				self.m_WeaponsBuyGun[k]:setEnabled(false)
			end
			if self.depot[k]["Munition"] == 0 then
				if self.m_WeaponsBuyMunition[k] then
					self.m_WeaponsBuyMunition[k]:setEnabled(false)
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
	for k,v in pairs(self.m_Cart) do
		for k1,v1 in pairs(self.m_Cart[k]) do
			if v1 > 0 then
				if k1 == "Waffe" then
					name = getWeaponNameFromID(k)
				elseif k1 == "Munition" then
					name = getWeaponNameFromID(k).." Magazin"
				end
				item = self.m_CartGrid:addItem(name,v1)
				item.typ = k1
				item.id = k
			end
		end
	end
end

function FactionWeaponShopGUI:deleteItemFromCart()
	local item = self.m_CartGrid:getSelectedItem()
	
	self.m_Cart[item.id][item.typ] = self.m_Cart[item.id][item.typ]-1
	
	self:updateCart()
	self:updateButtons()
end

function FactionWeaponShopGUI:addItemToCart(typ,weapon)
	if not(self.m_Cart[weapon]) then
		self.m_Cart[weapon] = {}
		self.m_Cart[weapon]["Waffe"] = 0
		self.m_Cart[weapon]["Munition"] = 0
	end
	if typ == "weapon" then self.m_Cart[weapon]["Waffe"] = self.m_Cart[weapon]["Waffe"]+1 end
	if typ == "munition" then self.m_Cart[weapon]["Munition"] = self.m_Cart[weapon]["Munition"]+1 end
	
	self:updateCart()
	self:updateButtons()
end

function FactionWeaponShopGUI:addMunitionToCart(weapon)
	if not(self.m_Cart[weapon]) then
		self.m_Cart[weapon] = {}
		self.m_Cart[weapon]["Waffe"] = 0
		self.m_Cart[weapon]["Munition"] = 0
	end
	self.m_Cart[weapon]["Magazin"] = self.m_Cart[weapon]["Magazin"]+1
	self:updateCart()
end

function FactionWeaponShopGUI:factionReceiveWeaponShopInfos()
		triggerServerEvent("factionReceiveWeaponShopInfos",localPlayer)
end

function FactionWeaponShopGUI:destuctor()	
	--removeEventHandler("depotRetrieveInfo", root, bind(self.Event_depotRetrieveInfo, self))
end

addEventHandler("showFactionWeaponShopGUI", root,
		function(validWeapons)
			FactionWeaponShopGUI:new(validWeapons)
		end
	)