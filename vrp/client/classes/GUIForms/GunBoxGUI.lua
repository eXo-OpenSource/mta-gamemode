-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/GunBoxGUI.lua
-- *  PURPOSE:     GunBox GUI
-- *
-- ****************************************************************************
GunBoxGUI = inherit(GUIForm)
inherit(Singleton, GunBoxGUI)

addRemoteEvents{"openGunBox", "receiveGunBoxData"}

function GunBoxGUI:constructor()
    GUIForm.constructor(self, screenWidth/2-620/2, screenHeight/2-400/2, 620, 400)

    self.ms_SlotsSettings = {
        ["weapon"] = {["color"] = Color.Orange, ["btnColor"] = Color.Red, ["emptyText"] = _"Keine Waffe"}
    }

    self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Waffenbox", true, true, self)
	self.m_Window:deleteOnClose(true)
    GUILabel:new(10, 35, 340, 35, _"Deine Waffen:", self.m_Window)
    self.m_LoadingLabel = GUILabel:new(10, 70, 250, 250, _"wird geladen...", self.m_Window):setAlignX("center"):setAlignY("center"):setFontSize(1):setFont(VRPFont(20))
    self.m_MyWeaponsGrid = GUIGridList:new(10, 70, 250, 250, self.m_Window)
    self.m_MyWeaponsGrid:addColumn(_"Waffe", 0.7)
    self.m_MyWeaponsGrid:addColumn(_"Munition", 0.3)
    self.m_MyWeaponsGrid:setVisible(false)

    GUILabel:new(320, 35, 340, 35, _"Waffenbox:", self.m_Window)
    GUILabel:new(320, 70, 340, 25, _"Items:", self.m_Window)

    self.m_WeaponSlots = {}
	self:addSlot(1, 320, 100)
    self:addSlot(2, 470, 100)
    self:addSlot(3, 320, 175)
    self:addSlot(4, 470, 175)
    self:addSlot(5, 320, 250)
    self:addSlot(6, 470, 250)

    self.m_ToBox = GUIButton:new(275, 70, 30, 250, FontAwesomeSymbols.Right, self.m_Window)
    self.m_ToBox:setEnabled(false)
    self.m_ToBox:setFont(FontAwesome(15)):setFontSize(1)
    self.m_ToBox:setBarEnabled(false)
    self.m_ToBox:setBackgroundColor(Color.Accent)

    self.m_ToBox.onLeftClick = function() self:ToBox() end
    self:loadPlayerWeapons()

	triggerServerEvent("requestGunBoxData", localPlayer)

	addEventHandler("receiveGunBoxData", root, bind(self.refreshData, self))
end

function GunBoxGUI:addSlot(id, posX, posY)
    self.m_WeaponSlots[id] = {}
    self.m_WeaponSlots[id].Rectangle = GUIRectangle:new(posX, posY, 140, 70, self.ms_SlotsSettings["weapon"].color, self.m_Window)
    self.m_WeaponSlots[id].RectangleImage = GUIRectangle:new(posX+5, posY+10, 50, 50, tocolor(0,0,0,200), self.m_Window)
    self.m_WeaponSlots[id].Image = GUIImage:new(posX+10, posY+15, 40, 40, "files/images/Other/noImg.png", self.m_Window)
    self.m_WeaponSlots[id].Label = GUILabel:new(posX+60, posY+5, 70, 20, self.ms_SlotsSettings["weapon"].emptyText, self.m_Window):setFontSize(1)
    self.m_WeaponSlots[id].Amount = GUILabel:new(posX+60, posY+25, 70, 20, "", self.m_Window):setFontSize(1)
    self.m_WeaponSlots[id].TakeButton = GUIButton:new(posX+60, posY+45, 70, 20, FontAwesomeSymbols.Left, self.m_Window):setFont(FontAwesome(15)):setFontSize(1):setBackgroundColor(self.ms_SlotsSettings["weapon"].btnColor)
    self.m_WeaponSlots[id].TakeButton:setEnabled(false)
    self.m_WeaponSlots[id].TakeButton.onLeftClick = function() self:fromBox(id) end

    if id > 3 and not localPlayer:isPremium() then
        self.m_WeaponSlots[id].Image:setImage("files/images/Other/premium.png")
    end
