-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Events/Halloween/Quests/GhostKillerQuest.lua
-- *  PURPOSE:     Ghost Finder Quest class
-- *
-- ****************************************************************************

GhostKillerQuest = inherit(HalloweenQuest)

function GhostKillerQuest:constructor()
    self.m_Ghosts = {
        HalloweenGhost:new(Vector3(-59.19, 1362.08, 1080.21), 66, 6, 13, false, bind(self.onGhostKill, self)), --Aztecas
        HalloweenGhost:new(Vector3(2371.15, -1132.86, 1051.69), 70, 8, 13, false, bind(self.onGhostKill, self)), --Strand
        HalloweenGhost:new(Vector3(-267.28, 1448.41, 1084.37), 74, 4, 13, false, bind(self.onGhostKill, self)), --San News
        HalloweenGhost:new(Vector3(323.84, 1129.22, 1083.88), 180, 5, 13, false, bind(self.onGhostKill, self)) --Glen Park
    }
    self.m_KilledGhosts = 0
    for key, ghost in pairs(self.m_Ghosts) do 
        ghost:setAttackMode(true)
    end
end

function GhostKillerQuest:virtual_destructor()
    for key, ghost in pairs(self.m_Ghosts) do
        delete(ghost)
    end
end

function GhostKillerQuest:startQuest()
    self:createDialog(bind(self.onStart, self), 
        "Du schon wieder!",
        "Scheinbar spukt es nicht nur in meinem Haus...",
        "Tust du mir den Gefallen und schaust dich mal um?"
    )
end

function GhostKillerQuest:onStart()
    triggerServerEvent("Halloween:giveGhostCleaner", localPlayer)
    self.m_QuestMessage = ShortMessage:new("Vertreibe die Geister aus den Häusern in Los Santos!\n(4 verbleibend)", "Halloween: Quest", Color.Orange, -1, false, false, false, false, true)
end

function GhostKillerQuest:onGhostKill()
    if self.m_KilledGhosts == 3 then
        self.m_QuestMessage:setText("Kehre nun zum Friedhof zurück!")
        self:setSucceeded()
    else
        self.m_KilledGhosts = self.m_KilledGhosts + 1
        self.m_QuestMessage:setText(("Vertreibe die Geister aus den Häusern in Los Santos!\n(%s verbleibend)"):format(4-self.m_KilledGhosts))
    end
end

function GhostKillerQuest:endQuest()
    self:createDialog(false, 
        "Ich danke dir vielmals für deine Hilfe!",
        "Hier, eine Belohnung für deine Arbeit!"
    )
end