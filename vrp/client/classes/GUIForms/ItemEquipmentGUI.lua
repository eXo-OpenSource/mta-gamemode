-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ItemEquipmentGUI.lua
-- *  PURPOSE:     Equipment-Depot
-- *
-- ****************************************************************************
ItemEquipmentGUI = inherit(GUIForm)
inherit(Singleton, ItemEquipmentGUI)

addRemoteEvents{"ItemEquipmentOpen", "ItemEquipmentRefresh"}
function ItemEquipmentGUI:constructor(  )
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 21)	
	self.m_Height = grid("y", 10)
	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Ausrüstungslager", true, true, self)
	GUIGridRectangle:new(10, 2, 5, 1, Color.Grey, self.m_Window)
	
	self.m_GridInventar = GUIGridGridList:new(1, 2, 9, 8, self.m_Window)
	self.m_GridInventar:addColumn(_"Ausrüstung", 0.7)
	self.m_GridInventar:addColumn(_"Stück", 0.3)	
	GUIGridRectangle:new(1, 1, 9, 1, Color.Grey, self.m_Window)
	GUIGridLabel:new(1, 1, 9, 1, "Inventar", self.m_Window):setAlignX("center")
		
	self.m_GridDepot = GUIGridGridList:new(11, 2, 10, 8, self.m_Window)
	self.m_GridDepot:addColumn(_"Ausrüstung", 0.7)
	self.m_GridDepot:addColumn(_"Stück", 0.3)	
	GUIGridRectangle:new(11, 1, 10, 1, Color.Grey, self.m_Window)
	GUIGridLabel:new(11, 1, 10, 1, "Lager", self.m_Window):setAlignX("center")
	
	self.m_ButtonAdd = GUIGridButton:new(10, 2, 1, 2, ">", self.m_Window):setBackgroundColor(Color.Green)
	self.m_ButtonTake = GUIGridButton:new(10, 4, 1, 2, "<", self.m_Window):setBackgroundColor(Color.Orange)
	self.m_ButtonAddAll = GUIGridButton:new(10, 6, 1, 2, ">>", self.m_Window):setBackgroundColor(Color.Green)
    self.m_ButtonTakeAll = GUIGridButton:new(10, 8, 1, 2, "<<", self.m_Window):setBackgroundColor(Color.Orange)
    
    self.m_GridInventar:setVisible(false)


    triggerServerEvent("refreshInventory", localPlayer)

    addEventHandler("ItemEquipmentRefresh", root, bind(self.Event_onGetInfo, self))
    
end

function ItemEquipmentGUI:Event_onGetInfo(id, data, allowedItems)
	if data and allowedItems then 
        self.m_Depot = data
        self.m_AllowedItems = allowedItems
        self:loadInventoryItems()
        self:loadDepotItems()
	end
end

function ItemEquipmentGUI:loadInventoryItems()
    self.m_GridInventar:clear()
    self.m_ItemData = Inventory:getSingleton():getItemData()
    self.m_Items = Inventory:getSingleton():getItems()
    local item
    for index, itemInv in pairs(self.m_Items) do
        if self.m_ItemData[itemInv["Objekt"]]["Handel"] == 1 then
            if self.m_AllowedItems["Spezial"][itemInv["Objekt"]] or self.m_AllowedItems["Explosiv"][itemInv["Objekt"]] then
                item = self.m_GridInventar:addItem(itemInv["Objekt"], itemInv["Menge"])
                item:setTooltip(self.m_ItemData[itemInv["Objekt"]]["Info"])
                item.onLeftClick = function()
                    self.m_SelectedItemInventar = itemInv["Objekt"]
                    self.m_SelectedItemAmountInventar = itemInv["Menge"]
                end
            end
        end
    end
    self.m_GridInventar:setVisible(true)
end

function ItemEquipmentGUI:loadDepotItems()
    self.m_GridDepot:clear()
    self.m_ItemData = Inventory:getSingleton():getItemData()
    local item
    for itemName, amount in pairs(self.m_Depot) do
        if amount > 0 then
            item = self.m_GridDepot:addItem(itemName, amount)
            if self.m_ItemData[itemName] then
                item:setTooltip(self.m_ItemData[itemName]["Info"])
            end
            item.onLeftClick = function()
                self.m_SelectedItemDepot = itemName
                self.m_SelectedItemAmountDepot = amount
            end
        end
    end
    self.m_GridInventar:setVisible(true)
end

function ItemEquipmentGUI:destructor() 
	GUIForm.destructor(self)
end


addEventHandler("ItemEquipmentOpen", root, function()
    if ItemEquipmentGUI:getSingleton():isInstantiated() then
        ItemEquipmentGUI:getSingleton():open()
    else
        ItemEquipmentGUI:getSingleton():new()
    end
end)