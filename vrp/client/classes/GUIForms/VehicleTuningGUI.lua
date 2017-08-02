-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/VehicleTuningGUI.lua
-- *  PURPOSE:     Vehicle tuning garage class
-- *
-- ****************************************************************************
VehicleTuningGUI = inherit(GUIForm)
addRemoteEvents{"vehicleTuningShopEnter", "vehicleTuningShopExit"}


function VehicleTuningGUI:constructor(vehicle, specialType)
    GUIForm.constructor(self, 10, 10, screenWidth/5/ASPECT_RATIO_MULTIPLIER, screenHeight/2)

    -- Part selection form
    do
        self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Fahrzeug-Tuning", false, true, self)
        self.m_PartsList = GUIGridList:new(0, self.m_Height*0.21, self.m_Width, self.m_Height*0.72, self.m_Window)
        self.m_PartsList:addColumn(_"Name", 1)
        self.m_MuteSound = GUILabel:new(self.m_Width-55, 5, 28, 28, FontAwesomeSymbols.SoundOn, self):setFont(FontAwesome(22))
		self.m_MuteSound.onLeftClick = function()
			if self.m_Music then
				self.m_Music:destroy()
				self.m_Music = nil
				self.m_MuteSound:setText(FontAwesomeSymbols.SoundOff)
			else
				self.m_Music = Sound.create("http://exo-reallife.de/ingame/GarageMusic.mp3", true)
				self.m_MuteSound:setText(FontAwesomeSymbols.SoundOn)
			end

		end

		GUIImage:new(0, 30, self.m_Width, self.m_Height/7, "files/images/Shops/TuningHeader.png", self.m_Window)
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
        self.m_ShoppingCartGrid = GUIGridList:new(0, 30, width, height*0.79, self.m_ShoppingCartWindow)
            :addColumn(_"Upgrade", 0.7)
            :addColumn(_"Preis", 0.3)
        self.m_PriceLabel = GUILabel:new(width*0.02, height*0.9, width*0.5, height*0.1, "", self.m_ShoppingCartWindow)
        self.m_ClearButton = GUIButton:new(width*0.65-height*0.12, height*0.9, height*0.1, height*0.1, FontAwesomeSymbols.Trash, self.m_ShoppingCartWindow):setFont(FontAwesome(15)):setBackgroundColor(Color.Red)
        self.m_ClearButton.onLeftClick = bind(self.ClearButton_Click, self)
		self.m_BuyButton = GUIButton:new(width*0.65, height*0.9, width*0.35, height*0.1, _"Kaufen", self.m_ShoppingCartWindow):setBackgroundColor(Color.Green)
        self.m_BuyButton.onLeftClick = bind(self.BuyButton_Click, self)
    end

	self.m_SpecialType = specialType or ""

    self.m_CartContent = {}
    self.m_Vehicle = vehicle
    self:initPartsList()
    setTimer(function() self:moveCameraToSlot(7, true) end, 100, 1)
    self:updatePrices()
    showChat(false)

	self.m_OldTuning = VehicleTuning:new(vehicle)

	self.m_NewTuning = VehicleTuning:new(vehicle)

    self.m_Music = Sound.create("http://exo-reallife.de/ingame/GarageMusic.mp3", true)
	self.m_CarRadioVolume = RadioGUI:getSingleton():getVolume() or 0
	RadioGUI:getSingleton():setVolume(0)
    self.m_Vehicle:setOverrideLights(2)
end

function VehicleTuningGUI:destructor(closedByServer)
    if not closedByServer then
        self:emptyCart()
        self:resetUpgrades(true)-- Tell the server that we do not want to upgrade anything
        triggerServerEvent("vehicleUpgradesAbort", localPlayer)
    end

    setCameraTarget(localPlayer)
    if self.m_Music then
        self.m_Music:destroy()
    end
    delete(self.m_UpgradeChanger)
    delete(self.m_AddToCartButton)
    delete(self.m_ShoppingCartWindow)
    self:closeAllWindows()
    self.m_Vehicle:setOverrideLights(0)
    showChat(true)
	RadioGUI:getSingleton():setVolume(self.m_CarRadioVolume)

    GUIForm.destructor(self)
