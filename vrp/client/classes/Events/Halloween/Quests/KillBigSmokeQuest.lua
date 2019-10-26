-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Events/Halloween/Quests/KillBigSmokeQuest.lua
-- *  PURPOSE:     Ghost Finder Quest class
-- *
-- ****************************************************************************

KillBigSmokeQuest = inherit(HalloweenQuest)

function KillBigSmokeQuest:constructor()
    self.m_Ghost = HalloweenGhost:new(Vector3(2552.88, -1285.38, 1060.98), 234, 2, 13, false, bind(self.onGhostKill, self))
    self.m_Ghost:setModel(311)
    self.m_Ghost:setAlpha(150)
    self.m_Ghost:setHealth(10)
    self.m_Ghost:setAttackMode(true)

    self.m_Ghosts = {
        HalloweenGhost:new(Vector3(2527.01, -1297.45, 1031.42), 180, 2, 13, false, false),
        HalloweenGhost:new(Vector3(2546.25, -1289.09, 1031.42), 106, 2, 13, false, false),
        HalloweenGhost:new(Vector3(2541.12, -1299.05, 1031.42), 67, 2, 13, false, false),
        HalloweenGhost:new(Vector3(2553.01, -1295.54, 1033.00), 84, 2, 13, false, false),
        HalloweenGhost:new(Vector3(2569.75, -1287.15, 1031.42), 175, 2, 13, false, false),
        HalloweenGhost:new(Vector3(2568.22, -1305.83, 1037.77), 301, 2, 13, false, false),
        HalloweenGhost:new(Vector3(2573.70, -1300.54, 1044.13), 341, 2, 13, false, false),
        HalloweenGhost:new(Vector3(2557.41, -1296.74, 1044.13), 250, 2, 13, false, false),
        HalloweenGhost:new(Vector3(2566.47, -1289.28, 1044.13), 200, 2, 13, false, false),
        HalloweenGhost:new(Vector3(2528.95, -1290.21, 1048.29), 180, 2, 13, false, false),
        HalloweenGhost:new(Vector3(2527.46, -1288.94, 1054.64), 354, 2, 13, false, false),
        HalloweenGhost:new(Vector3(2542.22, -1296.48, 1054.64), 42, 2, 13, false, false),
        HalloweenGhost:new(Vector3(2529.95, -1304.95, 1054.64), 301, 2, 13, false, false),
        HalloweenGhost:new(Vector3(2550.00, -1291.73, 1054.64), 157, 2, 13, false, false),
        HalloweenGhost:new(Vector3(2565.77, -1296.50, 1054.64), 90, 2, 13, false, false),
        HalloweenGhost:new(Vector3(2565.09, -1291.46, 1054.64), 90, 2, 13, false, false),
        HalloweenGhost:new(Vector3(2571.58, -1299.94, 1054.64), 343, 2, 13, false, false),
        HalloweenGhost:new(Vector3(2579.91, -1297.26, 1060.99), 0, 2, 13, false, false),
    }
    for key, ghost in pairs(self.m_Ghosts) do
        ghost:setAttackMode(true)
    end
end

function KillBigSmokeQuest:virtual_destructor()
    if self.m_Ghost then
        delete(self.m_Ghost)
    end
    for key, ghost in pairs(self.m_Ghosts) do
        delete(ghost)
    end
end

function KillBigSmokeQuest:startQuest()
    self:createDialog(bind(self.onStart, self), 
        "Du musst diesen Geist finden!",
        "Hier, der Geistvertreiber!"
    )
end

function KillBigSmokeQuest:onStart()
    triggerServerEvent("Halloween:giveGhostCleaner", localPlayer)
    self.m_QuestMessage = ShortMessage:new("Finde das Versteck des Geistes!", "Halloween: Quest", Color.Orange, -1, false, false, false, false, true)
end

function KillBigSmokeQuest:onGhostKill()
	local sound = playSound3D("files/audio/halloween/smokescream.mp3", localPlayer:getPosition())
	sound:setMaxDistance(75)
    sound:setVolume(2)
    sound:setDimension(locaPlayer:getDimension())

    self.m_QuestMessage:setText("Kehre nun zum Friedhof zurück!")
    self:setSucceeded()
end

function KillBigSmokeQuest:endQuest()
    self:createDialog(false, 
        "Du hast den Geist vertrieben?",
        "Gut gemacht!",
        "Hier, eine Belohnung für deine Arbeit!"
    )
end