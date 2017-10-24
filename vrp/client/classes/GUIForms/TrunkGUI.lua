-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/TrunkGUI.lua
-- *  PURPOSE:     Vehicle TrunkGUI
-- *
-- ****************************************************************************
TrunkGUI = inherit(GUIForm)
inherit(Singleton, TrunkGUI)

addRemoteEvents{"openTrunk", "getTrunkData"}

function TrunkGUI:constructor()
    GUIForm.constructor(self, screenWidth/2-620/2, screenHeight/2-400/2, 620, 400)

    self.ms_SlotsSettings = {
        ["item"] = {["color"] = Color.LightBlue, ["btnColor"] = Color.Blue, ["emptyText"] = _"Kein Item"},
        ["weapon"] = {["color"] = Color.Orange, ["btnColor"] = Color.Red, ["emptyText"] = _"Keine Waffe"}
    }

    self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Fahrzeug-Kofferraum", true, true, self)
    GUILabel:new(10, 35, 340, 35, _"Inventar:", self.m_Window)
    self.m_LoadingLabel = GUILabel:new(10, 70, 250, 250, _"wird geladen...", self.m_Window):setAlignX("center"):setAlignY("center"):setFontSize(1):setFont(VRPFont(20))
    self.m_MyItemsGrid = GUIGridList:new(10, 70, 250, 250, self.m_Window)
    self.m_MyItemsGrid:addColumn(_"Item/Waffe", 0.7)
    self.m_MyItemsGrid:addColumn(_"Anzahl", 0.3)
    self.m_MyItemsGrid:setVisible(false)
    self.m_AmountLabel = GUILabel:new(10, 325, 250, 30, _"Item-Anzahl:", self.m_Window)
    self.m_Amount = GUIEdit:new(10, 355, 250, 30, self.m_Window)
    self.m_AmountLabel:setVisible(false)
    self.m_Amount:setVisible(false)
    self.m_Amount.onChange = function()
        self:checkAmount()
    end

    GUILabel:new(320, 35, 340, 35, _"Kofferraum:", self.m_Window)
    GUILabel:new(320, 70, 340, 25, _"Items:", self.m_Window)

    self.m_ItemSlots = {}
    self:addSlot("item", 1, 320, 100)
    self:addSlot("item", 2, 470, 100)
    self:addSlot("item", 3, 320, 175)
    self:addSlot("item", 4, 470, 175)

    GUILabel:new(320, 250, 340, 25, _"Waffen:", self.m_Window)
    self.m_WeaponSlots = {}
    self:addSlot("weapon", 1, 320, 280)
    self:addSlot("weapon", 2, 470, 280)

	self.m_ToTrunk = GUIButton:new(275, 70, 30, 250, FontAwesomeSymbols.Right, self.m_Window)
	self.m_ToTrunk:setEnabled(false)
	self.m_ToTrunk:setFont(FontAwesome(15)):setFontSize(1)
	self.m_ToTrunk:setBarEnabled(false)
	self.m_ToTrunk:setBackgroundColor(Color.Accent)

    self.m_ToTrunk.onLeftClick = function() self:toTrunk() end
    triggerServerEvent("refreshInventory", localPlayer)
    self:loadItems()

    addEventHandler("getTrunkData", root, bind(self.refreshTrunkData, self))
end

function TrunkGUI:addSlot(type, id, posX, posY)
    local tableName
    if type == "item" then
        self.m_ItemSlots[id] = {}
        tableName = self.m_ItemSlots[id]
    elseif type == "weapon" then
        self.m_WeaponSlots[id] = {}
        tableName = self.m_WeaponSlots[id]
    end

    tableName.Rectangle = GUIRectangle:new(posX, posY, 140, 70, self.ms_SlotsSettings[type].color, self.m_Window)
    tableName.RectangleImage = GUIRectangle:new(posX+5, posY+10, 50, 50, tocolor(0,0,0,200), self.m_Window)
    tableName.Image = GUIImage:new(posX+10, posY+15, 40, 40, "files/images/Other/noImg.png", self.m_Window)
    tableName.Label = GUILabel:new(posX+60, posY+5, 70, 20, self.ms_SlotsSettings[type].emptyText, self.m_Window):setFontSize(1)
    tableName.Amount = GUILabel:new(posX+60, posY+25, 70, 20, "", self.m_Window):setFontSize(1)
    tableName.TakeButton = GUIButton:new(posX+60, posY+45, 70, 20, "<<", self.m_Window):setFontSize(1):setBackgroundColor(self.ms_SlotsSettings[type].btnColor)
    tableName.TakeButton:setEnabled(false)
    tableName.TakeButton.onLeftClick = function() self:fromTrunk(type, id) end
end

