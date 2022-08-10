-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/VehicleKeyListGUI.lua
-- *  PURPOSE:     Vehicle owning key management GUI
-- *
-- ****************************************************************************
VehicleKeyListGUI = inherit(GUIForm)
inherit(Singleton, VehicleKeyListGUI)
addRemoteEvents{"showKeyList"}

function VehicleKeyListGUI:constructor()	

    GUIWindow.updateGrid()
	self.m_Width = grid("x", 13)
	self.m_Height = grid("y", 11)
	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true, false, nil)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Geliehene Zweitschlüssel", true, true, self)
	self.m_Window:addBackButton(function () delete(self) SelfGUI:getSingleton():show() end)

    GUIGridLabel:new(1,1,12,1, "INFO: Mit einem Doppelklick kannst du das Fahrzeug orten.", self.m_Window):setColor(Color.Accent)

    triggerServerEvent("requestKeyList", localPlayer)
    addEventHandler("showKeyList", localPlayer, bind(self.updateList, self))
end

function VehicleKeyListGUI:updateList(vehicle)
    if self.m_KeyListGrid then delete(self.m_KeyListGrid) end

    self.m_KeyListGrid = GUIGridGridList:new(1,2, 12, 9, self.m_Window)
    self.m_KeyListGrid:addColumn(_"Name", 0.3)
    self.m_KeyListGrid:addColumn(_"Standort", 0.4)
    self.m_KeyListGrid:addColumn(_"Besitzer", 0.3)
    for i, vehData in pairs(vehicle) do
        local veh = vehData[1]
        local posType = vehData[2]

        if VehiclePositionTypeName[posType] then
            if VehiclePositionTypeName[posType] == VehiclePositionTypeName[0] then
                positionType = getZoneName(veh.position, false)
            else
                positionType =VehiclePositionTypeName[posType]
            end
        else
            positionType = _"Unbekannt"
        end

        local item = self.m_KeyListGrid:addItem(veh:getName(), positionType, veh:getData("OwnerName"))
        item.onLeftDoubleClick = function()
            if posType == VehiclePositionType.World then

                if not isVehicleBlown(veh) then
                    local x, y, z = getElementPosition(veh)
                    local blip = Blip:new("Marker.png", x, y, 9999, {200, 0, 0})
                    blip:setZ(z)
                    ShortMessage:new(_("Dieses Fahrzeug befindet sich in %s!\n(Klicke hier um das Blip auf der Map zu löschen!)", getZoneName(x, y, z, false)), "Fahrzeugortung", Color.DarkLightBlue, -1, false, false, Vector2(x, y), {{path="Marker.png", pos=Vector2(x, y)}})
                        .m_Callback = function (this)
                            if blip then
                                delete(blip)
                            end
                            delete(this)
                        end
                else ShortMessage:new(_("Dieses Fahrzeug ist zerstört."))
                end
            elseif posType == VehiclePositionType.Garage then
                 ShortMessage:new(_"Dieses Fahrzeug befindet sich in einer Garage!", "Fahrzeugortung", Color.DarkLightBlue)
            elseif posType == VehiclePositionType.Mechanic then
                ShortMessage:new(_"Dieses Fahrzeug befindet sich im Autohof (Mechanic Base)!", "Fahrzeugortung", Color.DarkLightBlue)
            elseif posType == VehiclePositionType.Hangar then
                ShortMessage:new(_"Dieses Flugzeug befindet sich im Hangar!", "Fahrzeugortung", Color.DarkLightBlue)
            elseif posType == VehiclePositionType.Harbor then
                ShortMessage:new(_"Dieses Boot befindet sich im Industrie-Hafen (Logistik-Job)!", "Fahrzeugortung", Color.DarkLightBlue)
            elseif posType == VehiclePositionType.Unregistered then
                ShortMessage:new(_"Dieses Fahrzeug ist abgemeldet!", "Fahrzeugortung", Color.DarkLightBlue)
            else
                ErrorBox:new(_"Es ist ein interner Fehler aufgetreten!")
            end
        end
    end
end
