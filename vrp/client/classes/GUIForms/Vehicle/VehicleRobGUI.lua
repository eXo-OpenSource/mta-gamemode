-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/VehicleRobGUI.lua
-- *  PURPOSE:     VehicleRobGUI class
-- *
-- ****************************************************************************
VehicleRobGUI = inherit(GUIForm)
inherit(Singleton, VehicleRobGUI)

addRemoteEvents{"ShopVehicleRob:openGUI"}

function VehicleRobGUI:constructor(time)
    self.m_Countdown = ShortCountdown:new(time, "Schloss knacken", "files/images/Other/LockPick.png")
    GUIForm.constructor(self, self.m_Countdown.m_AbsoluteX+self.m_Countdown.m_Width, self.m_Countdown.m_AbsoluteY, screenWidth*0.06, screenHeight*.03, false)
    self.m_Cancel = GUIButton:new(0, 0, self.m_Width, self.m_Height, "Abbruch", self)
    self.m_Cancel.onLeftClick = function()
        triggerServerEvent("ShopVehicleRob:onCancelPickingLock", localPlayer, isHealer)
        delete(self)
    end
    localPlayer.m_IsPickingLock = true
    self.m_CancelTimer = setTimer(function() if VehicleRobGUI:getSingleton() then delete(VehicleRobGUI:getSingleton()) end end, time*1000, 1)

    addEventHandler("onClientPlayerWasted", localPlayer, function()
        delete(self)
    end)
end

function VehicleRobGUI:destructor()
    GUIForm.destructor(self, posX, posY, screenWidth*0.06, screenHeight*.03, false)
    localPlayer.m_IsPickingLock = false

    if self.m_Countdown then 
        delete(self.m_Countdown) 
        self.m_Countdown = nil
    end
    if self.m_CancelTimer and isTimer(self.m_CancelTimer) then
        killTimer(self.m_CancelTimer)
        self.m_CancelTimer = nil
    end
end

addEventHandler("ShopVehicleRob:openGUI", root, function(time)
    VehicleRobGUI:new(time)  
end)