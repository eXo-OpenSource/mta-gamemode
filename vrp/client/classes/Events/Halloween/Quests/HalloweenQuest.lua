-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Events/Halloween/Quests/HalloweenQuest.lua
-- *  PURPOSE:     Halloween Quest base class
-- *
-- ****************************************************************************

HalloweenQuest = inherit(Object)

function HalloweenQuest:constructor()
    self.m_QuestSuccess = false
end

function HalloweenQuest:destructor()
    if self.m_QuestMessage then
        delete(self.m_QuestMessage)
    end
    triggerServerEvent("Halloween:takeGhostCleaner", localPlayer)
end

function HalloweenQuest:createDialog(callback, ...)
    DialogGUI:new(callback, ...)
end

function HalloweenQuest:setSucceeded()
    self.m_QuestSuccess = true
end

function HalloweenQuest:isSucceeded()
    return self.m_QuestSuccess
end