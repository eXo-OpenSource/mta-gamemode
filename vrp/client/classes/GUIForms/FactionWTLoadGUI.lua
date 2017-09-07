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

function FactionWTLoadGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-945/2, screenHeight/2-230, 945, 460)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Waffentruck beladen", true, true, self)
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
	self.m_TotalCosts = 0

	self.m_MaxLoad = localPlayer:getFaction():isStateFaction() and WEAPONTRUCK_MAX_LOAD_STATE or WEAPONTRUCK_MAX_LOAD

	GUILabel:new(645,30, 280, 35, "im Waffentruck:", self.m_Window)
	self.m_CartGrid = GUIGridList:new(645, 65, 280, 280, self.m_Window)
	self.m_CartGrid:addColumn(_"Ware", 0.6)
	self.m_CartGrid:addColumn(_"Anz.", 0.1)
	self.m_CartGrid:addColumn(_"Preis", 0.3)
	self.m_del = GUIButton:new(645, 430, 135, 20,_"Entfernen", self.m_Window)
	self.m_del:setBackgroundColor(Color.Red)
	self.m_del:setEnabled(false)
	self.m_del.onLeftClick = bind(self.deleteItemFromCart,self)
	self.m_buy = GUIButton:new(795, 430, 135, 20,_"Beladen", self.m_Window)
	self.m_buy.onLeftClick = bind(self.factionWeaponTruckLoad,self)
	self.m_ShiftNotice = GUILabel:new(645, 350, 280, 20, _("Strg + Klick: Alles aufladen\nShift + Klick: 10 aufladen"), self.m_Window)
	self.m_Sum = GUILabel:new(645,390, 280, 30, _("Gesamtkosten: 0$/%d$", self.m_MaxLoad), self.m_Window)
	addEventHandler("updateFactionWeaponShopGUI", root, bind(self.Event_updateFactionWTLoadGUI, self))

	self:factionReceiveWeaponShopInfos()
end

function FactionWTLoadGUI:destuctor()
	removeEventHandler("updateFactionWeaponShopGUI", root, bind(self.Event_updateFactionWTLoadGUI, self))
	GUIForm.destructor(self)
end

function FactionWTLoadGUI:onShow()
	AntiClickSpam:getSingleton():setEnabled(false)
end

function FactionWTLoadGUI:onHide()
	AntiClickSpam:getSingleton():setEnabled(true)
end

function FactionWTLoadGUI:Event_updateFactionWTLoadGUI(validWeapons, depotWeaponsMax, depotWeapons)
	self.m_validWeapons = validWeapons
	self.m_DepotWeaponsMax = depotWeaponsMax
	for k,v in pairs(self.m_validWeapons) do
		if v == true then
			self:addWeaponToGUI(k,depotWeapons[k]["Waffe"],depotWeapons[k]["Munition"])
		end
	end
	self.depot = depotWeapons
	self:updateButtons()
	self:updateCart()
end

function FactionWTLoadGUI:addWeaponToGUI(weaponID,Waffen,Munition)
	local maxWeapon = self.m_DepotWeaponsMax[weaponID]["Waffe"]
	local maxMagazine = self.m_DepotWeaponsMax[weaponID]["Magazine"]
	local weaponPrice = self.m_DepotWeaponsMax[weaponID]["WaffenPreis"]
	local magazinePrice = self.m_DepotWeaponsMax[weaponID]["MagazinPreis"]
	self.m_WeaponsName[weaponID] = GUILabel:new(25+self.m_WaffenRow*125, 35+self.m_WaffenColumn*200, 105, 25, WEAPON_NAMES[weaponID], self.m_Window)
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
		self.m_WeaponsMunition[weaponID] = GUILabel:new(25+self.m_WaffenRow*125, 150+self.m_WaffenColumn*200, 105, 20, "Magazine: "..Munition.."/"..maxMagazine, self.m_Window):setFontSize(0.8)
		self.m_WeaponsMunition[weaponID]:setAlignX("center")

	end

	if not(self.m_Cart[weaponID]) then
		self.m_Cart[weaponID] = {}
		self.m_Cart[weaponID]["Waffe"] = 0
		self.m_Cart[weaponID]["Munition"] = 0
	end

	self.m_WaffenAnzahl = self.m_WaffenAnzahl+1

	if self.m_WaffenAnzahl == 5 or self.m_WaffenAnzahl == 10 or self.m_WaffenAnzahl == 15 then
		self.m_WaffenRow = 0
		self.m_WaffenColumn = self.m_WaffenColumn+1
	else
		self.m_WaffenRow = self.m_WaffenRow+1
	end

end