end

function VehicleTuningGUI:closeAllWindows()
    if self.m_ColorPicker then delete(self.m_ColorPicker) end
    if self.m_TexturePicker then delete(self.m_TexturePicker) end
    if self.m_VehicleShader then delete(self.m_VehicleShader) end
    if self.m_HornPicker then delete(self.m_HornPicker) end
	if self.m_NeonPicker then delete(self.m_NeonPicker) end
end

function VehicleTuningGUI:initPartsList()
    -- Add 'special properties' (e.g. color)
    for id, data in ipairs(VehicleTuningGUI.SpecialTunings) do
        local partName, partData = unpack(data)
		if self.m_SpecialType ~= "AirportPainter" or (partData == "Color1" or partData == "Color2") then
        	local item = self.m_PartsList:addItem(partName)
        	item.PartSlot = partData
        	item.onLeftClick = bind(self.PartItem_Click, self)
		end
    end

    -- Add upgrades
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

    -- Add no upgrade
    local rowId = self.m_UpgradeChanger:addItem(_"Standard")
    self.m_UpgradeIdMapping[rowId] = 0 -- 0 stands for standard

    -- Add compatible upgrades
    for k, upgradeId in pairs(upgrades) do
		if not (self.m_Vehicle:getModel() == 560 and upgradeId == 1164) then	-- Buggy spoiler for Sultan (invisible after reconnect)
			local rowId = self.m_UpgradeChanger:addItem(tostring(getVehicleUpgradeNameFromID(upgradeId)))
			self.m_UpgradeIdMapping[rowId] = upgradeId
		end
    end
end

function VehicleTuningGUI:moveCameraToSlot(slot, noAnimation)
	local slot = self.m_SpecialType == "AirportPainter" and "AirportPainter" or slot
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
			if localPlayer.m_inTuning  then
				progress = progress + deltaTime * 0.0006
				local x, y, z = interpolateBetween(oldX, oldY, oldZ, self.m_Vehicle.matrix:transformPosition(targetPosition), progress, "InOutBack")
				local lx, ly, lz = interpolateBetween(oldLookX, oldLookY, oldLookZ, targetLookAtPosition, progress, "Linear")
				setCameraMatrix(x, y, z, lx, ly, lz)

				if progress >= 1 then
					removeEventHandler("onClientPreRender", root, getThisFunction())
				end
			else
				removeEventHandler("onClientPreRender", root, getThisFunction())
			end
		end)
end

function VehicleTuningGUI:updatePrices()
    local overallPrice = 0
    for slot, upgradeId in pairs(self.m_CartContent) do
        if upgradeId ~= 0 then
            -- Get price from price table
            local price = getVehicleUpgradePrice(upgradeId)
            -- If no price is available, search for the part price instead
			if not price then
				price = getVehicleUpgradePrice(slot)
				if not price then
					price = 0
				else
					if not tonumber(price) then
						price = 0
					end
				end
			else
				if not tonumber(price) then
					price = getVehicleUpgradePrice(slot)
					if not price then
						price = 0
					else
						if not tonumber(price) then
							price = 0
						end
					end
				end
			end

            assert(price, "Invalid price for upgrade "..tostring(upgradeId))
            overallPrice = overallPrice + price
        end
    end

    self.m_PriceLabel:setText(_("Preis: %d$", overallPrice))
end

function VehicleTuningGUI:resetUpgrades(reset)
    if self.m_PreviewShader then delete(self.m_PreviewShader) end

    if reset then
		self.m_OldTuning:applyTuning()
	else
		self.m_NewTuning:applyTuning()
	end
end

