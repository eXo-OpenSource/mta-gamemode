-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/FactionWTLoadGUI.lua
-- *  PURPOSE:     Faction Weapon Shop GUI class
-- *
-- ****************************************************************************
FactionWTLoadGUI = inherit(GUIForm)
inherit(Singleton, FactionWTLoadGUI)

addRemoteEvents{"showFactionWTLoadGUI", "updateFactionWeaponShopGUI"}

function FactionWTLoadGUI:constructor(validWeapons, depotWeaponsMax)
	GUIForm.constructor(self, screenWidth/2-390, screenHeight/2-230, 840, 460)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Waffentruck beladen", true, true, self)

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
	self.m_DepotWeaponsMax = depotWeaponsMax

	GUILabel:new(540,30, 280, 35, "im Waffentruck:", self.m_Window)
	self.m_CartGrid = GUIGridList:new(540, 65, 280, 300, self.m_Window)
	self.m_CartGrid:addColumn(_"Ware", 0.6)
	self.m_CartGrid:addColumn(_"Anz.", 0.1)
	self.m_CartGrid:addColumn(_"Preis", 0.3)
	self.m_del = GUIButton:new(540, 430, 135, 20,_"entfernen", self.m_Window)
	self.m_del:setBackgroundColor(Color.Red)
	self.m_del.onLeftClick = bind(self.deleteItemFromCart,self)
	self.m_buy = GUIButton:new(690, 430, 135, 20,_"Beladen", self.m_Window)
	self.m_buy.onLeftClick = bind(self.factionWeaponShopBuy,self)
	self.m_Sum = GUILabel:new(540,390, 280, 30, "Gesamtkosten: 0$", self.m_Window)
	addEventHandler("updateFactionWeaponShopGUI", root, bind(self.Event_updateFactionWTLoadGUI, self))

	self:factionReceiveWeaponShopInfos()

end

function FactionWTLoadGUI:destuctor()
	removeEventHandler("updateFactionWeaponShopGUI", root, bind(self.Event_updateFactionWTLoadGUI, self))
	GUIForm.destructor(self)
end

function FactionWTLoadGUI:Event_updateFactionWTLoadGUI(depotWeapons)
	for k,v in pairs(self.m_validWeapons) do
		if v == true then
			self:addWeaponToGUI(k,depotWeapons[k]["Waffe"],depotWeapons[k]["Munition"])
		end
	end
	self.depot = depotWeapons
	self:updateButtons()
end

function FactionWTLoadGUI:addWeaponToGUI(weaponID,Waffen,Munition)
	local maxWeapon = self.m_DepotWeaponsMax[weaponID]["Waffe"]
	local maxMagazine = self.m_DepotWeaponsMax[weaponID]["Magazine"]
	local weaponPrice = self.m_DepotWeaponsMax[weaponID]["WaffenPreis"]
	local magazinePrice = self.m_DepotWeaponsMax[weaponID]["MagazinPreis"]
	self.m_WeaponsName[weaponID] = GUILabel:new(25+self.m_WaffenRow*125, 35+self.m_WaffenColumn*200, 105, 25, getWeaponNameFromID(weaponID), self.m_Window)
	self.m_WeaponsName[weaponID]:setAlignX("center")
	self.m_WeaponsImage[weaponID] = GUIImage:new(45+self.m_WaffenRow*125, 70+self.m_WaffenColumn*200, 60, 60, WeaponIcons[weaponID], self.m_Window)
	self.m_WeaponsMenge[weaponID] = GUILabel:new(25+self.m_WaffenRow*125, 135+self.m_WaffenColumn*200, 105, 20, "Waffen: "..Waffen.."/"..maxWeapon, self.m_Window)
	self.m_WeaponsMenge[weaponID]:setAlignX("center")
	self.m_WeaponsBuyGun[weaponID] = GUIButton:new(25+self.m_WaffenRow*125, 170+self.m_WaffenColumn*200, 105, 20,"+Waffe ("..weaponPrice.."$)", self)
	self.m_WeaponsBuyGun[weaponID]:setBackgroundColor(Color.Red):setFontSize(1)
	self.m_WeaponsBuyGun[weaponID].onLeftClick = bind(self.addItemToCart,self,"weapon",weaponID)

	if weaponID >=22 and weaponID <= 43 then
		self.m_WeaponsBuyMunition[weaponID] = GUIButton:new(25+self.m_WaffenRow*125, 195+self.m_WaffenColumn*200, 105, 20,"+Magazin ("..magazinePrice.."$)", self)
		self.m_WeaponsBuyMunition[weaponID]:setBackgroundColor(Color.Blue):setFontSize(1)
		self.m_WeaponsBuyMunition[weaponID].onLeftClick = bind(self.addItemToCart,self,"munition",weaponID)
		self.m_WeaponsMunition[weaponID] = GUILabel:new(25+self.m_WaffenRow*125, 150+self.m_WaffenColumn*200, 105, 20, "Magazine: "..Munition.."/"..maxMagazine, self.m_Window)
		self.m_WeaponsMunition[weaponID]:setAlignX("center")

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

