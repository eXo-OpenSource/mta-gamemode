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

    local apartmentsOwner = table.reverse(apartmentsOwner)
    for i, houseId in pairs(table.reverse(apartments)) do
        local floorNumber = #apartments - i
        local floorName = floorNumber == 0 and "EG" or floorNumber..". OG"
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