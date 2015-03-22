-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/TradeGUI.lua
-- *  PURPOSE:     (Inventory) Trade GUI
-- *
-- ****************************************************************************
TradeGUI = inherit(GUIForm)

function TradeGUI:constructor()
    local width, height = 640, 480
    GUIForm.constructor(screenWidth/2-width/2, screenHeight/2-height/2, width, height)


end
