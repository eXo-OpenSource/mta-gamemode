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
    self:createDummyPoliceman()
    self:createWeaponBoxes()

    local antifall = createColCuboid( 3624.71, -1551.32, -0.20, 8, 8, 3.8 )
    InstantTeleportArea:new(antifall, 0, 0, Vector3(3630.73, -1546.19, 4.94))
    
    local antifall2 = createColCuboid(2559.17, -1416.25, 1045.87, 5, 10, 4 )
    antifall2:setInterior(2)
    InstantTeleportArea:new(antifall2, 0, 2, Vector3(2561.75, -1414.22, 1050.83))

    local antifall3 = createColCuboid(2555.62, -1462.42, 1031.07, 200, 200, 7) -- prevents suicide
    antifall3:setInterior(2)
    InstantTeleportArea:new(antifall3, 0, 2, Vector3(2611.23, -1414.81, 1040.36))
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

function PrisonBreakManager:createDummyPoliceman()
    self.m_Officer = ShopNPC:new(276, Vector3(2564.98, -1432.98, 1044.52), 345.4)
    self.m_Officer:setInterior(2)
    self.m_Officer:setImmortal(true)
    self.m_Officer:setFrozen(true)
    self.m_Officer.m_Warning = "Du überfällst den Gefängnisaufseher in 5 Sekunden, wenn du weiter auf ihn zielst!"
    self.m_Officer.onTargetted = bind(self.PedTargetted, self)
    self.m_Officer.onTargetRefresh = bind(self.PedTargetRefresh, self)
end

function PrisonBreakManager:PedTargetted(ped, attacker)
    if not self:getCurrent() then
        attacker:sendError("Derzeit läuft kein Knastausbruch!")
        return false
    end
    self:getCurrent():Ped_Targetted(ped, attacker)
end

function PrisonBreakManager:PedTargetRefresh(count, startingPlayer)
    if not self:getCurrent() then
        return false
    end
    self:getCurrent():PedTargetRefresh(count, startingPlayer)    
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
