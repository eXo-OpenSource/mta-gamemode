-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/AtmManager.lua
-- *  PURPOSE:     ATM Manager class
-- *
-- ****************************************************************************

AtmManager = inherit(Singleton)

function AtmManager:constructor()
    self.m_Atms = {}
    for key, object in pairs(getElementsByType("object")) do
        if object:getModel() == ATM_NORMAL_MODEL or object:getModel() == ATM_BROKEN_MODEL then
            self.m_Atms[#self.m_Atms+1] = object
            self:handleAtms()
            object:setBreakable(false)
            addEventHandler("onClientElementDataChange", object, bind(self.handleEffect, self))
        end
    end
end

function AtmManager:handleAtms()
    for key, atm in pairs(self.m_Atms) do
        if atm:getData("isHacked") or atm:getData("isExploded") then
            if not isElement(atm.effect) then
                local x, y, z = getElementPosition(atm)
                local xr, yr, zr = getElementRotation(atm)
                atm.effect = createEffect("prt_spark", x, y, z+0.1, -90, 0, 0)
            end
        else
            if isElement(atm.effect) then
                atm.effect:destroy()
            end
        end
    end
end

function AtmManager:handleEffect(key, oldValue, newValue)
    if key == "isHacked" or key == "isExploded" then
        if newValue == true then
            if not isElement(source.effect) then
                local x, y, z = getElementPosition(source)
                local xr, yr, zr = getElementRotation(source)
                source.effect = createEffect("prt_spark", x, y, z+0.1, -90, 0, 0)
            end
        else
            if isElement(source.effect) then
                source.effect:destroy()
            end
        end
    end
end

function AtmManager.onAtmClick(atm)
    if atm:getModel() == ATM_BROKEN_MODEL or atm:getData("isExploded") then
        ErrorBox:new(_"Dieser Bankautomat ist kaputt! Komm bitte später wieder!")
    elseif atm:getData("isHacked") then
        ErrorBox:new(_"Aus diesem Automaten sprühen Funken, er scheint wohl nicht richtig zu funktionieren!")
    else
        BankGUI:getSingleton(atm):show()
    end
end

function AtmManager.startHacking(atm)
    if atm:getInterior() == 0 and atm:getDimension() == 0 then
        triggerServerEvent("onAtmStartHacking", localPlayer, atm)
        delete(BankGUI:getSingleton())
    else
        ErrorBox:new(_"Du kannst hier keine Bankautomaten sabotieren!")
    end
end