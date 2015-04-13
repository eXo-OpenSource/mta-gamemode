-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/TradeGUI.lua
-- *  PURPOSE:     (Inventory) Trade GUI
-- *
-- ****************************************************************************
TradeGUI = inherit(GUIForm)
inherit(Singleton, TradeGUI)

function TradeGUI:constructor(myInventory)
    local width, height = screenWidth*0.5, screenHeight*0.6
    GUIForm.constructor(self, screenWidth/2-width/2, screenHeight/2-height/2, width, height)

    self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Handeln", true, true, self)

    -- Vertical line between local and remote inventory/trading list
    GUIRectangle:new(self.m_Width*0.65, 30, 3, self.m_Height-30, Color.White, self.m_Window)

    GUILabel:new(self.m_Width*0.01, self.m_Height*0.07, self.m_Width*0.27, self.m_Height*0.05, _"Meine Items:", self.m_Window)
    self.m_MyItemsGrid = GUIGridList:new(self.m_Width*0.01, self.m_Height*0.12, self.m_Width*0.3, self.m_Height*0.7, self.m_Window)
    self.m_MyItemsGrid:addColumn(_"Item", 0.7)
    self.m_MyItemsGrid:addColumn(_"Anzahl", 0.3)
    self.m_ButtonAdd = GUIButton:new(self.m_Width*0.26, self.m_Height*0.83, self.m_Width*0.05, self.m_Height*0.05, ">", self.m_Window):setBackgroundColor(Color.Green)
    self.m_ButtonAdd.onLeftClick = bind(self.ButtonAdd_Click, self)

    GUILabel:new(self.m_Width*0.33, self.m_Height*0.07, self.m_Width*0.27, self.m_Height*0.05, _"Handeln: ", self.m_Window)
    self.m_TradeItemsGrid = GUIGridList:new(self.m_Width*0.33, self.m_Height*0.12, self.m_Width*0.3, self.m_Height*0.7, self.m_Window)
    self.m_TradeItemsGrid:addColumn(_"Item", 0.7)
    self.m_TradeItemsGrid:addColumn(_"Anzahl", 0.3)
    self.m_ButtonRemove = GUIButton:new(self.m_Width*0.33, self.m_Height*0.83, self.m_Width*0.05, self.m_Height*0.05, "<", self.m_Window):setBackgroundColor(Color.Red)
    self.m_ButtonRemove.onLeftClick = bind(self.ButtonRemove_Click, self)

    GUILabel:new(self.m_Width*0.69, self.m_Height*0.07, self.m_Width*0.3, self.m_Height*0.05, _"Gegenleistung: ", self.m_Window)
    self.m_RemoteItemsGrid = GUIGridList:new(self.m_Width*0.69, self.m_Height*0.12, self.m_Width*0.3, self.m_Height*0.7, self.m_Window)
    self.m_RemoteItemsGrid:addColumn(_"Item", 0.7)
    self.m_RemoteItemsGrid:addColumn(_"Anzahl", 0.3)

    GUILabel:new(self.m_Width*0.01, self.m_Height*0.83, self.m_Width*0.08, self.m_Height*0.05, _"Anzahl:", self.m_Window)
    self.m_AmountEdit = GUIEdit:new(self.m_Width*0.09, self.m_Height*0.83, self.m_Width*0.14, self.m_Height*0.05, self.m_Window):setText("1"):setNumeric(true)

    GUILabel:new(self.m_Width*0.395, self.m_Height*0.83, self.m_Width*0.07, self.m_Height*0.05, _"Geld:", self.m_Window)
    self.m_MyMoneyEdit = GUIEdit:new(self.m_Width*0.46, self.m_Height*0.83, self.m_Width*0.17, self.m_Height*0.05, self.m_Window):setText("0"):setNumeric(true)
    self.m_MyMoneyEdit.onEditInput = bind(self.MyMoneyEdit_Input, self)

    self.m_RemoteMoney = GUILabel:new(self.m_Width*0.69, self.m_Height*0.83, self.m_Width*0.3, self.m_Height*0.05, _"Geld: 0$", self.m_Window)

    self.m_AcceptCheck = GUICheckbox:new(self.m_Width*0.01, self.m_Height*0.92, self.m_Width*0.3, self.m_Height*0.05, _"Ich bin einverstanden", self.m_Window)
    self.m_AcceptCheck.onChange = bind(self.AcceptCheck_Change, self)

    -- Update inventory
    self:updateMyInventory(myInventory)
end