function VehicleTuningGUI:addPartToCart(partId, partName, info, upgradeName)
    -- Remove upgrade if already exists for this slot
    if self.m_CartContent[partId] then
        for rowId, item in pairs(self.m_ShoppingCartGrid:getItems()) do
            if item.PartSlot == partId then
                self.m_ShoppingCartGrid:removeItem(rowId)
                break
            end
        end
    end

    -- Get price from price table
    local price =  getVehicleUpgradePrice(info)
    -- If no price is available, search for the part price instead
    if not price then
		price = getVehicleUpgradePrice(partId)
		if not price then
			price = 0
		else
			if not tonumber(price) then
				price = 0
			end
		end
	else
		if not tonumber(price) then
			price = getVehicleUpgradePrice(partId)
			if not price then
				price = 0
			else
				if not tonumber(price) then
					price = 0
				end
			end
		end
    end

    if partId == "Neon" and info == 0 then
        price = 0
        partName = "Neon-Ausbau"
    end

    local name = upgradeName and partName..": "..upgradeName or partName
    local item = self.m_ShoppingCartGrid:addItem(name, tostring(price).."$")
    item.PartSlot = partId

    -- Add item to cart now
    self.m_CartContent[partId] = info

    -- Update overall costs
    self:updatePrices()
end

function VehicleTuningGUI:emptyCart()
    self.m_CartContent = {}
end

