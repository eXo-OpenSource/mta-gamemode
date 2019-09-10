-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Tutorial.lua
-- *  PURPOSE:     eXo Tutorial Class
-- *
-- ****************************************************************************

Tutorial = inherit(GUIForm)
inherit(Singleton, Tutorial)
Tutorial.fadeInTime = 1000
Tutorial.fadeCameraTime = 3
Tutorial.startTime = 3000

function Tutorial.start()
    fadeCamera(false, Tutorial.fadeCameraTime)
    Tutorial.sound = playSound("files/audio/theme.mp3")
    setTimer(function()
        Tutorial:new()
    end, Tutorial.startTime, 1)
end
addEventHandler("startTutorial", resourceRoot, Tutorial.start)

function Tutorial:constructor()
    GUIForm.constructor(self, 0, 0, screenWidth, screenHeight)
    self.m_Logo = GUIImage:new(screenWidth/2 - 350/2, screenHeight/2 - 200/2 - 120, 350, 167, "files/images/Logo.png", self)
    Animation.FadeIn:new(self.m_Logo, Tutorial.fadeInTime)
    setTimer(function()
        Animation.FadeOut:new(self.m_Logo, Tutorial.fadeInTime)
    end
    , 4000, 1)
    playSound("files/audio/logosound.mp3"):setVolume(2)
end

function Tutorial:destructor()
    GUIForm.destructor(self)
    stopSound(Tutorial.sound)
end