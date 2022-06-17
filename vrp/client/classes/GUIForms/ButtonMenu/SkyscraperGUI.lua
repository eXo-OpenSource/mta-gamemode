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

function SkyscraperGUI:constructor(apartments, freeApartments)
    GUIButtonMenu.constructor(self, "Hochhaus")

    for i, houseId in pairs(apartments) do
        self:addItem(("%s Wohnung %s - %s"):format(localPlayer:getRank() >= 4 and "["..houseId.."]" or "",i == 1 and "EG" or "OG"..i-1 ,freeApartments[i] and "vermietet" or "frei"), freeApartments[i] and Color.Red or Color.Green, bind(self.itemCallback, self, houseId))
    end
end

function SkyscraperGUI:itemCallback(houseId)
    delete(self)
    triggerServerEvent("Skyscraper:requestHouseInfos", localPlayer, houseId)
end

addEventHandler("Skyscraper:showGUI", root,
    function(apartments, freeApartments)
        SkyscraperGUI:new(apartments, freeApartments)
    end
    )