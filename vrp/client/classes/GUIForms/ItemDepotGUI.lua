-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ItemDepotGUI.lua
-- *  PURPOSE:     ItemDepotGUI
-- *
-- ****************************************************************************
ItemDepotGUI = inherit(GUIForm)
inherit(Singleton, ItemDepotGUI)

addRemoteEvents{"ItemDepotOpen", "ItemDepotRefresh"}

function ItemDepotGUI:constructor()
    GUIForm.constructor(self, screenWidth/2-620/2, screenHeight/2-400/2, 620, 400)

    self.ms_SlotsSettings = {
        ["item"] = {["color"] = Color.LightBlue, ["btnColor"] = Color.Blue, ["emptyText"] = _"Kein Item"}
    }

    self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Item Depot", true, true, self)
    GUILabel:new(10, 35, 340, 35, _"Inventar:", self.m_Window)
    self.m_LoadingLabel = GUILabel:new(10, 70, 250, 250, _"wird geladen...", self.m_Window):setAlignX("center"):setAlignY("center"):setFontSize(1):setFont(VRPFont(20))
    self.m_MyItemsGrid = GUIGridList:new(10, 70, 250, 250, self.m_Window)
    self.m_MyItemsGrid:addColumn(_"Item", 0.7)
    self.m_MyItemsGrid:addColumn(_"Anzahl", 0.3)
    self.m_MyItemsGrid:setVisible(false)
    self.m_AmountLabel = GUILabel:new(10, 325, 250, 30, _"Item-Anzahl:", self.m_Window)
    self.m_Amount = GUIEdit:new(10, 355, 250, 30, self.m_Window)
    self.m_AmountLabel:setVisible(false)
    self.m_Amount:setVisible(false)
    self.m_Amount.onChange = function()
        self:checkAmount()
    end

    GUILabel:new(320, 35, 340, 35, _"Depot:", self.m_Window)
    GUILabel:new(320, 70, 340, 25, _"Items:", self.m_Window)

    self.m_ItemSlots = {}
    self:addSlot(1, 320, 100)
    self:addSlot(2, 470, 100)
    self:addSlot(3, 320, 175)
    self:addSlot(4, 470, 175)
    self:addSlot(5, 320, 250)
    self:addSlot(6, 470, 250)

    self.m_ToDepot = GUIButton:new(275, 70, 30, 250, ">>", self.m_Window):setBackgroundColor(Color.LightBlue):setFontSize(1)
    self.m_ToDepot:setEnabled(false)

    self.m_ToDepot.onLeftClick = function() self:toDepot() end
    triggerServerEvent("refreshInventory", localPlayer)
    self:loadItems()

    addEventHandler("ItemDepotRefresh", root, bind(self.refreshData, self))
end

function ItemDepotGUI:addSlot(id, posX, posY)
    self.m_ItemSlots[id] = {}

    self.m_ItemSlots[id].Rectangle = GUIRectangle:new(posX, posY, 140, 70, self.ms_SlotsSettings["item"].color, self.m_Window)
    self.m_ItemSlots[id].RectangleImage = GUIRectangle:new(posX+5, posY+10, 50, 50, tocolor(0,0,0,200), self.m_Window)
    self.m_ItemSlots[id].Image = GUIImage:new(posX+10, posY+15, 40, 40, "files/images/Other/noImg.png", self.m_Window)
    self.m_ItemSlots[id].Label = GUILabel:new(posX+60, posY+5, 70, 20, self.ms_SlotsSettings["item"].emptyText, self.m_Window):setFontSize(1)
    self.m_ItemSlots[id].Amount = GUILabel:new(posX+60, posY+25, 70, 20, "", self.m_Window):setFontSize(1)
    self.m_ItemSlots[id].TakeButton = GUIButton:new(posX+60, posY+45, 70, 20, "<<", self.m_Window):setFontSize(1):setBackgroundColor(self.ms_SlotsSettings["item"].btnColor)
    self.m_ItemSlots[id].TakeButton:setEnabled(false)
    self.m_ItemSlots[id].TakeButton.onLeftClick = function() self:fromDepot(id) end
end

