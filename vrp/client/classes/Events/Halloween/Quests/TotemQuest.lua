-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Events/Halloween/Quests/TotemQuest.lua
-- *  PURPOSE:     Totem Quest class
-- *
-- ****************************************************************************

TotemQuest = inherit(HalloweenQuest)

function TotemQuest:constructor()
    self.m_Totem = createObject(3524, -325, 2222, 44.3, 0, 0, 284.5)
    self.m_Totem:setScale(3)
    self.m_KillZone = createColSphere(-325, 2222, 44.3, 20)
    addEventHandler("onClientColShapeHit", self.m_KillZone, bind(self.onKillZoneHit, self))

    self.m_DamageZone = createColSphere(-325, 2222, 44.3, 40)
    addEventHandler("onClientColShapeHit", self.m_DamageZone, bind(self.onDamageZoneHit, self))
    addEventHandler("onClientColShapeLeave", self.m_DamageZone, bind(self.onDamageZoneLeave, self))

    self.m_MessageColShape = createColSphere(-325, 2222, 44.3, 60)
    addEventHandler("onClientColShapeHit", self.m_MessageColShape, bind(self.onMessageColShapeHit, self))

    self.m_SpawnZone = createColSphere(-325, 2222, 44.3, 200)
    addEventHandler("onClientColShapeHit", self.m_SpawnZone, bind(self.onSpawnZoneHit, self))
    addEventHandler("onClientColShapeLeave", self.m_SpawnZone, bind(self.onSpawnZoneLeave, self))
    self.m_Ghosts = {}
end

function TotemQuest:virtual_destructor()
    self.m_Totem:destroy()
    self.m_KillZone:destroy()
    self.m_DamageZone:destroy()
    self.m_SpawnZone:destroy()
    if self.m_DamageTimer and isTimer(self.m_DamageTimer) then
        killTimer(self.m_DamageTimer)
    end
end

function TotemQuest:startQuest()
    self:createDialog(bind(self.onStart, self), 
        "Totems sagst Du also...",
        "Du solltest Dich mal umschauen, ob Du eines dieser Totems finden kannst!"
    )
end

function TotemQuest:onStart()
    triggerServerEvent("Halloween:giveGhostCleaner", localPlayer)
    self.m_QuestMessage = ShortMessage:new("Finde ein Totem!", "Halloween: Quest", Color.Orange, -1, false, false, false, false, true)
end

function TotemQuest:onKillZoneHit(hitElement, matchingDimension)
    if matchingDimension then
        if hitElement == localPlayer then
            localPlayer:setHealth(0)
            Guns:getSingleton():bloodScreen()
        end
    end
end

function TotemQuest:onDamageZoneHit(hitElement, matchingDimension)
    if matchingDimension then
        if hitElement == localPlayer then
            self.m_DamageTimer = setTimer(
                function()
                    localPlayer:setHealth(localPlayer:getHealth() - 5)
                    Guns:getSingleton():bloodScreen()
                end
            , 500, 0)
        end
    end
end

function TotemQuest:onDamageZoneLeave(leaveElement, matchingDimension)
    if matchingDimension then
        if leaveElement == localPlayer then
            if self.m_DamageTimer and isTimer(self.m_DamageTimer) then
                killTimer(self.m_DamageTimer)
            end
        end
    end
end

function TotemQuest:onMessageColShapeHit(hitElement, matchingDimension)
    if matchingDimension then
        if hitElement == localPlayer then
            self:createDialog(bind(self.startTotemHunt, self), 
                "Ein riesiges Totem spuckt Geister aus...",
                "Du spürst eine merkwürdige Präsenz...",
                "Du solltest dich dem Totem nicht weiter nähern..."
            )
            self.m_MessageColShape:destroy()
        end
    end
end

function TotemQuest:onSpawnZoneHit(hitElement, matchingDimension)
    if matchingDimension then
        if hitElement == localPlayer then
            self.m_SpawnTimer = setTimer(
                function()
                    self:spawnGhost()
                end
            , 250, 0)
        end
    end
end

function TotemQuest:onSpawnZoneLeave(leaveElement, matchingDimension)
    if matchingDimension then
        if leaveElement == localPlayer then
            if isTimer(self.m_SpawnTimer) then
                killTimer(self.m_SpawnTimer)
            end
        end
    end
end

function TotemQuest:spawnGhost()
    local rotation = math.random(56, 137)
    local ghost = HalloweenGhost:new(Vector3(-326.064, 2221.722, 50.597), rotation, 0, 0, false, false)
    ghost.m_MoveObject:setRotation(math.random(260, 280), 0, rotation)
    setTimer(
        function()
            ghost.m_MoveObject:move(1000, ghost.m_MoveObject.position + ghost.m_MoveObject.matrix.up*20, 0, 0, 0, "OutQuad")
        end
    , 55, 1)
    setTimer(
        function()
            ghost:kill()
        end
    , 200, 1)
end

function TotemQuest:startTotemHunt()
    self.m_Totems = {
        HalloweenTotem:new(Vector3(-431.931, 2241.015, 42.983), Vector3(0, 0, 222.860), bind(self.onTotemBreak, self)),
        HalloweenTotem:new(Vector3(-399.996, 2203.404, 42.426), Vector3(0, 0, 102.825), bind(self.onTotemBreak, self)),
        HalloweenTotem:new(Vector3(-367.764, 2266.393, 42.484), Vector3(0, 0, 6.5), bind(self.onTotemBreak, self)),
        HalloweenTotem:new(Vector3(-480.409, 2179.008, 41.860), Vector3(0, 0, 357.321), bind(self.onTotemBreak, self)),
        HalloweenTotem:new(Vector3(-455.336, 2227.886, 42.760), Vector3(0, 0, 88.2), bind(self.onTotemBreak, self)),
        HalloweenTotem:new(Vector3(-417.650, 2246.380, 42.430), Vector3(0, 0, 300.80), bind(self.onTotemBreak, self))
    }
    self.m_TotemsBroken = 0
end

function TotemQuest:onTotemBreak()
    self.m_TotemsBroken = self.m_TotemsBroken + 1
    if self.m_TotemsBroken == #self.m_Totems then
        delete(self.m_QuestMessage)
        self.m_QuestMessage = ShortMessage:new("Kehre nun zum Friedhof zurück!", "Halloween: Quest", Color.Orange, -1, false, false, false, false, true)
        self:setSucceeded()
    end
end

function TotemQuest:endQuest()
    self:createDialog(false, 
        "Ein riesiges Totem aus dem Geister erscheinen?",
        "Und viele weitere kleine Totems drum herum?",
        "Und das große Totem hat eine merkwürdige Präsenz umgeben?",
        "Das wird ja immer gruseliger..."
    )
end