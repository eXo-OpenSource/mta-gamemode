-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/SkyscraperGUI.lua
-- *  PURPOSE:     Skyscraper GUI
-- *
-- ****************************************************************************
SkyscraperGUI = inherit(GUIButtonMenu)
inherit(Singleton, SkyscraperGUI)

addRemoteEvents{"Skyscraper:showGUI"}

function SkyscraperGUI:constructor(id, apartments, apartmentsOwner, rangeElement)
    GUIButtonMenu.constructor(self, _("Hochhaus #%s", id), false, false, false, false, rangeElement)

    for i, houseId in pairs(apartments) do
        local floorNumber = i-1
        local floorName = i == 1 and "EG" or "OG"..floorNumber
        local color = apartmentsOwner[i] and Color.Red or Color.Green
        local idPrefix = localPlayer:getRank() >= 4 and "["..houseId.."]" or ""
        local rentStatus = apartmentsOwner[i] and "vermietet" or "frei"

        self:addItem(("%s Wohnung %s - %s"):format(idPrefix, floorName, rentStatus), color, bind(self.itemCallback, self, houseId))
    end
end

function SkyscraperGUI:itemCallback(houseId)
    delete(self)
    triggerServerEvent("Skyscraper:requestHouseInfos", localPlayer, houseId)
end

addEventHandler("Skyscraper:showGUI", root,
    function(id, apartments, apartmentsOwner, rangeElement)
        SkyscraperGUI:new(id, apartments, apartmentsOwner, rangeElement)
    end
    )