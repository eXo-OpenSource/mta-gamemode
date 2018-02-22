-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Phone/AppAmmunation.lua
-- *  PURPOSE:     AppAmmunation app class
-- *
-- ****************************************************************************
AppAmmunation = inherit(PhoneApp)

function AppAmmunation:constructor()
	PhoneApp.constructor(self, "Ammu Nation", "IconAmmuNation.png")
end

function AppAmmunation:onOpen(form)

	self.m_SelectedWeaponId = 0
	self.m_Cart = {}

	self.m_TabPanel = GUIPhoneTabPanel:new(0, 0, form.m_Width, form.m_Height, form)
	self.m_Tabs = {}
	self.m_Tabs["Info"] = self.m_TabPanel:addTab(_"Information", FontAwesomeSymbols.Info)
	GUILabel:new(10, 10, 200, 50, _"Ammunation", self.m_Tabs["Info"])
	GUILabel:new(10, 65, form.m_Width-20, 22, _[[
		Hier kannst du den Lieferservice von Ammunation nutzen.
		Wähle einfach die gewünschten Produkte aus und klicke auf bestellen.

		Das Geld wird bequem vom Konto abgebucht!
	]], self.m_Tabs["Info"]):setMultiline(true)
	self.m_Tabs["Order"] = self.m_TabPanel:addTab(_"Bestellen", FontAwesomeSymbols.CartPlus)
	GUILabel:new(10, 10, 200, 50, _"Bestellen:", self.m_Tabs["Order"])
	self.m_WeaponChanger = GUIChanger:new(10, 65, 240, 30, self.m_Tabs["Order"])
	self.m_WeaponChanger:addItem("<< Produkt auswählen >>")
	for id, key in pairs(AmmuNationInfo) do
		if id > 0 then
			self.m_WeaponChanger:addItem(WEAPON_NAMES[id])
			if not self.m_Cart[id] then self.m_Cart[id] = {["Waffe"] = 0, ["Munition"] = 0} end
		end
	end
	self.m_WeaponChanger:addItem("Schutzweste")
	if not self.m_Cart[0] then self.m_Cart[0] = {["Waffe"] = 0, ["Munition"] = 0} end


	self.m_WeaponChanger.onChange = function(text)
		self:onWeaponChange(text)
	end
	self.m_WeaponName = GUILabel:new(10, 105, 240, 20, _"Ammunation", self.m_Tabs["Order"]):setAlignX("center")
	self.m_WeaponImage = GUIImage:new(90, 130, 60, 60, "files/images/Other/trans.png", self.m_Tabs["Order"])
	self.m_CartLabel = GUILabel:new(10, 200, 245, 30, _"In den Warenkorb legen:", self.m_Tabs["Order"])
	self.m_WeaponBuyBtn = GUIButton:new(10, 240, 240, 25, "Waffe (0$)", self.m_Tabs["Order"])
	self.m_WeaponBuyBtn.onLeftClick = bind(self.addItemToCart,self,"weapon")
	self.m_MagazineBuyBtn = GUIButton:new(10, 270, 240, 25, "Magazin (0$)", self.m_Tabs["Order"])
	self.m_MagazineBuyBtn.onLeftClick = bind(self.addItemToCart,self,"munition")

	GUIRectangle:new(10, 308, 240, 2, Color.LightBlue, self.m_Tabs["Order"])
	GUILabel:new(10, 310, 240, 30, _"Im Warenkorb:", self.m_Tabs["Order"])
	self.m_SumLabel = GUILabel:new(10, 340, 240, 20, _"Gesamtsumme:", self.m_Tabs["Order"])
	GUILabel:new(190, 310, 50, 50, FontAwesomeSymbols.Cart, self.m_Tabs["Order"]):setFont(FontAwesome(50))
	self.m_OrderBtn = GUIButton:new(10, 365, 240, 30, "Waren bestellen", self.m_Tabs["Order"])
	self.m_OrderBtn:setBackgroundColor(Color.Green)
	self.m_OrderBtn.onLeftClick = bind(self.order,self)


	self.m_CartLabel:setVisible(false)
	self.m_WeaponName:setVisible(false)
	self.m_WeaponImage:setVisible(false)
	self.m_WeaponBuyBtn:setVisible(false)
	self.m_MagazineBuyBtn:setVisible(false)

	self.m_Tabs["Basket"] = self.m_TabPanel:addTab(_"Warenkorb", FontAwesomeSymbols.Money)
	GUILabel:new(10, 10, 200, 50, _"Warenkorb", self.m_Tabs["Basket"])
	self.m_CartGrid = GUIGridList:new(0, 60, 260, 285, self.m_Tabs["Basket"])
	self.m_CartGrid:setItemHeight(20)
	self.m_CartGrid:setFont(VRPFont(20))
	self.m_CartGrid:addColumn(_"Ware", 0.6)
	self.m_CartGrid:addColumn(_"Anzahl", 0.4)
	self.m_SumLabelCart = GUILabel:new(10, 350, 240, 20, _"Gesamtsumme:", self.m_Tabs["Basket"])
	self.m_del = GUIButton:new(10, 375, 115, 20,_"entfernen", self.m_Tabs["Basket"])
	self.m_del:setBackgroundColor(Color.Red)
	self.m_del.onLeftClick = bind(self.deleteItemFromCart,self)
	self.m_OrderBtnCart = GUIButton:new(135, 375, 115, 20,_"Bestellen", self.m_Tabs["Basket"])
	self.m_OrderBtnCart:setBackgroundColor(Color.Green)
	self.m_OrderBtnCart.onLeftClick = bind(self.order,self)
	self:getPlayerWeapons()
	ShortMessage:new(_("Links-Shift halten um 10-fache Muniton zu bestellen."), _"Ammunation App", {0, 102, 102})
	
