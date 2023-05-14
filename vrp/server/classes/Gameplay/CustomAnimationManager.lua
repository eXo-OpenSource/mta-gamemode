-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/CustomAnimationManager.lua
-- *  PURPOSE:     Custom IFP Animations Manager
-- *
-- ****************************************************************************

CustomAnimationManager = inherit(Singleton)

addRemoteEvents{"CustomAnimationManager:startAnimation"}

function CustomAnimationManager:constructor()
    self.m_CustomAnimationStopBind = bind(self.stopAnimation, self)
    addEventHandler("CustomAnimationManager:startAnimation", getRootElement(), bind(self.startAnimation, self))
end

function CustomAnimationManager:startAnimation(players, animation)
    if client.isTasered then return	end
	if client.vehicle then return end
    if client:isEating() then return end 
	if client:isOnFire() then return end
	if client:getData("isInDeathMatch") then return end
	if not isControlEnabled(client, "forwards") then return end
	if client.lastAnimation and getTickCount() - client.lastAnimation < 1000 then return end
	if client:isInGangwar() then client:sendError(_("Du kannst im Gangwar keine Animationen ausführen!", client)) return end

    if CUSTOM_ANIMATIONS[animation] then
        local animation = CUSTOM_ANIMATIONS[animation]
        for i, player in pairs(players) do
            player:triggerEvent("CustomAnimationManager:syncAnimation", client, animation)
        end
        client.lastAnimation = getTickCount()
        bindKey(client, "space", "down", self.m_CustomAnimationStopBind)
    else
        client:sendError(_("Diese Animation existiert nicht!", client))
    end
end

function CustomAnimationManager:stopAnimation(player)
    player:setAnimation()
    unbindKey(player, "space", "down", self.m_CustomAnimationStopBind)
end

function CustomAnimationManager:destructor()
end
