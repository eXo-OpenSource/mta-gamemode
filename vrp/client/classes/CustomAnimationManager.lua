-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/CustomAnimationManager.lua
-- *  PURPOSE:     Custom IFP Animations Manager
-- *
-- ****************************************************************************

CustomAnimationManager = inherit(Singleton)

addRemoteEvents{"CustomAnimationManager:syncAnimation"}

function CustomAnimationManager:constructor()
    for path, block in pairs(CUSTOM_ANIMATION_IFP) do
        engineLoadIFP(path, block)
    end
    
    addEventHandler("CustomAnimationManager:syncAnimation", getRootElement(), bind(self.syncAnimation, self))
    addCommandHandler("customanim", bind(self.startAnimation, self))
end

function CustomAnimationManager:startAnimation(_, ...)
    triggerServerEvent("CustomAnimationManager:startAnimation", localPlayer, self:getPlayersStreamedIn(), table.concat({...}, " "))
end

function CustomAnimationManager:syncAnimation(player, animation)
    player:setAnimation(animation["block"], animation["animation"], -1, animation["loop"], animation["updatePosition"], animation["interruptable"], animation["freezeLastFrame"])
end

function CustomAnimationManager:getPlayersStreamedIn()
    local players = {}
    for i, player in pairs(getElementsByType("player", root, true)) do
        table.insert(players, player)
    end
    return players
end

function CustomAnimationManager:destructor()
end