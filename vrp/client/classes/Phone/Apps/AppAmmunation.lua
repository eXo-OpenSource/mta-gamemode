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
	self.m_Tabs["Order"] = self.m_TabPanel:addTab(_"Bestellen", FontAwesomeSymbols.CartPlus)
	GUILabel:new(10, 10, 200, 50, _"Bestellen:", self.m_Tabs["Order"])
	self.m_WeaponChanger = GUIChanger:new(10, 65, 240, 30, self.m_Tabs["Order"])
	self.m_WeaponChanger:addItem("<< Produkt auswählen >>")
	for id, key in pairs(AmmuNationInfo) do
		self.m_WeaponChanger:addItem(getWeaponNameFromID(id))
		if not self.m_Cart[id] then self.m_Cart[id] = {["Waffe"] = 0, ["Munition"] = 0} end

	end
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


end

function AppAmmunation:addItemToCart(typ)
	local weaponID = self.m_SelectedWeaponId
	if weaponID > 0 then
		if typ == "weapon" then self.m_Cart[weaponID]["Waffe"] = self.m_Cart[weaponID]["Waffe"]+1 end
		if typ == "munition" then self.m_Cart[weaponID]["Munition"] = self.m_Cart[weaponID]["Munition"]+1 end

		self:updateCart()
	end
end

function AppAmmunation:order()
	triggerServerEvent("onAmmunationAppOrder",root,self.m_Cart)
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
					name = getWeaponNameFromID(weaponID)
					price = amount*AmmuNationInfo[weaponID].Weapon
				elseif typ == "Munition" then
					name = getWeaponNameFromID(weaponID).." Magazin"
					price = amount*AmmuNationInfo[weaponID].Magazine.price
				end
				totalCosts = totalCosts + price
				item = self.m_CartGrid:addItem(name,amount)
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
	if self.m_playerWeapons[weaponID] or self.m_Cart[weaponID]["Waffe"] > 0 then
		if self.m_MagazineBuyBtn then
			self.m_MagazineBuyBtn:setEnabled(true)
		end
		self.m_WeaponBuyBtn:setEnabled(false)
	else
		self.m_WeaponBuyBtn:setEnabled(true)
		if self.m_MagazineBuyBtn then
			self.m_MagazineBuyBtn:setEnabled(false)
			self.m_Cart[weaponID]["Munition"] = 0
		end
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
	if getWeaponIDFromName(name) then
		local weaponID = getWeaponIDFromName(name)
		self.m_WeaponImage:setImage(WeaponIcons[weaponID])
		self.m_WeaponName:setText(_("Waffe: %s", name))
		self.m_WeaponBuyBtn:setText(_("Waffe (%d$)", AmmuNationInfo[weaponID].Weapon))
		self.m_MagazineBuyBtn:setText(_("Magazin (%d$)", AmmuNationInfo[weaponID].Magazine.price))
		self.m_SelectedWeaponId = weaponID
		self.m_CartLabel:setVisible(true)
		self.m_WeaponName:setVisible(true)
		self.m_WeaponImage:setVisible(true)
		self.m_WeaponBuyBtn:setVisible(true)
		self.m_MagazineBuyBtn:setVisible(true)
		self:updateButtons()

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
