-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ItemEquipmentGUI.lua
-- *  PURPOSE:     Equipment-Depot
-- *
-- ****************************************************************************
ItemEquipmentGUI = inherit(GUIForm)
inherit(Singleton, ItemEquipmentGUI)
ItemEquipmentGUI.ImagePath = "files/images/Inventory/items/"
addRemoteEvents{"ItemEquipmentOpen", "ItemEquipmentRefresh"}

function ItemEquipmentGUI:constructor(id)
    self.m_Id = id
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 21)	
	self.m_Height = grid("y", 11)
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
    self.m_ButtonAdd.onLeftClick = function() self:addItem(1) end
    
    self.m_ButtonTake = GUIGridButton:new(10, 4, 1, 2, "<", self.m_Window):setBackgroundColor(Color.Orange)
    self.m_ButtonTake.onLeftClick = function() self:takeItem(1) end

	self.m_ButtonAddAll = GUIGridButton:new(10, 6, 1, 2, ">>", self.m_Window):setBackgroundColor(Color.Green)
    self.m_ButtonAddAll.onLeftClick = function() self:addItem(-1) end

    self.m_ButtonTakeAll = GUIGridButton:new(10, 8, 1, 2, "<<", self.m_Window):setBackgroundColor(Color.Orange)
    self.m_ButtonTakeAll.onLeftClick = function() self:takeItem(-1) end

    self.m_GridInventar:setVisible(false)

    GUIGridRectangle:new(1, 10, 20, 1, Color.Grey, self.m_Window)
    self.m_Info = GUIGridLabel:new(2, 10, 18, 1, "", self.m_Window)

    triggerServerEvent("refreshInventory", localPlayer)

    addEventHandler("ItemEquipmentRefresh", root, bind(self.Event_onGetInfo, self))
    
end

function ItemEquipmentGUI:updateInfo( icon, text)
    if self.m_Image then
        self.m_Image:delete()
    end
    self.m_Info:setText(text) 
    self.m_Image = GUIGridImage:new(1, 10, 1, 1, ("%s%s"):format(ItemEquipmentGUI.ImagePath, icon), self.m_Window)
end
function ItemEquipmentGUI:addItem(amount)
    if self.m_SelectedItemInventar and self.m_Id then 
        triggerServerEvent("equipmentDepotAdd", localPlayer, self.m_Id, self.m_SelectedItemInventar, amount)
    end
end

function ItemEquipmentGUI:takeItem(amount)
    if self.m_SelectedItemDepot and self.m_Id then 
        triggerServerEvent("equipmentDepotTake", localPlayer, self.m_Id, self.m_SelectedItemDepot, amount)
    end
end

function ItemEquipmentGUI:Event_onGetInfo(id, data, allowedItems)
    if data and allowedItems then
        self.m_Id = id
        self.m_Depot = data
        self.m_AllowedItems = allowedItems
        self:loadInventoryItems()
        self:loadDepotItems()
	end
end

function ItemEquipmentGUI:isSpecialProduct(product) 
	return (product == "RPG-7" or product == "Granate" or product == "Scharfschützengewehr" or product == "Gasgranate") 
end

function ItemEquipmentGUI:loadInventoryItems()
    self.m_GridInventar:clear()
    self.m_ItemData = Inventory:getSingleton():getItemData()
    self.m_Items = Inventory:getSingleton():getItems()
    self.m_SelectedItemInventar = nil
    local item
    for index, itemInv in pairs(self.m_Items) do
        if self.m_ItemData[itemInv["Objekt"]]["Handel"] == 1 then
            if self.m_AllowedItems["Spezial"][itemInv["Objekt"]] or self.m_AllowedItems["Explosiv"][itemInv["Objekt"]] then
                item = self.m_GridInventar:addItem(itemInv["Objekt"], itemInv["Menge"])
                item.onLeftClick = function()
                    self.m_SelectedItemInventar = itemInv["Objekt"]
                    self.m_SelectedItemAmountInventar = itemInv["Menge"]
                    self:updateInfo(self.m_ItemData[itemInv["Objekt"]]["Icon"], self.m_ItemData[itemInv["Objekt"]]["Info"])
                end
            end
        end
    end
    local weapons = getPedWeapons(localPlayer)
    local weaponItem, weaponData
    for i, weapon in ipairs(weapons) do
        if getPedTotalAmmo(localPlayer, getSlotFromWeapon(weapon)) > 0 and self:getItemFromWeapon(weapon) then 
            weaponItem, weaponData = self:getItemFromWeapon(weapon)
            item = self.m_GridInventar:addItem(weaponItem, getPedTotalAmmo(localPlayer, getSlotFromWeapon(weapon)))
            item.weaponItem = weaponItem
            item.weaponAmount = getPedTotalAmmo(localPlayer, getSlotFromWeapon(weapon))
            item.onLeftClick = function(itm)
                self.m_SelectedItemInventar = itm.weaponItem
                self.m_SelectedItemAmountInventar = itm.weaponAmount
                self:updateInfo("Items/Munition.png", WEAPON_NAMES[weapon])
            end
        end
    end
    self.m_GridInventar:setVisible(true)
end

function ItemEquipmentGUI:getItemFromWeapon(weapon)
    for category, data in pairs(self.m_AllowedItems) do 
        for product, subdata in pairs(data) do 
            if subdata[3] and subdata[3] == weapon and not self:isSpecialProduct(product) then
                return product, subdata
            end
        end
    end
    return false
end

function ItemEquipmentGUI:getWeaponFromItem(item)
    for category, data in pairs(self.m_AllowedItems) do 
        for product, subdata in pairs(data) do 
            if product == item and subdata[3] then
                return subdata[3]
            end
        end
    end
    return false
end

function ItemEquipmentGUI:loadDepotItems()
    self.m_GridDepot:clear()
    self.m_ItemData = Inventory:getSingleton():getItemData()
    self.m_SelectedItemDepot = nil
    local item, weaponName, weaponData
    for itemName, amount in pairs(self.m_Depot) do
        if not self:isSpecialProduct(itemName) then
            if amount > 0 then
                item = self.m_GridDepot:addItem(itemName, amount)
                weaponName, weaponData = self:getWeaponFromItem(itemName)
                if weaponName then
                    item.m_SelectedWeaponName = WEAPON_NAMES[weaponName]
                    item.m_SelectedWeaponIcon = "Items/Munition.png"
                end
                item.onLeftClick = function(itm)
                    self.m_SelectedItemDepot = itemName
                    self.m_SelectedItemAmountDepot = amount
                    self:updateInfo(itm.m_SelectedWeaponIcon or self.m_ItemData[itemName]["Icon"], itm.m_SelectedWeaponName or self.m_ItemData[itemName]["Info"])
                end
            end
        end
    end
    self.m_GridInventar:setVisible(true)
end

function ItemEquipmentGUI:onHide()
    setElementData(localPlayer, "isEquipmentGUIOpen", false, true) 
end

function ItemEquipmentGUI:onShow()
    setElementData(localPlayer, "isEquipmentGUIOpen", true, true) 
end

function ItemEquipmentGUI:destructor() 
    GUIForm.destructor(self)
    setElementData(localPlayer, "isEquipmentGUIOpen", false, true) 
end


addEventHandler("ItemEquipmentOpen", root, function()
    if ItemEquipmentGUI:getSingleton():isInstantiated() then
        ItemEquipmentGUI:getSingleton():open()
    else
        ItemEquipmentGUI:getSingleton():new(id)
    end
end)