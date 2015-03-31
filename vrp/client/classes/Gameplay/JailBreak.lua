-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/JailBreak.lua
-- *  PURPOSE:     Jailbreak class
-- *
-- ****************************************************************************
JailBreak = inherit(Singleton)
addEvent("jailBreakStart", true)

function JailBreak:constructor()
    self.m_ElevatorMusic = createColSphere(3010.29, -2125.96, 1209.33, 3)
    self.m_ElevatorMusic:setDimension(5)
    addEventHandler("onClientColShapeHit", self.m_ElevatorMusic, bind(self.ElevatorMusic_Hit, self))

    addEventHandler("jailBreakStart", root, bind(self.onStart, self))
end

function JailBreak:playSiren()
    local sound = Sound3D.create("files/audio/Siren.ogg", 3450.77, -2153.13, 17.13, true)
    --sound:setMaxDistance(500)
    Sound3D.setMaxDistance(sound, 500)

    -- Stop after 8 minutes
    setTimer(function() if isElement(sound) then sound:destroy() end end, 8*60*1000, 1)
end

function JailBreak:onStart()
    -- WARNING: This function is called for all players
    self:playSiren()
end

function JailBreak:ElevatorMusic_Hit(hitElement, matchingDimension)
    if hitElement == localPlayer and matchingDimension then
        Sound.create("files/audio/ElevatorMusic.ogg")
    end
end
