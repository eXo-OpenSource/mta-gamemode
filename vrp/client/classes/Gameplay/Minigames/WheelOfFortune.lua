-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Minigames/WheelOfFortune.lua
-- *  PURPOSE:     create a wheel of fortune and manage it
-- *
-- ****************************************************************************

WheelOfFortune = inherit(Singleton)
addRemoteEvents{"WheelOfFortunePlaySound"}

function WheelOfFortune:constructor()
    
   -- self.m_WheelTexture = StaticFileTextureReplacer:new("WheelOfFortune.png", "white256")
    addEventHandler("WheelOfFortunePlaySound", resourceRoot, bind(WheelOfFortune.playWheelSound, self))
end

function WheelOfFortune:playWheelSound(x, y, z, time)
    local sound = playSFX3D("script", 157, 0, x, y, z, true)
	setTimer(setSoundSpeed, time*0.7, 1, sound, 0.8)
	setTimer(destroyElement, time*0.95, 1, sound)
end