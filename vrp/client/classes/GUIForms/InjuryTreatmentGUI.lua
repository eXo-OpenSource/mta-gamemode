-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/InjuryTreatmentGUI.lua
-- *  PURPOSE:     InjuryTreatmentGUI class
-- *
-- ****************************************************************************
InjuryTreatmentGUI = inherit(GUIForm)
inherit(Singleton, InjuryTreatmentGUI)

function InjuryTreatmentGUI:constructor(posX, posY, isHealer)
    GUIForm.constructor(self, posX, posY, screenWidth*0.06, screenHeight*.03, false)
    self.m_Cancel = GUIButton:new(0, 0, self.m_Width, self.m_Height, "Abbruch", self)
    self.m_Cancel.onLeftClick = function()
        triggerServerEvent("Damage:onCancelTreat", localPlayer, isHealer)
    end

end

function InjuryTreatmentGUI:virtual_destructor()

end
