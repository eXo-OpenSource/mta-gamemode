-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/TradeGUI.lua
-- *  PURPOSE:     (Inventory) Trade GUI
-- *
-- ****************************************************************************
TradeGUI = inherit(GUIForm)
inherit(Singleton, TradeGUI)

function TradeGUI:constructor(target)
    GUIForm.constructor(self, screenWidth/2-600/2, screenHeight/2-400/2, 580, 400)
    self.m_TargetPlayer = target

    self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _("Handel mit %s", target:getName()), true, true, self)

	self.m_TabPanel = GUITabPanel:new(10, 35, 320, 350, self.m_Window)
	self.m_TabPanel.onTabChanged = bind(self.TabPanel_TabChanged, self)

	self.m_TabItems = self.m_TabPanel:addTab(_"Items")

    self.m_MyItemsGrid = GUIGridList:new(5, 10, 310, 305, self.m_TabItems)
    self.m_MyItemsGrid:addColumn(_"Item", 0.7)
    self.m_MyItemsGrid:addColumn(_"Anzahl", 0.3)

	self.m_TabWeapons = self.m_TabPanel:addTab(_"Waffen")

    self.m_MyWeaponsGrid = GUIGridList:new(5, 10, 310, 305, self.m_TabWeapons)
    self.m_MyWeaponsGrid:addColumn(_"Waffe", 0.7)
    self.m_MyWeaponsGrid:addColumn(_"Patronen", 0.3)

	self.m_Preview = GUIImage:new(423, 35, 64, 64, false, self.m_Window)
    self.m_LabelDescription = GUILabel:new(340, 105, 230, 20, "", self.m_Window)
    self.m_LabelDescription:setFont(VRPFont(self.m_Height*0.05))
    self.m_LabelDescription:setAlignX("center")
    self.m_LabelAmountText = GUILabel:new(340, 200, 110, 30, "Item-Anzahl:", self.m_Window)
    self.m_Amount = GUIEdit:new(460, 200, 85, 30, self.m_Window)
	self.m_Amount:setText("1")
	self.m_Amount:setNumeric(true, true)
    self.m_Amount.onChange = function()
        self:checkAmount()
    end
    GUILabel:new(340, 240, 220, 30, "gewünschtes Geld:", self.m_Window)
    self.m_Money = GUIEdit:new(340, 270, 205, 30, self.m_Window)
	self.m_Money:setText("0")
    GUILabel:new(550, 270, 20, 30, "$", self.m_Window)
    self.m_Money:setNumeric(true, true)
    self.m_LabelError = GUILabel:new(340, 310, 225, 25, "", self.m_Window)
    self.m_LabelError:setColor(Color.Red)

    self.m_ButtonTrade = GUIButton:new(340, 350, 225, 35, _"Handel vorschlagen", self.m_Window):setBackgroundColor(Color.Green):setBarEnabled(true)
    self.m_ButtonTrade:setEnabled(false)

    self.m_ButtonTrade.onLeftClick = function() self:requestTrade() end
    self:loadItems()
end

function TradeGUI:TabPanel_TabChanged(tabId)
	self.m_Preview:setImage("files/images/Other/trans.png")
	self.m_LabelDescription:setText("")
	self.m_LabelAmountText:setVisible(false)
	self.m_Amount:setVisible(false)

	if tabId == self.m_TabItems.TabIndex then
		self:loadItems()
	elseif tabId == self.m_TabWeapons.TabIndex then
		self:loadWeapons()
	end
end

function TradeGUI:loadItems()
   self.m_MyItemsGrid:clear()
   self.m_LabelAmountText:setVisible(true)
   self.m_Amount:setVisible(true)
   	triggerServerEvent("refreshInventory", localPlayer)
    self.m_ItemData = Inventory:getSingleton():getItemData()
    self.m_Items = Inventory:getSingleton():getItems()

    local item
	if self.m_Items then
		for index, itemInv in pairs(self.m_Items) do
			if self.m_ItemData then
				if self.m_ItemData[itemInv["Objekt"]]["Handel"] == 1 then
					item = self.m_MyItemsGrid:addItem(itemInv["Objekt"], itemInv["Menge"])
					item.onLeftClick = function()
						self.m_SelectedType = "Item"
						self.m_SelectedItem = itemInv["Objekt"]
						self.m_SelectedItemAmount = itemInv["Menge"]
						self.m_SelectedItemValue = itemInv["Value"]
						self.m_ButtonTrade:setEnabled(true)
						self.m_Preview:setImage("files/images/Inventory/items/"..self.m_ItemData[itemInv["Objekt"]]["Icon"])
						self.m_LabelDescription:setText(self.m_ItemData[itemInv["Objekt"]]["Info"])
						self:checkAmount()
					end
				end
			end
        end
    end
end

function TradeGUI:loadWeapons()
   self.m_MyWeaponsGrid:clear()
    for i = 0, 12 do
		local weaponId = getPedWeapon(localPlayer, i)
		if weaponId and weaponId ~= 0 then
			if not TRADE_DISABLED_WEAPONS[weaponId] then
				local item = self.m_MyWeaponsGrid:addItem(WEAPON_NAMES[weaponId], getPedTotalAmmo(localPlayer, i))
				item.onLeftClick =
					function()
						self.m_SelectedType = "Weapon"
						self.m_SelectedItem = weaponId
						self.m_SelectedItemAmount = getPedTotalAmmo(localPlayer, i)
						self.m_ButtonTrade:setEnabled(true)
						self.m_Preview:setImage(FileModdingHelper:getSingleton():getWeaponImage(weaponId))
						self.m_LabelDescription:setText(WEAPON_NAMES[weaponId])
					end
			end
		end
	end
end

function TradeGUI:checkAmount(text)
    if self.m_SelectedType ~= "Item" then return end

	local amount = self.m_Amount:getText()
    if tonumber(amount) then
        if self.m_SelectedItemAmount then
            if tonumber(amount) > self.m_SelectedItemAmount then
                self.m_LabelError:setText(_("Du hast nicht soviel %s!", self.m_SelectedItem))
                self.m_ButtonTrade:setEnabled(false)
            else
                self.m_LabelError:setText("")
                self.m_ButtonTrade:setEnabled(true)
            end
        else
            self.m_LabelError:setText(_"Bitte wähle ein Item aus!")
        end
    else
        self.m_LabelError:setText(_"Bitte gib eine gültige Anzahl ein!")
    end
end

function TradeGUI:requestTrade()
    if not self.m_SelectedItem then
		ErrorBox:new(_("Du hast kein/e %s ausgewählt!", self.m_SelectedType))
		return
	end

	if self.m_SelectedType == "Item" then
		if tonumber(self.m_Amount:getText()) > 0 then
			if tonumber(self.m_Amount:getText()) <= self.m_SelectedItemAmount then
				triggerServerEvent("requestTrade", localPlayer, "Item", self.m_TargetPlayer, self.m_SelectedItem, tonumber(self.m_Amount:getText()), tonumber(self.m_Money:getText()), self.m_SelectedItemValue)
				delete(self)
			else
				ErrorBox:new(_("Du nicht ausreichend %s!", self.m_SelectedItem))
			end
		else
			ErrorBox:new(_"Du hast keine Anzahl eingegeben!")
		end
	elseif self.m_SelectedType == "Weapon" then
		triggerServerEvent("requestTrade", localPlayer, "Weapon", self.m_TargetPlayer, self.m_SelectedItem, self.m_SelectedItemAmount, tonumber(self.m_Money:getText()))
		delete(self)
	end
end
