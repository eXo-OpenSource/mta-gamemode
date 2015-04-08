-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/VehicleTuningGUI.lua
-- *  PURPOSE:     Vehicle tuning garage class
-- *
-- ****************************************************************************
VehicleTuningGUI = inherit(GUIForm)

function VehicleTuningGUI:constructor(vehicle)
    GUIForm.constructor(self, 10, 10, screenWidth/5/ASPECT_RATIO_MULTIPLIER, screenHeight/2)

    -- Part selection form
    do
        self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Vehicle shop", false, true, self)
        self.m_PartsList = GUIGridList:new(0, self.m_Height*0.21, self.m_Width, self.m_Height*0.72, self.m_Window)
        self.m_PartsList:addColumn(_"Name", 1)
        GUIImage:new(0, 30, self.m_Width, self.m_Height/7, "files/images/TuningHeader.png", self.m_Window)
        GUILabel:new(0, self.m_Height-self.m_Height/14, self.m_Width, self.m_Height/14, "↕", self.m_Window):setAlignX("center")
        GUIRectangle:new(0, self.m_Height*0.93, self.m_Width, self.m_Height*0.005, Color.LightBlue, self.m_Window)
    end

    -- Upgrade selection rect
    do
        local width, height = 500, 60
        self.m_UpgradeChanger = GUIChanger:new(screenWidth/2-width/2, screenHeight-20-height, width, height)
        self.m_UpgradeChanger.onChange = bind(self.UpgradeChanger_Change, self)
        self.m_AddToCartButton = GUIButton:new(screenWidth/2-width/2 + width + 3, screenHeight-20-height, height, height, FontAwesomeSymbols.CartPlus)
            :setFont(FontAwesome(height*0.8))
            :setFontSize(1)
        self.m_AddToCartButton.onLeftClick = bind(self.AddToCartButton_Click, self)
    end

    -- Shopping cart form
    do
        local width, height = screenWidth*0.2, screenHeight*0.35
        self.m_ShoppingCartWindow = GUIWindow:new(screenWidth*0.76, screenHeight*0.3, width, height, _"Warenkorb", true, false)
        self.m_ShoppingCartGrid = GUIGridList:new(0, 30, width, height*0.9, self.m_ShoppingCartWindow)
            :addColumn(_"Upgrade", 0.7)
            :addColumn(_"Preis", 0.3)
        self.m_PriceLabel = GUILabel:new(width*0.02, height*0.9, width*0.5, height*0.1, "", self.m_ShoppingCartWindow)
        self.m_BuyButton = GUIButton:new(width*0.6, height*0.9, width*0.4, height*0.1, _"Kaufen", self.m_ShoppingCartWindow):setBackgroundColor(Color.Green)
    end

    self.m_CartContent = {}
    self.m_Vehicle = vehicle
    self:initPartsList()
    self:moveCameraToSlot(7, true)
    self:updatePrices()
    showChat(false)

    self.m_Music = Sound.create("https://jusonex.net/public/saonline/Audio/GarageMusic.mp3", true)
end

function VehicleTuningGUI:destructor()
    setCameraTarget(localPlayer)
    if self.m_Music then
        self.m_Music:destroy()
    end
    delete(self.m_UpgradeChanger)
    delete(self.m_PutIntoCartButton)
    showChat(true)

    GUIForm.destructor(self)
end

function VehicleTuningGUI:initPartsList()
    for slot = 0, 16 do
        if slot ~= 10 and slot ~= 11 then -- Exclude Stereo and Unknown
            local compatibleUpgrades = getVehicleCompatibleUpgrades(self.m_Vehicle, slot)
            if #compatibleUpgrades > 0 then
                local name = getVehicleUpgradeSlotName(slot)
                local item = self.m_PartsList:addItem(name)
                item.PartSlot = slot
                item.onLeftClick = bind(self.PartItem_Click, self)
            end
        end
    end
end

function VehicleTuningGUI:updateUpgradeList(slot)
    local upgrades = getVehicleCompatibleUpgrades(self.m_Vehicle, slot)
    self.m_UpgradeIdMapping = {}
    self.m_UpgradeChanger:clear()

    -- Add compatible upgrades
    for k, upgradeId in pairs(upgrades) do
        local rowId = self.m_UpgradeChanger:addItem(tostring(getVehicleUpgradeNameFromID(upgradeId)))
        self.m_UpgradeIdMapping[rowId] = upgradeId
    end

    -- Add no upgrade
    local rowId = self.m_UpgradeChanger:addItem(_"Standard")
    self.m_UpgradeIdMapping[rowId] = 0 -- 0 stands for standard
end

