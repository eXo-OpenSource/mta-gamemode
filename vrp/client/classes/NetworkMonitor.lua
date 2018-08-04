-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/NetworkMonitor.lua
-- *  PURPOSE:     Class to monitor the network-status 
-- *
-- ****************************************************************************


NetworkMonitor = inherit(Singleton)
NETWORK_MONITOR_INTERVAL = 250 --// ms
NETWORK_PACKET_LOSS_THRESHOLD = 5   --// loss%
NETWORK_PACKET_LOSS_OVER_ALL_THRESHOLD = 70 --// loss%
MAX_PING_THRESHOLD = 300 --// % 
MIN_PING_TRIGGER = 400 --// ms
function NetworkMonitor:constructor()
    self.m_NetMonitor = setTimer( bind(self.monitor, self), NETWORK_MONITOR_INTERVAL, 0)
    self.m_Ping = 0
    self.m_PingAverage = 0
    self.m_PingCount = 0
    self.m_LastOutput = getTickCount()
    self.m_LastPingOutput = getTickCount()
    self.m_WarnCount = 0
end

function NetworkMonitor:monitor()
    local loss = self:check("packetlossLastSecond") or self:check("packetlossTotal") 
    if loss then 
        if getTickCount() >= self.m_LastOutput + 15000 then
            self.m_LastOutput = getTickCount()
            outputChatBox(("[Network] #ffffffDeine Handlung wird eingeschränkt, aufgrund eines sehr hohen Paketverlustes: #ff0000%s%%"):format(math.ceil(loss, 2)), 255, 0, 0, true)
        end
    end
    local ping = self:ping()
    if ping then 
        if getTickCount() >= self.m_LastPingOutput + 15000 then 
            self.m_LastPingOutput = getTickCount()
            outputChatBox(("[Network] #ffffffDeine Handlung wird eingeschränkt, aufgrund einer sehr hohen Pingschwankung: #ff0000%s ms"):format(MIN_PING_TRIGGER+math.ceil(self.m_PingAverage, 2)), 255, 0, 0, true)
        end
    end
end

function NetworkMonitor:getPingDisabled()
    return self.m_PingDisabled
end


function NetworkMonitor:getLossDisabled()
    return self.m_ActionsDisabled
end

function NetworkMonitor:ping()
    self.m_Ping = self.m_Ping + getPlayerPing(localPlayer)
    self.m_PingCount = self.m_PingCount + 1 
    local lastAverage = self.m_PingAverage
    local ping = getPlayerPing(localPlayer) > 0 and getPlayerPing(localPlayer) or 1
    self.m_PingAverage = self.m_Ping / self.m_PingCount
    if ping > MIN_PING_TRIGGER and self.m_PingAverage > 0 and self.m_PingAverage < ping then
        if ( ping / self.m_PingAverage )*100 > MAX_PING_THRESHOLD then 
            self.m_WarnCount = self.m_WarnCount + 1
            if not self.m_PingDisabled then 
                if self.m_WarnCount > 12 then
                    self.m_PingDisabled = true
                    self:disableActions()
                    return true
                end
            end
        else 
            if self.m_PingDisabled then 
                self:enableActions()
                self.m_WarnCount = 0 
                self.m_PingDisabled = false 
            end
        end
    else 
        if self.m_PingDisabled then 
            self.m_PingDisabled = false 
            self:enableActions()
            self.m_WarnCount = 0 
        end
    end
    if self.m_PingCount > 2000 then 
        self.m_PingCount = 0
        self.m_Ping = 0
        self.m_PingAverage = 0
    end
    return false
end

function NetworkMonitor:check( type )
    local loss =  getNetworkStats()[type]
    local limit = type == "packetlossLastSecond" and NETWORK_PACKET_LOSS_THRESHOLD or NETWORK_PACKET_LOSS_OVER_ALL_THRESHOLD
    if loss and loss > limit then 
        self.m_WarnCount = self.m_WarnCount + 1
        if not self.m_ActionsDisabled then
            if self.m_WarnCount >  12 then
                self.m_ActionsDisabled = true
                self:disableActions()
                return loss
            end
        end
    else 
        if self.m_ActionsDisabled then 
            self.m_ActionsDisabled = false
            if not self.m_PingDisabled then
                self:enableActions()
                self.m_WarnCount  = 0
            end
        end
    end 
    return false
end

function NetworkMonitor:disableActions()
    toggleControl("fire", false)
    toggleControl("aim_weapon", false)
    toggleControl("crouch", false)
    toggleControl("forwards", false)
    toggleControl("backwards", false)
    toggleControl("left", false)
    toggleControl("right", false)
    toggleControl("crouch", false)
    setPedWeaponSlot(localPlayer, 0)
end

function NetworkMonitor:enableActions() 
    setTimer(toggleControl, 500, 1, "fire", true) 
    setTimer(toggleControl, 500, 1, "aim_weapon", true)
    setTimer(toggleControl, 500, 1, "forwards", true) 
    setTimer(toggleControl, 500, 1, "backwards", true) 
    setTimer(toggleControl, 500, 1, "left", true) 
    setTimer(toggleControl, 500, 1, "right", true) 
    setTimer(toggleControl, 500, 1, "jump", true) 
    setTimer(toggleControl, 500, 1, "crouch", true) 
end