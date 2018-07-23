-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Actions/PrisonBreak/PrisonBreakManager.lua
-- *  PURPOSE:     Prison Break Manager Class
-- *
-- ****************************************************************************


-- TODO
-- Nachricht beim Auslagern von Waffen kommt 2x
-- Countdown liegen übereinander

PrisonBreakManager = inherit(Singleton)

function PrisonBreakManager:constructor()
    self.m_WeaponBoxes = {}

    self:createEntrance()
    self:createPoliceman()
    self:createWeaponBoxes()
end

function PrisonBreakManager:start(button, state, player)
    if
        button ~= "left"
        or state ~= "down"
    then
        return
    end

    self.m_Instance = PrisonBreak:new()
    self.m_Instance:placeBomb(player)
end

function PrisonBreakManager:stop()
    self.m_Instance = nil

    if not isElement(self.m_Entrance) then
        self:createEntrance()
    end

    if not isElement(self.m_Officer) then
        self:createPoliceman()
    end
end

function PrisonBreakManager:createEntrance()
    self.m_Entrance = createObject(2904, Vector3(3629.8999023438, -1548.0999755859, 5.5999999046326), Vector3(0, 0, 335.49987792969))
    self.m_Entrance:setScale(1.29999995)
	addEventHandler("onElementClicked", self.m_Entrance, bind(self.start, self))
end

function PrisonBreakManager:createPoliceman()
    self.m_Officer = NPC:new(276, Vector3(2564.98, -1432.98, 1044.52), 345.4)
    self.m_Officer:setInterior(2)
    self.m_Officer:setFrozen(true)
end

function PrisonBreakManager:createWeaponBoxes()
    table.insert(self.m_WeaponBoxes, createObject(964, Vector3(2567.8000488281, -1433.9000244141, 1043.5), Vector3(0, 0, 180)))
    table.insert(self.m_WeaponBoxes, createObject(964, Vector3(2565, -1421.5, 1043.5), Vector3(0, 0, 90)))

    for i, box in pairs(self.m_WeaponBoxes) do
        box:setInterior(2)
    end
end

function PrisonBreakManager:getCurrent()
    return self.m_Instance
end