end

function GunBoxGUI:loadPlayerWeapons()
    self.m_MyWeaponsGrid:clear()
    for i = 0, 12 do
		local weaponId = getPedWeapon(localPlayer, i)
		if weaponId and weaponId ~= 0 then
            local item = self.m_MyWeaponsGrid:addItem(WEAPON_NAMES[weaponId], getPedTotalAmmo(localPlayer, i))
            item.onLeftClick = function()
                self.m_SelectedItem = weaponId
                self.m_SelectedItemAmount = getPedTotalAmmo(localPlayer, i)
                self.m_ToBox:setEnabled(true)
                self:checkAmount()
            end
		end
	end
    self.m_MyWeaponsGrid:setVisible(true)
    self.m_LoadingLabel:setVisible(false)
end

function GunBoxGUI:refreshData(weapons)
    for index, weapon in pairs(weapons) do
		index = tonumber(index)
		if self.m_WeaponSlots[index] then
            if index <= 3 or index > 3 and localPlayer:isPremium() then
    			if weapon["WeaponId"] > 0 then
    	            local weaponName = WEAPON_NAMES[weapon["WeaponId"]]
    	            self.m_WeaponSlots[index].Label:setText(weaponName:len() <= 6 and weaponName or ("%s (...)"):format(weaponName:sub(1, 6)))
    	            self.m_WeaponSlots[index].Amount:setText(_("%d Schuss", weapon["Amount"]))
    	            self.m_WeaponSlots[index].Image:setImage(FileModdingHelper:getSingleton():getWeaponImage(weapon.WeaponId))
    	            self.m_WeaponSlots[index].TakeButton:setEnabled(true)
    	        else
    	            self.m_WeaponSlots[index].Label:setText(self.ms_SlotsSettings["weapon"].emptyText)
    	            self.m_WeaponSlots[index].Amount:setText("")
    	            self.m_WeaponSlots[index].Image:setImage("files/images/Other/noImg.png")
    	            self.m_WeaponSlots[index].TakeButton:setEnabled(false)
    	        end
            else
                self.m_WeaponSlots[index].TakeButton:setEnabled(false)
                self.m_WeaponSlots[index].Amount:setText("")
                self.m_WeaponSlots[index].Label:setText("Keine Waffe")
                self.m_WeaponSlots[index].Image:setImage("files/images/Other/premium.png")
            end
		end
    end
    setTimer(function()
        self:loadPlayerWeapons()
        self.m_MyWeaponsGrid:setVisible(true)
        self.m_LoadingLabel:setVisible(false)
    end, 100, 1)
end

function GunBoxGUI:checkAmount(text)
    self.m_ToBox:setEnabled(true)
    return
end

function GunBoxGUI:ToBox()
    triggerServerEvent("gunBoxAddWeapon", localPlayer, self.m_SelectedItem, self.m_SelectedItemAmount)
end

function GunBoxGUI:fromBox(id)
    if self.m_WeaponSlots[id].Label:getText() ~= self.ms_SlotsSettings["weapon"].emptyText then
        triggerServerEvent("gunBoxTakeWeapon", localPlayer, id)
        self.m_MyWeaponsGrid:setVisible(false)
        self.m_LoadingLabel:setVisible(true)
    else
        ErrorBox:new(_"In diesem Slot ist keine Waffe!")
    end
end

addEventHandler("openGunBox", root, function()
    if GunBoxGUI:getSingleton():isInstantiated() then
        GunBoxGUI:getSingleton():open()
    else
        GunBoxGUI:getSingleton():new()
    end
end)