end

function AppAmmunation:addItemToCart(typ)
	local weaponID = self.m_SelectedWeaponId
	if localPlayer:getWeaponLevel() < MIN_WEAPON_LEVELS[weaponID] then
		ErrorBox:new(_("Dein Waffenlevel ist zu niedrig! (Benötigt: %i)", MIN_WEAPON_LEVELS[weaponID]))
		return
	end
	if typ == "weapon" then self.m_Cart[weaponID]["Waffe"] = self.m_Cart[weaponID]["Waffe"]+1 end
	if typ == "munition" then 
		if not getKeyState("lshift") then
			self.m_Cart[weaponID]["Munition"] = self.m_Cart[weaponID]["Munition"]+1 
		else 
			self.m_Cart[weaponID]["Munition"] = self.m_Cart[weaponID]["Munition"]+10
		end
	end

	self:updateCart()
end

function AppAmmunation:order()
	triggerServerEvent("onAmmunationAppOrder",root,self.m_Cart)
	self:clearCart()
end

function AppAmmunation:deleteItemFromCart()
	local item = self.m_CartGrid:getSelectedItem()
	if item then
		self.m_Cart[item.id][item.typ] = self.m_Cart[item.id][item.typ]-1
		self:updateCart()
	end
end

function AppAmmunation:updateCart()
	self.m_CartGrid:clear()
	local totalCosts = 0
	local name,item
	for weaponID,v in pairs(self.m_Cart) do
		for typ,amount in pairs(self.m_Cart[weaponID]) do
			if amount > 0 then
				if typ == "Waffe" then
					name = WEAPON_NAMES[weaponID]
					price = amount*AmmuNationInfo[weaponID].Weapon
				elseif typ == "Munition" then
					name = WEAPON_NAMES[weaponID].." Magazin"
					price = amount*AmmuNationInfo[weaponID].Magazine.price
				end
				if weaponID == 0 then name = "Schutzweste" end
				totalCosts = totalCosts + price
				item = self.m_CartGrid:addItem(name,amount)
				item:setFont(VRPFont(20))
				item.typ = typ
				item.id = weaponID
			end
		end
	end
	self.m_TotalCosts = totalCosts
	self.m_SumLabel:setText(_("Gesamtsumme: %d$", totalCosts))
	self.m_SumLabelCart:setText(_("Gesamtsumme: %d$", totalCosts))
	self:updateButtons()

end

function AppAmmunation:updateButtons()
	local weaponID = self.m_SelectedWeaponId
	self.m_MagazineBuyBtn:setEnabled(false)
	self.m_WeaponBuyBtn:setEnabled(false)

	if self.m_playerWeapons[weaponID] or self.m_Cart[weaponID]["Waffe"] > 0 then
		if localPlayer:getWeaponLevel() >= MIN_WEAPON_LEVELS[weaponID] then
			self.m_MagazineBuyBtn:setEnabled(true)
		end
	end

	if localPlayer:getWeaponLevel() >= MIN_WEAPON_LEVELS[weaponID] then
		self.m_WeaponBuyBtn:setEnabled(true)
	end
end

function AppAmmunation:getPlayerWeapons()
	self.m_playerWeapons = {}
	for i=1, 12 do
		if getPedWeapon(localPlayer,i) > 0 then
			self.m_playerWeapons[getPedWeapon(localPlayer,i)] = true
		end
	end
end

function AppAmmunation:onWeaponChange(name)
	if WEAPON_IDS[name] or name == "Schutzweste" then
		self.m_CartLabel:setVisible(true)
		self.m_WeaponName:setVisible(true)
		self.m_WeaponImage:setVisible(true)
		self.m_WeaponBuyBtn:setVisible(true)

		if name == "Schutzweste" then
			self.m_SelectedWeaponId = 0
			self.m_WeaponImage:setImage("files/images/Weapons/Vest.png")
			self.m_WeaponName:setText(name)
			self.m_WeaponBuyBtn:setText(_("Schutzweste (%d$)", AmmuNationInfo[0].Weapon))
			self.m_MagazineBuyBtn:setVisible(false)
			self:updateButtons()
		else
			local weaponID = WEAPON_IDS[name]
			self.m_SelectedWeaponId = weaponID

			self.m_WeaponImage:setImage(WeaponIcons[weaponID])
			self.m_WeaponName:setText(_("Waffe: %s (Level: %i)", name, MIN_WEAPON_LEVELS[weaponID]))
			self.m_WeaponBuyBtn:setText(_("Waffe (%d$)", AmmuNationInfo[weaponID].Weapon))
			if AmmuNationInfo[weaponID].Magazine then
				self.m_MagazineBuyBtn:setText(_("Magazin (%d$)", AmmuNationInfo[weaponID].Magazine.price))
				self.m_MagazineBuyBtn:setVisible(true)
			else
				self.m_MagazineBuyBtn:setVisible(false)
			end
			self:updateButtons()
		end
	else
		self.m_CartLabel:setVisible(false)
		self.m_WeaponName:setVisible(false)
		self.m_WeaponImage:setVisible(false)
		self.m_WeaponBuyBtn:setVisible(false)
		self.m_MagazineBuyBtn:setVisible(false)
	end
end

function AppAmmunation:onClose()

end

function AppAmmunation:clearCart()
	for key, item in pairs(self.m_CartGrid:getItems()) do
		if item then
			self.m_Cart[item.id][item.typ] = 0
		end
	end
	self:updateCart()
end