function VehicleTuningGUI:moveCameraToSlot(slot, noAnimation)
    local targetPosition = self.CameraPositions[slot]
    local targetLookAtPosition = self.m_Vehicle:getPosition()
    if type(targetPosition) == "table" then
        targetPosition, targetLookAtPosition = unpack(targetPosition)
        targetLookAtPosition = self.m_Vehicle.matrix:transformPosition(targetLookAtPosition)
    end

    local oldX, oldY, oldZ, oldLookX, oldLookY, oldLookZ = getCameraMatrix()
    local progress = 0

    if noAnimation then
        progress = 1
    end

    addEventHandler("onClientPreRender", root,
        function(deltaTime)
            progress = progress + deltaTime * 0.0006
            local x, y, z = interpolateBetween(oldX, oldY, oldZ, self.m_Vehicle.matrix:transformPosition(targetPosition), progress, "InOutBack")
            local lx, ly, lz = interpolateBetween(oldLookX, oldLookY, oldLookZ, targetLookAtPosition, progress, "Linear")
            setCameraMatrix(x, y, z, lx, ly, lz)

            if progress >= 1 then
                removeEventHandler("onClientPreRender", root, getThisFunction())
            end
        end
    )
end

function VehicleTuningGUI:updatePrices()
    local overallPrice = 0
    for slot, upgradeId in pairs(self.m_CartContent) do
        if upgradeId then
            -- Get price from price table
            local price = getVehicleUpgradePrice(upgradeId)
            assert(price, "Invalid price for upgrade "..tostring(upgradeId))
            overallPrice = overallPrice + price
        end
    end

    self.m_PriceLabel:setText(_("Preis: %d$", overallPrice))
end

function VehicleTuningGUI:PartItem_Click(item)
    self:moveCameraToSlot(item.PartSlot)
    if item.PartSlot then
        self:updateUpgradeList(item.PartSlot)
    end
end

function VehicleTuningGUI:UpgradeChanger_Change(text, index)
    local upgradeId = self.m_UpgradeIdMapping[index]
    if upgradeId then
        if upgradeId ~= 0 then
            self.m_Vehicle:addUpgrade(upgradeId)
        else
            -- Remove the upgrade
            local selectedPartItem = self.m_PartsList:getSelectedItem()
            if selectedPartItem and selectedPartItem.PartSlot then
                local upgradeId = getVehicleUpgradeOnSlot(self.m_Vehicle, selectedPartItem.PartSlot)
                if upgradeId then
                    self.m_Vehicle:removeUpgrade(upgradeId)
                end
            end
        end
    end
end

function VehicleTuningGUI:AddToCartButton_Click()
    local selectedPartItem = self.m_PartsList:getSelectedItem()
    local upgradeName, changerIndex = self.m_UpgradeChanger:getIndex()

    if selectedPartItem and selectedPartItem.PartSlot and changerIndex and self.m_UpgradeIdMapping[changerIndex] then
        local slot = selectedPartItem.PartSlot
        local partName = selectedPartItem:getColumnText(1)

        -- Remove upgrade if already exists for tihs slot
        if self.m_CartContent[slot] then
            for rowId, item in pairs(self.m_ShoppingCartGrid:getItems()) do
                if item.PartSlot == slot then
                    self.m_ShoppingCartGrid:removeItem(rowId)
                    break
                end
            end
        end

        local upgradeId = self.m_UpgradeIdMapping[changerIndex]
        self.m_CartContent[slot] = upgradeId ~= 0 and upgradeId or false

        -- Get price from price table
        local price = getVehicleUpgradePrice(upgradeId)
        if upgradeId == 0 then -- Standard parts are free
            price = 0
        end

        local item = self.m_ShoppingCartGrid:addItem(partName..": "..upgradeName, tostring(price).."$")
        item.PartSlot = slot

        -- Update overall costs
        self:updatePrices()
    end
end

VehicleTuningGUI.CameraPositions = {
    [0] = Vector3(0, 5.6, 1.5), -- Hood
    [1] = Vector3(0, 4.76, 0.35), -- Vent
    [2] = Vector3(1.8, -5, 1.6), -- Spoiler
    [3] = Vector3(5, 0, 0.5), -- Sideskirt
    [4] = Vector3(0, 5.8, 0.2), -- Front bullbars
    [5] = Vector3(0, -6, 0.2), -- Rear bullbars
    [6] = Vector3(0, 5.6, 1), -- Headlights
    [7] = Vector3(4.2, 2.1, 2.1), -- Roof
    [8] = Vector3(0.5, -4.9, 2.2), -- Nitro
    [9] =  {Vector3(3.2, -1.7, 0), Vector3(-96.7, -4.7, 0)}, -- Hydraulics
    [10] = Vector3(0, 0, 0), -- Stereo
    [11] = Vector3(4.2, 2.1, 2.1), -- Unkonwn
    [12] = {Vector3(3.2, -1.7, 0), Vector3(-96.7, -4.7, 0)}, -- Wheels
    [13] = Vector3(0, -5, 0), -- Exhaust
    [14] = Vector3(0, 5.8, 0.2), -- Front Bumper
    [15] = Vector3(0, -6, 0.2), -- Rear Bumper
    [16] = Vector3(4.2, 2.1, 2.1), -- Misc
}

-- A piece of debug code | TODO: Remove soon
if DEBUG then
    local tuningGUI = false

    addCommandHandler("setvehicle",
        function(cmd, id)
            id = tonumber(id)
            if not id or id < 1 or id > 3 then
                return
            end

            if tuningGUI then
                delete(tuningGUI)
            end
            tuningGUI = VehicleTuningGUI:new(getElementByID("TuningVehicle"..id))
        end
    )
end
