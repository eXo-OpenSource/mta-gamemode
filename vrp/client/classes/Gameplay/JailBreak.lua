-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/JailBreak.lua
-- *  PURPOSE:     Jailbreak class
-- *
-- ****************************************************************************
JailBreak = inherit(Singleton)

function JailBreak:constructor()
    self.m_ElevatorMusic = createColSphere(3010.29, -2125.96, 1209.33, 3)
    self.m_ElevatorMusic:setDimension(5)
    addEventHandler("onClientColShapeHit", self.m_ElevatorMusic, bind(self.ElevatorMusic_Hit, self))
end

function JailBreak:ElevatorMusic_Hit(hitElement, matchingDimension)
    if hitElement == localPlayer and matchingDimension then
        playSound("https://jusonex.net/public/saonline/ElevatorMusic.ogg")
    end
end
