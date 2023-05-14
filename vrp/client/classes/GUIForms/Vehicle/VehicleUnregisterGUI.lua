-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/VehicleUnregisterGUI.lua
-- *  PURPOSE:     VehicleUnregister GUI
-- *
-- ****************************************************************************
VehicleUnregisterGUI = inherit(GUIForm)
inherit(Singleton, VehicleUnregisterGUI)
addRemoteEvents{"sendRegisteredVehicleList"}

function VehicleUnregisterGUI:constructor(rangeElement)
    GUIWindow.updateGrid()
	self.m_Width = grid("x", 16)
	self.m_Height = grid("y", 12)

    GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true, false, rangeElement)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Fahrzeug an/abmelden", true, true, self)

    self.m_UnregisterButton = GUIGridButton:new(1, 11, 15, 1, _"Abmelden", self.m_Window):setBackgroundColor(Color.Green)
    self.m_UnregisterButton.onLeftClick = bind(self.unregistereButton_Click, self)

    triggerServerEvent("requestVehicles", localPlayer)
    addEventHandler("sendRegisteredVehicleList", localPlayer, bind(self.updateList, self))
end

function VehicleUnregisterGUI:unregistereButton_Click()
    if not self.m_VehicleListGrid:getSelectedItem() then return end
    local vehicle = self.m_VehicleListGrid:getSelectedItem().id
    if self.m_UnregisterButton:getText() == _"Abmelden" then
        self:hide()
        QuestionBox:new(_("Bist du sicher, dass du dein Fahrzeug abmelden möchtest? Du kannst es dann erst in 3 Tagen wieder anmelden. Außerdem wird bei der Abholung eine Gebühr von %s$ abgebucht.", 500 + vehicle:getTax()*10), 
            function()
                triggerServerEvent("onToggleVehicleRegister", vehicle, "unregister")
                triggerServerEvent("requestVehicles", localPlayer)
                self:show()
            end,
            function() self:show() end,
            localPlayer:getPosition()
        )
    else
        triggerServerEvent("onToggleVehicleRegister", vehicle, "register")
        triggerServerEvent("requestVehicles", localPlayer)
    end
end


function VehicleUnregisterGUI:updateList(vehicles)
    if self.m_VehicleListGrid then delete(self.m_VehicleListGrid) end
    self.m_VehicleListGrid = GUIGridGridList:new(1, 1, 15, 9, self.m_Window)
	self.m_VehicleListGrid:addColumn(_"Fahrzeug", 0.6)
	self.m_VehicleListGrid:addColumn(_"Status", 0.4)
    for i, v in pairs(vehicles) do
        local item = self.m_VehicleListGrid:addItem(v[1]:getName(), v[2] ~= 0 and _"Abgemeldet" or _"Angemeldet"):setColor(v[2] ~= 0 and Color.Red or Color.Green)
        item.id = v[1]
        item.registered = v[2]
        item.onLeftClick =
        function()
            self.m_UnregisterButton:setText(("%smelden"):format(item.registered ~= 0 and "An" or "Ab"))
            if self.m_InfoLabel then
                delete(self.m_InfoLabel)
            end
            self.m_InfoLabel = GUIGridLabel:new(1, 10, 15, 1, item.registered ~= 0 and ("Mindestens abgemeldet bis zum %s"):format(getOpticalTimestamp(item.registered + VEHICLE_MIN_DAYS_TO_REGISTER_AGAIN))  or _"Nicht abgemeldet", self.m_Window):setAlignX("center")
        end
    end
end