function TradeGUI:updateMyInventory(inv)
    if inv then
        self.m_MyInventory = inv -- inv is normally the same as m_MyInventory
    end

    self.m_MyItemsGrid:clear()

    for k, item in pairs(self.m_MyInventory:getItems()) do
        local listItem = self.m_MyItemsGrid:addItem(item:getName(), tostring(item:getCount()))
        listItem.Item = item
    end

    -- Remove trade items from my inventory item list
    local removeList = {}
    local findItem = function(itemId) for k, item in pairs(self.m_MyItemsGrid:getItems()) do if item.Item:getItemId() == itemId then return item end end end
    for k, item in pairs(self.m_TradeItemsGrid:getItems()) do
        local myItem = findItem(item.ItemId)
        if myItem then
            local availableAmount = tonumber(myItem:getColumnText(2))
            local tradeAmount = tonumber(item:getColumnText(2))

            if availableAmount >= tradeAmount then
                myItem:setColumnText(2, tostring(availableAmount - tradeAmount))
            else
                -- Remove item if less items are available than we want to trade
                removeList[#removeList+1] = myItem
            end
        else
            -- Remove item if it does not exist anymore
            removeList[#removeList+1] = myItem
        end
    end

    -- Remove items here as we'd corrupt the iterator above otherwise
    for k, item in pairs(removeList) do
        self.m_TradeItemsGrid:removeItemByItem(item)
    end

    -- Uncheck 'accept' as the inventory has changed
    self.m_AcceptCheck:setChecked(false)
end

function TradeGUI:ButtonAdd_Click()
    local selectedItem = self.m_MyItemsGrid:getSelectedItem()
    if not selectedItem then
        WarningBox:new(_"Bitte wähle ein Item aus deinem Inventar aus")
        return
    end

    local amount = tonumber(self.m_AmountEdit:getText())
    if not amount or amount == 0 then
        WarningBox:new(_"Bitte gib eine gültige Anzahl an Items ein!")
        return
    end

    local name, availableAmount = selectedItem:getColumnText(1), tonumber(selectedItem:getColumnText(2))
    if not availableAmount then error("Internal error @ TradeGUI.ButtonAdd_Click") end

    if amount > availableAmount then
        WarningBox:new(_"Du kannst nicht mit mehr Items Handeln als du hast")
        return
    end

    -- TODO: Implement item stacking

    -- Add to trade list and remove from my item list
    local listItem = self.m_TradeItemsGrid:addItem(name, tostring(amount))
    listItem.ItemId = selectedItem.Item:getItemId()
    if availableAmount - amount == 0 then
        self.m_MyItemsGrid:removeItemByItem(selectedItem)
    else
        selectedItem:setColumnText(2, tostring(availableAmount - amount))
    end

    -- Inform the server about this
    local item = selectedItem.Item
    triggerServerEvent("tradeItemAdd", localPlayer, item:getItemId(), amount, item:getSlot())
end

function TradeGUI:ButtonRemove_Click()
    local selectedItem = self.m_TradeItemsGrid:getSelectedItem()
    if not selectedItem then
        WarningBox:new(_"Bitte wähle ein Item aus deinem Inventar aus")
        return
    end

    -- Remove item and update everything (updateMyInventory will substract the trading items then)
    self.m_TradeItemsGrid:removeItemByItem(selectedItem)
    self:updateMyInventory()

    -- Inform the server about this
    -- TODO: Add amount
    triggerServerEvent("tradeItemRemove", localPlayer, selectedItem.ItemId)
end

function TradeGUI:MyMoneyEdit_Input()
    local money = tonumber(self.m_MyMoneyEdit:getText())
    if money then
        -- Tell the server that we changed our money amount
        triggerServerEvent("tradeMoneyChange", localPlayer, money)
    end
end

function TradeGUI:AcceptCheck_Change(state)
    -- Tell the server that we are or are not ready for trading
    triggerServerEvent("tradeAcceptStatusChange", localPlayer)
end


addEvent("tradingStart", true)
addEventHandler("tradingStart", root,
    function(invId)
        if TradeGUI:isInstantiated() then
            delete(TradeGUI:getSingleton())
        end

        -- TODO: Replace by something like localPlayer:getInventory()
        if Inventory.Map[invId] then
            TradeGUI:new(Inventory.Map[invId])
        end
    end
)

addEvent("tradeItemUpdate", true)
addEventHandler("tradeItemUpdate", root,
    function(items)
        local tradeGUI = TradeGUI:getSingleton()

        tradeGUI.m_RemoteItemsGrid:clear()
        for k, item in pairs(items) do
            local itemId, amount = unpack(item)
            tradeGUI.m_RemoteItemsGrid:addItem(Items[itemId].name, tostring(amount))
        end
    end
)

addEvent("tradeMoneyChange", true)
addEventHandler("tradeMoneyChange", root,
    function(money)
        local tradeGUI = TradeGUI:getSingleton()
        tradeGUI.m_RemoteMoney:setText(_("Geld: %s$", tostring(money)))
    end
)