function VehicleTuningGUI:PartItem_Click(item)
    self:resetUpgrades()
    self.m_UpgradeChanger:setVisible(true)
    self.m_AddToCartButton:setVisible(true)

    self:closeAllWindows()
    self:moveCameraToSlot(item.PartSlot)

    if item.PartSlot then
        -- Check for special properties
        if item.PartSlot == "Color1" then
            self.m_UpgradeChanger:setVisible(false)
            self.m_AddToCartButton:setVisible(false)
           	local r2, g2, b2 = unpack(self.m_NewTuning:getTuning("Color2"))

			self.m_ColorPicker = ColorPicker:new(
            function(r, g, b)
                self.m_NewTuning:saveTuning(item.PartSlot, {r, g, b})
				self.m_NewTuning:applyTuning()
				self:addPartToCart(item.PartSlot, VehicleTuningGUI.SpecialTuningsNames[item.PartSlot], {r, g, b}) end,
                    function(r, g, b)
						self.m_Vehicle:setColor(r, g, b, r2, g2, b2)
                    end
            )
            self.m_ColorPicker:setColor(unpack(self.m_NewTuning:getTuning(item.PartSlot)))
            return
        elseif item.PartSlot == "Color2" then
            self.m_UpgradeChanger:setVisible(false)
            self.m_AddToCartButton:setVisible(false)
			local r1, g1, b1 = unpack(self.m_NewTuning:getTuning("Color1"))

            self.m_ColorPicker = ColorPicker:new(
            function(r, g, b)
                self.m_NewTuning:saveTuning(item.PartSlot, {r, g, b})
				self.m_NewTuning:applyTuning()
				self:addPartToCart(item.PartSlot, VehicleTuningGUI.SpecialTuningsNames[item.PartSlot], {r, g, b}) end,
                    function(r, g, b)
						self.m_Vehicle:setColor(r1, g1, b1, r, g, b)
                    end
            )
            self.m_ColorPicker:setColor(unpack(self.m_NewTuning:getTunings()[item.PartSlot]))
            return
        elseif item.PartSlot == "ColorLight" then
            self.m_UpgradeChanger:setVisible(false)
            self.m_AddToCartButton:setVisible(false)
            self.m_ColorPicker = ColorPicker:new(
            function(r, g, b)
                self.m_NewTuning:saveTuning(item.PartSlot, {r, g, b})
				self.m_NewTuning:applyTuning()
				self:addPartToCart(item.PartSlot, VehicleTuningGUI.SpecialTuningsNames[item.PartSlot], {r, g, b}) end,
                    function(r, g, b)
                        self.m_Vehicle:setHeadLightColor(r, g, b)
                    end
            )
            self.m_ColorPicker:setColor(unpack(self.m_NewTuning:getTuning(item.PartSlot)))
            return
        elseif item.PartSlot == "Neon" then
            self.m_UpgradeChanger:setVisible(false)
            self.m_AddToCartButton:setVisible(false)
            self.m_NeonPicker = VehicleTuningItemGrid:new(
                "Neonröhren ein/ausbauen",
                {[0] = _"Keine Neonröhre", [1] = _"Neonröhre einbauen"},
                function(neon)
					self.m_NewTuning:saveTuning(item.PartSlot, neon == 1)
					self.m_NewTuning:applyTuning()
					self:addPartToCart(item.PartSlot, VehicleTuningGUI.SpecialTuningsNames[item.PartSlot], neon)
                end,
                function(neon)
                    if neon == 1 then
                        setElementData(self.m_Vehicle, "Neon", true)
                        setElementData(self.m_Vehicle, "NeonColor", {255,0,0})
                        Neon.Vehicles[self.m_Vehicle] = true
                    else
                        setElementData(self.m_Vehicle, "Neon", false)
                        setElementData(self.m_Vehicle, "NeonColor", {0,0,0})
                        if Neon.Vehicles[self.m_Vehicle] then
                            Neon.Vehicles[self.m_Vehicle] = nil
                        end
                    end
                end
            )
            return
        elseif item.PartSlot == "NeonColor" then
            if not self.m_NewTuning:getTuning("Neon") then
				ErrorBox:new(_"Du hast keine Neonröhren eingebaut!")
				return
			end
			self.m_UpgradeChanger:setVisible(false)
            self.m_AddToCartButton:setVisible(false)
            self.m_ColorPicker = ColorPicker:new(
				function(r, g, b)
					self.m_NewTuning:saveTuning(item.PartSlot, {r, g, b})
					self.m_NewTuning:applyTuning()
				self:addPartToCart(item.PartSlot, VehicleTuningGUI.SpecialTuningsNames[item.PartSlot], {r, g, b}) end,
				function(r, g, b)
					setElementData(self.m_Vehicle, "NeonColor", {r, g, b})
				end)
            if self.m_NewTuning:getTuning(item.PartSlot) and type(self.m_NewTuning:getTuning(item.PartSlot)) == "table" then
				self.m_ColorPicker:setColor(unpack(self.m_NewTuning:getTuning(item.PartSlot)))
			end
            return
        elseif item.PartSlot == "CustomHorn" then
            self.m_UpgradeChanger:setVisible(false)
            self.m_AddToCartButton:setVisible(false)
            local horns = {}
            horns[1] = _"Keine"
            for i=2, 61 do horns[i] = _("Hupe %d", i-1) end
            self.m_HornPicker = VehicleTuningItemGrid:new(
                "Hupe auswählen",
                horns,
                function (horn)
                    self.m_NewTuning:saveTuning(item.PartSlot, horn-1)
					self.m_NewTuning:applyTuning()
					self:addPartToCart(item.PartSlot, VehicleTuningGUI.SpecialTuningsNames[item.PartSlot], horn-1)
                end,
                function (horn)
                    if isElement(self.m_CustomHornSound) then destroyElement(self.m_CustomHornSound) end
                    if horn ~= 1 then
                        local playhorn = horn-1
                        self.m_CustomHornSound = playSound("files/audio/Horns/"..playhorn..".mp3")
                    end
                end
            )
            return
        elseif item.PartSlot == "Texture" then
			--[[Disabled
            self.m_UpgradeChanger:setVisible(false)
            self.m_AddToCartButton:setVisible(false)
            self.m_TexturePicker = VehicleTuningItemGrid:new(
                "Select Texture",
                {"None", _"Line", _"DiagonalRally", _"RallyStripes", _"ZebraStripes"},
                function (texture)
                    if self.m_PreviewShader then delete(self.m_PreviewShader) end
					TextureReplacer.deleteFromElement(self.m_Vehicle)
					if texture > 1 then
						self.m_NewTuning:saveTuning(item.PartSlot, "files/images/Textures/Special/"..(texture-1)..".png")
						self:addPartToCart(item.PartSlot, VehicleTuningGUI.SpecialTuningsNames[item.PartSlot], "files/images/Textures/Special/"..(texture-1)..".png")
					else
						self.m_NewTuning:saveTuning(item.PartSlot, "")
						self:addPartToCart(item.PartSlot, VehicleTuningGUI.SpecialTuningsNames[item.PartSlot], "")
					end
					self.m_NewTuning:applyTuning()
                end,
                function (texture)
                    if self.m_PreviewShader then delete(self.m_PreviewShader) end
					TextureReplacer.deleteFromElement(self.m_Vehicle)
					if texture ~= 1 then
                        self.m_PreviewShader = TextureReplace:new(self.m_Vehicle:getTextureName(), "files/images/Textures/Special/"..(texture-1)..".png", false, 250, 250, self.m_Vehicle)
                    end
                end
            )
			Disabled --]]
            return
        end
		self:resetUpgrades()
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
	self.m_NewTuning:saveGTATuning()