function FactionWTLoadGUI:updateButtons()
	for weaponID,v in pairs(self.m_validWeapons) do
		if v == true then
			if self.depot[weaponID]["Waffe"]+self.m_Cart[weaponID]["Waffe"] >= self.m_DepotWeaponsMax[weaponID]["Waffe"] then
				self.m_WeaponsBuyGun[weaponID]:setEnabled(false)
			else
				self.m_WeaponsBuyGun[weaponID]:setEnabled(true)
			end

			if self.m_WeaponsBuyMunition[weaponID] then
				if self.depot[weaponID]["Munition"]+self.m_Cart[weaponID]["Munition"] >= self.m_DepotWeaponsMax[weaponID]["Magazine"] then
					self.m_WeaponsBuyMunition[weaponID]:setEnabled(false)
				else
					self.m_WeaponsBuyMunition[weaponID]:setEnabled(true)
				end
			end
		end
	end
	self:updateCart()
end

function FactionWTLoadGUI:updateCart()
	self.m_CartGrid:clear()
	local name, item, price
	local totalCosts = 0
	for weaponID,v in pairs(self.m_Cart) do
		for typ,amount in pairs(self.m_Cart[weaponID]) do
			if amount > 0 then
				if typ == "Waffe" then
					name = getWeaponNameFromID(weaponID)
					price = amount*self.m_DepotWeaponsMax[weaponID]["WaffenPreis"]
				elseif typ == "Munition" then
					name = getWeaponNameFromID(weaponID).." Magazin"
					price = amount*self.m_DepotWeaponsMax[weaponID]["MagazinPreis"]
				end
				totalCosts = totalCosts + price
				item = self.m_CartGrid:addItem(name, amount, price.."$")
				item.typ = typ
				item.id = weaponID
			end
		end
	end
	self.m_Sum:setText("Gesamtkosten: "..totalCosts.."$")
end

function FactionWTLoadGUI:deleteItemFromCart()
	local item = self.m_CartGrid:getSelectedItem()

	self.m_Cart[item.id][item.typ] = self.m_Cart[item.id][item.typ]-1

	self:updateCart()
	self:updateButtons()
end

function FactionWTLoadGUI:addItemToCart(typ,weapon)
	if typ == "weapon" then self.m_Cart[weapon]["Waffe"] = self.m_Cart[weapon]["Waffe"]+1 end
	if typ == "munition" then self.m_Cart[weapon]["Munition"] = self.m_Cart[weapon]["Munition"]+1 end

	self:updateCart()
	self:updateButtons()
end

function FactionWTLoadGUI:addMunitionToCart(weapon)
	self.m_Cart[weapon]["Magazin"] = self.m_Cart[weapon]["Magazin"]+1
	self:updateCart()
end

function FactionWTLoadGUI:factionReceiveWeaponShopInfos()
		triggerServerEvent("factionReceiveWeaponShopInfos",localPlayer)
end

function FactionWTLoadGUI:factionWeaponShopBuy()
	triggerServerEvent("factionWeaponShopBuy",root,self.m_Cart)
end

addEventHandler("showFactionWTLoadGUI", root,
		function(validWeapons, depotWeaponsMax)
			FactionWTLoadGUI:new(validWeapons, depotWeaponsMax)
		end
	)
