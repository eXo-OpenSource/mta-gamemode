-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/NetworkMonitor.lua
-- *  PURPOSE:     Class to monitor the network-status 
-- *
-- ****************************************************************************


NetworkMonitor = inherit(Singleton)
local NETWORK_MONITOR_INTERVAL = 500 --// ms
local NETWORK_PACKET_LOSS_THRESHOLD = 5 --// loss%
function NetworkMonitor:constructor()
    self.m_BindFunc = bind(self.monitor, self)
    self.m_NetMonitor = setTimer(self.m_BindFunc, NETWORK_MONITOR_INTERVAL, 0)
end

function NetworkMonitor:monitor()
    local loss = self:check("packetlossLastSecond") or self:check("packetlossTotal") 
    if loss then 
        outputChatBox(("Deine Handlung wird eingeschränkt aufgrund eines sehr hohen Paketverlustes: %s"):format(loss), 200, 0, 0)
    end
end

function NetworkMonitor:check( type )
    local loss =  getNetworkStats()[type]
    if loss and loss > NETWORK_PACKET_LOSS_THRESHOLD then 
        if not self.m_ActionsDisabled then
            self.m_FireControl = isControlEnabled("fire")
            self.m_AimControl = isControlEnabled("aim_weapon")
            self.m_IsFrozen = getElementFrozen(localPlayer)
            self.m_ActionsDisabled = true
            self:disableActions()
            return loss
        end
    else 
        if self.m_ActionsDisabled then 
            self:enableActions()
        end
    end 
    return false
end

function NetworkMonitor:disableActions()
    toggleControl("fire", false)
    toggleControl("aim_weapon", false)
    setElementFrozen(localPlayer, false)
end

function NetworkMonitor:enableActions() 
    if not self.m_FireControl then toggleControl("fire", true) end
    if not self.m_AimControl then toggleControl("aim_weapon", true) end
    if not self.m_IsFrozen then setElementFrozen(localPlayer, false) end
end