function TrunkGUI:loadItems()
    self.m_MyItemsGrid:clear()
    self.m_ItemData = Inventory:getSingleton():getItemData()
    self.m_Items = Inventory:getSingleton():getItems()
    self.m_MyItemsGrid:addItemNoClick(_"Items", _"Anzahl")
    local item
    for index, itemInv in pairs(self.m_Items) do
        if self.m_ItemData[itemInv["Objekt"]]["Handel"] == 1 then
            item = self.m_MyItemsGrid:addItem(itemInv["Objekt"], itemInv["Menge"])
            item.onLeftClick = function()
                self.m_SelectedItemType = "item"
                self.m_SelectedItem = itemInv["Objekt"]
                self.m_SelectedItemAmount = itemInv["Menge"]
				self.m_SelectedItemValue = itemInv["Value"]
                self.m_ToTrunk:setEnabled(true)
                self.m_AmountLabel:setVisible(true)
                self.m_Amount:setVisible(true)
                self.m_Amount:setText(tostring(itemInv["Menge"]))
                self:checkAmount()
            end
        end
    end
    self.m_MyItemsGrid:addItemNoClick(_"Waffe", _"Muni")
    for i=2,12 do
		local weaponId = getPedWeapon(localPlayer,i)
		if weaponId and weaponId ~= 0 then
            item = self.m_MyItemsGrid:addItem(WEAPON_NAMES[weaponId], getPedTotalAmmo(localPlayer, i))
            item.onLeftClick = function()
                self.m_SelectedItemType = "weapon"
                self.m_SelectedItem = weaponId
                self.m_SelectedItemAmount = getPedTotalAmmo(localPlayer, i)
                self.m_ToTrunk:setEnabled(true)
                self.m_AmountLabel:setVisible(false)
                self.m_Amount:setVisible(false)
                self:checkAmount()
            end
		end
	end
    self.m_MyItemsGrid:setVisible(true)
    self.m_LoadingLabel:setVisible(false)
end

function TrunkGUI:refreshTrunkData(id, items, weapons)
    self.m_Id = id
    for index, item in pairs(items) do
        if item["Item"] ~= "none" then
            self.m_ItemSlots[index].Label:setText(item["Item"])
            self.m_ItemSlots[index].Amount:setText(_("%d Stk.", item["Amount"]))
            self.m_ItemSlots[index].Image:setImage("files/images/Inventory/items/"..self.m_ItemData[item.Item]["Icon"])
            self.m_ItemSlots[index].TakeButton:setEnabled(true)
        else
            self.m_ItemSlots[index].Label:setText(self.ms_SlotsSettings["item"].emptyText)
            self.m_ItemSlots[index].Amount:setText("")
            self.m_ItemSlots[index].Image:setImage("files/images/Other/noImg.png")
            self.m_ItemSlots[index].TakeButton:setEnabled(false)
        end
    end
    for index, weapon in pairs(weapons) do
        if weapon["WeaponId"] > 0 then
            local weaponName = WEAPON_NAMES[weapon["WeaponId"]]
            self.m_WeaponSlots[index].Label:setText(weaponName:len() <= 6 and weaponName or ("%s (...)"):format(weaponName:sub(1, 6)))
            self.m_WeaponSlots[index].Amount:setText(_("%d Schuss", weapon["Amount"]))
            self.m_WeaponSlots[index].Image:setImage(WeaponIcons[weapon.WeaponId])
            self.m_WeaponSlots[index].TakeButton:setEnabled(true)
        else
            self.m_WeaponSlots[index].Label:setText(self.ms_SlotsSettings["weapon"].emptyText)
            self.m_WeaponSlots[index].Amount:setText("")
            self.m_WeaponSlots[index].Image:setImage("files/images/Other/noImg.png")
            self.m_WeaponSlots[index].TakeButton:setEnabled(false)
        end
    end
    triggerServerEvent("refreshInventory", localPlayer)
    setTimer(function()
        self:loadItems()
        self.m_MyItemsGrid:setVisible(true)
        self.m_LoadingLabel:setVisible(false)
    end, 250, 1)
end



function TrunkGUI:checkAmount(text)
    if self.m_SelectedItemType == "weapon" then
        self.m_ToTrunk:setEnabled(true)
        return
    end

    local amount = self.m_Amount:getText()
    if tonumber(amount) then
        if self.m_SelectedItemAmount then
            if tonumber(amount) > self.m_SelectedItemAmount then
                self.m_ToTrunk:setEnabled(false)
            else
                self.m_ToTrunk:setEnabled(true)
            end
        end
    end
end

function TrunkGUI:toTrunk()
    if self.m_Id then
        if self.m_SelectedItemType == "item" then
            local amount = tonumber(self.m_Amount:getText())
            if amount and amount > 0 then
                if amount <= self.m_SelectedItemAmount then
                    triggerServerEvent("trunkAddItem", localPlayer, self.m_Id, self.m_SelectedItem, amount, self.m_SelectedItemValue)
                    self.m_MyItemsGrid:setVisible(false)
                    self.m_LoadingLabel:setVisible(true)
                else
                    ErrorBox:new(_"Anzahl zu hoch! Du hast nicht soviel von diesem Item!")
                end
            else
                ErrorBox:new(_"Ungültige Item-Anzahl!")
            end
        elseif self.m_SelectedItemType == "weapon" then
            if localPlayer:getFaction() and localPlayer:getFaction():isStateFaction() and localPlayer:getPublicSync("Faction:Duty") == true then
				ErrorBox:new("Du bist im Dienst, du darfst keine Waffen einlagern!")
				return
			end
			triggerServerEvent("trunkAddWeapon", localPlayer, self.m_Id, self.m_SelectedItem, self.m_SelectedItemAmount)
        end
    else
        ErrorBox:new("InternalError - TrunkId not set")
    end
end

function TrunkGUI:fromTrunk(type, id)
    if type == "item" then
        tableName = self.m_ItemSlots[id]
    elseif type == "weapon" then
        tableName = self.m_WeaponSlots[id]
    end

    if tableName.Label:getText() ~= self.ms_SlotsSettings[type].emptyText then
        triggerServerEvent("trunkTake", localPlayer, self.m_Id, type, id)
        self.m_MyItemsGrid:setVisible(false)
        self.m_LoadingLabel:setVisible(true)
    else
        ErrorBox:new(_"In diesem Slot ist kein Item!")
    end
end



addEventHandler("openTrunk", root, function()
    if TrunkGUI:getSingleton():isInstantiated() then
        TrunkGUI:getSingleton():open()
    else
        TrunkGUI:getSingleton():new()
    end
end)
