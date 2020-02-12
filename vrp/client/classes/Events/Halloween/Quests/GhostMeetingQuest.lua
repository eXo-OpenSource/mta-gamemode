-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Events/Halloween/Quests/GhostMeetingQuest.lua
-- *  PURPOSE:     Ghost Meeting Quest class
-- *
-- ****************************************************************************

GhostMeetingQuest = inherit(HalloweenQuest)

function GhostMeetingQuest:constructor()
    self.m_Ghosts = {
        HalloweenGhost:new(Vector3(-730.738, 1546.295, 41), 270, 0, 0, false, false),
        HalloweenGhost:new(Vector3(-725.308, 1548.575, 41), 111, 0, 0, false, false),
        HalloweenGhost:new(Vector3(-722.573, 1546.523, 41), 90, 0, 0, false, false),
        HalloweenGhost:new(Vector3(-725.308, 1544.481, 41), 64, 0, 0, false, false)
    }
    self.m_ColShape = createColCuboid(-724.774, 1532.279, 39.091, 6, 2, 2)
    addEventHandler("onClientColShapeHit", self.m_ColShape, bind(self.onClientColShapeHit, self))
end

function GhostMeetingQuest:virtual_destructor()
    
end

function GhostMeetingQuest:startQuest()
    self:createDialog(bind(self.onStart, self), 
        "Da bist Du ja wieder!",
        "Du musst diese Quelle der Geister finden!",
        "Am besten schaust Du dich mal in der Nähe von Ruinen um..."
    )
end

function GhostMeetingQuest:onStart()
    triggerServerEvent("Halloween:giveGhostCleaner", localPlayer)
    self.m_QuestMessage = ShortMessage:new("Finde die Quelle der Geister!", "Halloween: Quest", Color.Orange, -1, false, false, false, false, true)
end

function GhostMeetingQuest:onClientColShapeHit(hitElement)
    if hitElement == localPlayer then
        toggleAllControls(false)
        self:createDialog(bind(self.onDialogEnd, self), 
            "Ihr verteilt die Totems, Ich kümmere mich um den Rest!",
            "Verstanden!"
        )
        self.m_ColShape:destroy()
    end
end

function GhostMeetingQuest:onDialogEnd()
    self.m_Ghosts[1].m_MoveObject:move(20000, self.m_Ghosts[1].m_MoveObject.position + self.m_Ghosts[1].m_MoveObject.matrix.forward * 1000)
    self.m_Ghosts[2].m_MoveObject:move(20000, self.m_Ghosts[2].m_MoveObject.position + self.m_Ghosts[2].m_MoveObject.matrix.forward * 1000)
    self.m_Ghosts[3].m_MoveObject:move(20000, self.m_Ghosts[3].m_MoveObject.position + self.m_Ghosts[3].m_MoveObject.matrix.forward * 1000)
    self.m_Ghosts[4].m_MoveObject:move(20000, self.m_Ghosts[4].m_MoveObject.position + self.m_Ghosts[4].m_MoveObject.matrix.forward * 1000)
    setTimer(
        function()
            toggleAllControls(true)
            delete(self.m_QuestMessage)
            self.m_QuestMessage = ShortMessage:new("Kehre nun zum Friedhof zurück!", "Halloween: Quest", Color.Orange, -1, false, false, false, false, true)
            self:setSucceeded()
            for key, ghost in pairs(self.m_Ghosts) do
                delete(ghost)
            end
        end
    , 5000, 1)
end

function GhostMeetingQuest:endQuest()
    self:createDialog(false, 
        "Sie verteilen Totems?",
        "Wofür bloß?"
    )
end