end

function VehicleTuningGUI:AddToCartButton_Click()
    local selectedPartItem = self.m_PartsList:getSelectedItem()
    local upgradeName, changerIndex = self.m_UpgradeChanger:getIndex()

    if selectedPartItem and selectedPartItem.PartSlot and changerIndex and self.m_UpgradeIdMapping[changerIndex] then
        local slot = selectedPartItem.PartSlot
        local partName = selectedPartItem:getColumnText(1)
        local upgradeId = self.m_UpgradeIdMapping[changerIndex]

        -- Add to cart
        self:addPartToCart(slot, partName, upgradeId, upgradeName)
    end
end

function VehicleTuningGUI:ClearButton_Click()
	self:emptyCart()
	self:resetUpgrades(true)
	self.m_ShoppingCartGrid:clear()
	self:updatePrices()
end

function VehicleTuningGUI:BuyButton_Click()
	if table.size(self.m_CartContent) > 0 then
    	triggerServerEvent("vehicleUpgradesBuy", localPlayer, self.m_CartContent)
	else
		VehicleTuningGUI.Exit()
	end
end

local vehicleTuningShop = false
addEventHandler("vehicleTuningShopEnter", root,
    function(vehicle, specialType)
        if vehicleTuningShop then
            delete(vehicleTuningShop)
        end

        vehicleTuningShop = VehicleTuningGUI:new(vehicle, specialType)

        vehicle:setDimension(PRIVATE_DIMENSION_CLIENT)
        localPlayer:setDimension(PRIVATE_DIMENSION_CLIENT)
		localPlayer.m_inTuning = true
    end
)

function VehicleTuningGUI.Exit(closedByServer)
	if vehicleTuningShop then
		vehicleTuningShop.m_Vehicle:setDimension(0)
		localPlayer:setDimension(0)

		delete(vehicleTuningShop, closedByServer)
		vehicleTuningShop = false
		localPlayer.m_inTuning = false
		setCameraTarget(localPlayer)
	end
end
addEventHandler("vehicleTuningShopExit", root, function() VehicleTuningGUI.Exit(true) end)


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

    -- Special properties
    ["Color1"] = Vector3(4.2, 2.1, 2.1),
    ["Color2"] = Vector3(4.2, 2.1, 2.1),
    ["ColorLight"] = Vector3(0, 5.6, 1),
    --["Texture"] = Vector3(4.2, 2.1, 2.1),
    ["CustomHorn"] = Vector3(4.2, 2.1, 2.1),
    ["Neon"] = Vector3(4.2, 2.1, 2.1),
    ["NeonColor"] = Vector3(4.2, 2.1, 2.1),

	["AirportPainter"] = Vector3(7, 7, 2.1),

}

VehicleTuningGUI.SpecialTunings = {
	{"Farbe", "Color1"},
	{"Farbe 2", "Color2"},
	{"Licht-Farbe", "ColorLight"},
	{"Neonröhren", "Neon"},
	{"Neonröhren-Farbe", "NeonColor"},
	{"Spezial-Hupe", "CustomHorn"},
	--{"Spezial-Lackierung", "Texture"},
}

VehicleTuningGUI.SpecialTuningsNames = {}

for index, value in pairs(VehicleTuningGUI.SpecialTunings) do
	VehicleTuningGUI.SpecialTuningsNames[value[2]] = value[1]
end