function FactionWTLoadGUI:updateButtons()
	for weaponID,v in pairs(self.m_validWeapons) do
		if v == true then
			if self.depot[weaponID]["Waffe"]+self.m_Cart[weaponID]["Waffe"] < self.m_DepotWeaponsMax[weaponID]["Waffe"] then
				if self.m_TotalCosts + self.m_DepotWeaponsMax[weaponID]["WaffenPreis"] < self.m_MaxLoad then
					self.m_WeaponsBuyGun[weaponID]:setEnabled(true)
				else
					self.m_WeaponsBuyGun[weaponID]:setEnabled(false)
				end
			else
				self.m_WeaponsBuyGun[weaponID]:setEnabled(false)
			end

			if self.m_WeaponsBuyMunition[weaponID] then
				if self.depot[weaponID]["Munition"]+self.m_Cart[weaponID]["Munition"] < self.m_DepotWeaponsMax[weaponID]["Magazine"] then
					if self.m_TotalCosts + self.m_DepotWeaponsMax[weaponID]["MagazinPreis"] <= self.m_MaxLoad then
						self.m_WeaponsBuyMunition[weaponID]:setEnabled(true)
					else
						self.m_WeaponsBuyMunition[weaponID]:setEnabled(false)
					end
				else
					self.m_WeaponsBuyMunition[weaponID]:setEnabled(false)
				end
			end
		end
	end
	if self.m_TotalCosts > 0 then self.m_buy:setEnabled(true) else	self.m_buy:setEnabled(false) end
end

function FactionWTLoadGUI:updateCart()
	self.m_del:setEnabled(false)
	self.m_CartGrid:clear()
	local name, item, price
	local totalCosts = 0
	for weaponID,v in pairs(self.m_Cart) do
		for typ,amount in pairs(self.m_Cart[weaponID]) do
			if amount > 0 then
				if typ == "Waffe" then
					name = WEAPON_NAMES[weaponID]
					price = amount*self.m_DepotWeaponsMax[weaponID]["WaffenPreis"]
				elseif typ == "Munition" then
					name = WEAPON_NAMES[weaponID].." Magazin"
					price = amount*self.m_DepotWeaponsMax[weaponID]["MagazinPreis"]
				end
				totalCosts = totalCosts + price
				item = self.m_CartGrid:addItem(name, amount, price.."$")
				item.typ = typ
				item.id = weaponID
				item.onLeftClick = function() self.m_del:setEnabled(true) end
			end
		end
	end

	self.m_TotalCosts = totalCosts
	self.m_Sum:setText(_("Gesamtkosten: %d$/%d$", totalCosts, self.m_MaxLoad))
end

function FactionWTLoadGUI:deleteItemFromCart()
	local item = self.m_CartGrid:getSelectedItem()
	if item then
		self.m_Cart[item.id][item.typ] = self.m_Cart[item.id][item.typ]-1

		self:updateCart()
		self:updateButtons()
	else
		ErrorBox:new(_"Kein Item ausgewählt!")
	end
end

function FactionWTLoadGUI:addItemToCart(typ,weapon)
	if getKeyState("lctrl") or getKeyState("lshift") then
		local index = "Waffe"
		local index2 = "Waffe"
		local indexPrice = "WaffenPreis"
		if typ == "munition" then index = "Munition"; index2 = "Magazine"; indexPrice = "MagazinPreis" end

		local max = self.m_DepotWeaponsMax[weapon][index2] - self.depot[weapon][index] - self.m_Cart[weapon][index]

		if getKeyState("lshift") then
			if max > 10 then max = 10 end
		end

		local pricePerUnit = self.m_DepotWeaponsMax[weapon][indexPrice]
		local remainingBudget = self.m_MaxLoad - self.m_TotalCosts

		local maxMoney = math.floor(remainingBudget / pricePerUnit)

		if maxMoney > max then
			self.m_Cart[weapon][index] = self.m_Cart[weapon][index] + max
		else
			self.m_Cart[weapon][index] = self.m_Cart[weapon][index] + maxMoney
		end
	else
		if typ == "weapon" then self.m_Cart[weapon]["Waffe"] = self.m_Cart[weapon]["Waffe"]+1 end
		if typ == "munition" then self.m_Cart[weapon]["Munition"] = self.m_Cart[weapon]["Munition"]+1 end
	end


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

function FactionWTLoadGUI:factionWeaponTruckLoad()
	triggerServerEvent("onWeaponTruckLoad",root,self.m_Cart)
	delete(self)
end

addEventHandler("showFactionWTLoadGUI", root,
		function()
			if FactionWTLoadGUI:getSingleton():isInstantiated() then
				FactionWTLoadGUI:getSingleton():open()
			else
				FactionWTLoadGUI:getSingleton():new()
			end

		end
	)
