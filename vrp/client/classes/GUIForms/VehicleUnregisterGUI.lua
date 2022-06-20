-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/VehicleUnregisterGUI.lua
-- *  PURPOSE:     Skyscraper GUI
-- *
-- ****************************************************************************
VehicleUnregisterGUI = inherit(GUIForm)
inherit(Singleton, VehicleUnregisterGUI)
addRemoteEvents{"sendRegisteredVehicleList"}

function VehicleUnregisterGUI:constructor(rangeElement)
    GUIForm.constructor(self, screenWidth/2-screenWidth*0.3*0.5, screenHeight/2-screenHeight*0.4*0.5, screenWidth*0.4, screenHeight*0.45, true, false, rangeElement)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Fahrzeug an/abmelden", true, true, self)
    self.m_UnregisterButton = GUIButton:new(self.m_Width*0.66, self.m_Height*0.09, 200, 50, "Abmelden", self.m_Window):setBackgroundColor(Color.Green)
    self.m_UnregisterButton.onLeftClick = bind(self.unregistereButton_Click, self)
    self.m_InfoButton = GUIButton:new(self.m_Width*0.66, self.m_Height*0.22, 200, 50, _"Information", self.m_Window):setBackgroundColor(Color.Blue)
    self.m_InfoButton.onLeftClick = bind(self.infoButton_Click, self)

    triggerServerEvent("requestVehicles", localPlayer)
    addEventHandler("sendRegisteredVehicleList", localPlayer, bind(self.updateList, self))
end

function VehicleUnregisterGUI:unregistereButton_Click()
    if not self.m_VehicleListGrid:getSelectedItem() then return end
    local vehicle = self.m_VehicleListGrid:getSelectedItem().id
    if self.m_UnregisterButton:getText() == "Abmelden" then
        QuestionBox:new("Bist du sicher, dass du dein Fahrzeug abmelden möchtest? Du kannst es dann erst in 3 Tagen wieder anmelden. Außerdem wird eine Gebühr von 500$ abgebucht.", 
            function()
                triggerServerEvent("onToggleVehicleRegister", vehicle, "unregister")
                triggerServerEvent("requestVehicles", localPlayer)
            end,
            function() end,
            localPlayer:getPosition()
        )
    else
        triggerServerEvent("onToggleVehicleRegister", vehicle, "register")
        triggerServerEvent("requestVehicles", localPlayer)
    end
end

function VehicleUnregisterGUI:infoButton_Click()
    if not self.m_VehicleListGrid:getSelectedItem() then return end
    local vehicle = self.m_VehicleListGrid:getSelectedItem().id
    local timestamp = self.m_VehicleListGrid:getSelectedItem().registered
    if timestamp == 0 then
        ShortMessage:new(_("Das Fahrzeug %s ist nicht abgemeldet.", vehicle:getName()))
    else
        ShortMessage:new(("Du kannst das Fahrzeug am %s um %s wieder abholen."):format(os.date("%d.%m.%Y", timestamp), os.date("%H:%M", timestamp)))
    end
end

function VehicleUnregisterGUI:updateList(vehicles)
    if self.m_VehicleListGrid then delete(self.m_VehicleListGrid) end
    self.m_VehicleListGrid = GUIGridList:new(self.m_Width*0.03, self.m_Height*0.09, self.m_Width*0.6, self.m_Height*0.88, self.m_Window)
	self.m_VehicleListGrid:addColumn(_"Fahrzeug", 0.6)
	self.m_VehicleListGrid:addColumn(_"Status", 0.4)
    for i, v in pairs(vehicles) do
        local item = self.m_VehicleListGrid:addItem(v[1]:getName(), v[2] ~= 0 and "Abgemeldet" or "Angemeldet"):setColor(v[2] ~= 0 and Color.Red or Color.Green)
        item.id = v[1]
        item.registered = v[2]
        item.onLeftClick =
        function()
            self.m_UnregisterButton:setText(("%smelden"):format(item.registered ~= 0 and "An" or "Ab"))
           
        end
    end
end