function ItemDepotGUI:loadItems()
    self.m_MyItemsGrid:clear()
    self.m_ItemData = Inventory:getSingleton():getItemData()
    self.m_Items = Inventory:getSingleton():getItems()
    local item
    for index, itemInv in pairs(self.m_Items) do
        if self.m_ItemData[itemInv["Objekt"]]["Handel"] == 1 then
            item = self.m_MyItemsGrid:addItem(itemInv["Objekt"], itemInv["Menge"])
            item.onLeftClick = function()
                self.m_SelectedItem = itemInv["Objekt"]
                self.m_SelectedItemAmount = itemInv["Menge"]
                self.m_ToDepot:setEnabled(true)
                self.m_AmountLabel:setVisible(true)
                self.m_Amount:setVisible(true)
                self.m_Amount:setText(tostring(itemInv["Menge"]))
                self:checkAmount()
            end
        end
    end
    self.m_MyItemsGrid:setVisible(true)
    self.m_LoadingLabel:setVisible(false)
end

function ItemDepotGUI:refreshData(id, items)
    self.m_Id = id
    for index, item in pairs(items) do
        if item["Item"] ~= 0 then
         	if self.m_ItemSlots[index] then
				self.m_ItemSlots[index].Label:setText(item["Item"])
				self.m_ItemSlots[index].Amount:setText(_("%d Stk.", item["Amount"]))
				if self.m_ItemSlots[index].Image and self.m_ItemData[item.Item] then
					self.m_ItemSlots[index].Image:setImage("files/images/Inventory/items/"..self.m_ItemData[item.Item]["Icon"])
					self.m_ItemSlots[index].TakeButton:setEnabled(true)
				end
			end
        else
			if self.m_ItemSlots[index] then
				self.m_ItemSlots[index].Label:setText(self.ms_SlotsSettings["item"].emptyText)
				self.m_ItemSlots[index].Amount:setText("")
				self.m_ItemSlots[index].Image:setImage("files/images/Other/noImg.png")
				self.m_ItemSlots[index].TakeButton:setEnabled(false)
			end
        end
    end
    triggerServerEvent("refreshInventory", localPlayer)
    setTimer(function()
        self:loadItems()
        self.m_MyItemsGrid:setVisible(true)
        self.m_LoadingLabel:setVisible(false)
    end, 250, 1)
end

function ItemDepotGUI:checkAmount(text)
    local amount = self.m_Amount:getText()
    if tonumber(amount) then
        if self.m_SelectedItemAmount then
            if tonumber(amount) > self.m_SelectedItemAmount then
                self.m_ToDepot:setEnabled(false)
            else
                self.m_ToDepot:setEnabled(true)
            end
        end
    end
end

function ItemDepotGUI:resetSelected()
	self.m_SelectedItem = nil
	self.m_SelectedItemAmount = nil
	self.m_SelectedItemValue = nil
end

function ItemDepotGUI:toDepot()
    if self.m_Id then
		if not self.m_SelectedItem then
			ErrorBox:new(_"Du hast kein Item aus der Liste ausgewält!")
			return
		end
		local amount = tonumber(self.m_Amount:getText())
        if amount and amount > 0 then
            if amount <= self.m_SelectedItemAmount then
                triggerServerEvent("itemDepotAdd", localPlayer, self.m_Id, self.m_SelectedItem, amount)
                self.m_MyItemsGrid:setVisible(false)
				self.m_LoadingLabel:setVisible(true)
				self:resetSelected()
            else
                ErrorBox:new(_"Anzahl zu hoch! Du hast nicht soviel von diesem Item!")
            end
        else
            ErrorBox:new(_"Ungültige Item-Anzahl!")
        end
    else
        ErrorBox:new("InternalError - DepotId not set")
    end
end

function ItemDepotGUI:fromDepot(id)
    if self.m_ItemSlots[id].Label:getText() ~= self.ms_SlotsSettings["item"].emptyText then
        triggerServerEvent("itemDepotTake", localPlayer, self.m_Id, id)
        self.m_MyItemsGrid:setVisible(false)
        self.m_LoadingLabel:setVisible(true)
    else
        ErrorBox:new(_"In diesem Slot ist kein Item!")
    end
end

addEventHandler("ItemDepotOpen", root, function()
    if ItemDepotGUI:getSingleton():isInstantiated() then
        ItemDepotGUI:getSingleton():open()
    else
        ItemDepotGUI:getSingleton():new()
    end
end)
