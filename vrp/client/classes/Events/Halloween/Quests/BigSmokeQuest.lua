-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Events/Halloween/Quests/BigSmokeQuest.lua
-- *  PURPOSE:     Ghost Finder Quest class
-- *
-- ****************************************************************************

BigSmokeQuest = inherit(HalloweenQuest)

function BigSmokeQuest:constructor()
    self.m_Ghost = HalloweenGhost:new(Vector3(2260.347, -1224.271, 1049.023), 180, 10, 13, false, false)
    self.m_ColShape = createColRectangle(2259.034, -1221.085, 3, 1)
    addEventHandler("onClientColShapeHit", self.m_ColShape, bind(self.onClientColShapeHit, self))
end

function BigSmokeQuest:virtual_destructor()
    if self.m_Ghost then
        delete(self.m_Ghost)
    end
end

function BigSmokeQuest:startQuest()
    self:createDialog(bind(self.onStart, self),
        "Du kommst wie gerufen!",
        "Ich habe Informationen zu einem Geist der in einem Haus in Idlewood sein Unwesen treibt!",
        "Nimm den Geistvertreiber und vertreibe ihn!"
    )
end

function BigSmokeQuest:onStart()
    triggerServerEvent("Halloween:giveGhostCleaner", localPlayer)
    self.m_QuestMessage = ShortMessage:new("Vertreibe den Geist aus dem Haus in Idlewood!", "Halloween: Quest", Color.Orange, -1, false, false, Vector2(2058.01, -1697.27), {{path="Marker.png", pos=Vector2(2058.01, -1697.27)}}, true)
end

function BigSmokeQuest:onClientColShapeHit(hitElement)
    if hitElement == localPlayer then
        toggleAllControls(false)
        self:createDialog(bind(self.removeDisguise, self), 
            "Ich wusste, dass du kommen wirst.",
            "Du wirst uns nicht an unserem Plan hindern."
        )
        self.m_ColShape:destroy()
    end
end

function BigSmokeQuest:removeDisguise()
    fadeCamera(false, 0.1)
    setTimer(
        function()
            self.m_Ghost.m_Ped:setModel(311)
            self.m_Ghost.m_Ped:setAlpha(150)
        end
    , 200, 1)
    setTimer(
        function()
            fadeCamera(true, 0.1)
        end
    , 600, 1)
    setTimer(
        function()
            self:createDialog(bind(self.moveGhost, self), 
                "Wenn Du mich nun entschuldigen würdest, Ich muss los."
            )
        end
    , 700, 1)
end

function BigSmokeQuest:moveGhost()
    self.m_Ghost.m_MoveObject:move(4000, 2260.347, -1226.271, 1049.023)
    
    toggleAllControls(true)
    delete(self.m_QuestMessage)
    self.m_QuestMessage = ShortMessage:new("Kehre nun zum Friedhof zurück!", "Halloween: Quest", Color.Orange, -1, false, false, false, false, true)
    self:setSucceeded()
end

function BigSmokeQuest:endQuest()
    self:createDialog(false, 
        "Der Geist hat von einem Plan gesprochen und ist anschließend geflohen?",
        "Merkwürdig...",
        "Dennoch, eine Belohnung für deine Arbeit!"
    )
end