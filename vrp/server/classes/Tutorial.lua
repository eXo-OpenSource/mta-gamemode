-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Tutorial.lua
-- *  PURPOSE:     eXo Tutorial Class
-- *
-- ****************************************************************************

Tutorial = inherit(Singleton)

function Tutorial:constructor()

end

function Tutorial:destructor()

end

function Tutorial:startForPlayer(player)
    player:triggerEvent("startTutorial")
end