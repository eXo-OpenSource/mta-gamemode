-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/NetworkMonitor.lua
-- *  PURPOSE:     Class to monitor the network-status 
-- *
-- ****************************************************************************


NetworkMonitor = inherit(Singleton)
local NETWORK_MONITOR_INTERVAL = 250 --// ms
local NETWORK_PACKET_LOSS_THRESHOLD = 5 --// loss%
local NETWORK_PACKET_LOSS_OVER_ALL_THRESHOLD = 50 --// loss%
local MAX_PING_THRESHOLD = 30 --// % 
function NetworkMonitor:constructor()
    self.m_BindFunc = bind(self.monitor, self)
    self.m_NetMonitor = setTimer(self.m_BindFunc, NETWORK_MONITOR_INTERVAL, 0)
    self.m_Ping = 0
    self.m_PingAverage = 0
    self.m_PingCount = 0
    self.m_LastOutput = getTickCount()
    self.m_LastPingOutput = getTickCount()
end

function NetworkMonitor:monitor()
    local loss = self:check("packetlossLastSecond") or self:check("packetlossTotal") 
    if loss then 
        if getTickCount() >= self.m_LastOutput + 2000 then
            self.m_LastOutput = getTickCount()
            outputChatBox(("[Network] #ffffffDeine Handlung wird eingeschränkt, aufgrund eines sehr hohen Paketverlustes: #ff0000%s%%"):format(math.ceil(loss, 2)), 255, 0, 0, true)
        end
    end
    local ping = self:ping()
    if ping then 
        if getTickCount() >= self.m_LastPingOutput + 2000 then 
            self.m_LastPingOutput = getTickCount()
            outputChatBox(("[Network] #ffffffDeine Handlung wird eingeschränkt, aufgrund einer sehr hohen Pingschwankung: #ff0000%s ms"):format(math.ceil(self.m_PingAverage, 2)), 255, 0, 0, true)
        end
    end
end

function NetworkMonitor:ping()
    self.m_Ping = self.m_Ping + getPlayerPing(localPlayer)
    self.m_PingCount = self.m_PingCount + 1 
    local lastAverage = self.m_PingAverage
    local ping = getPlayerPing(localPlayer)
    self.m_PingAverage = self.m_Ping / self.m_PingCount
    if self.m_PingAverage < ping then
        if (self.m_PingAverage / ping) > MAX_PING_THRESHOLD then 
            if not self.m_PingDisabled then 
                self.m_FireControl = isControlEnabled("fire")
                self.m_ForwardControl = isControlEnabled("forwards")
                self.m_LeftControl = isControlEnabled("left")
                self.m_RightControl = isControlEnabled("right")
                self.m_JumpControl = isControlEnabled("jump")
                self.m_BackwardControl = isControlEnabled("backwards")
                self.m_AimControl = isControlEnabled("aim_weapon")
                self.m_CrouchControl = isControlEnabled("crouch")
                self.m_PingDisabled = true
                self:disableActions()
            end
        else 
            if self.m_PingDisabled then 
                self.m_PingDisabled = false 
                self:enableActions()
            end
        end
    else 
        if self.m_PingDisabled then 
            self.m_PingDisabled = false 
            self:enableActions()
        end
    end
    if self.m_PingCount > 200 then 
        self.m_PingCount = 0
        self.m_Ping = 0
        self.m_PingAverage = 0
    end
    outputChatBox( (self.m_PingAverage / ping).." "..self.m_PingCount )
end

function NetworkMonitor:check( type )
    local loss =  getNetworkStats()[type]
    local limit = type == "packetlossLastSecond" and NETWORK_PACKET_LOSS_THRESHOLD or NETWORK_PACKET_LOSS_OVER_ALL_THRESHOLD
    if loss and loss > limit then 
        if not self.m_ActionsDisabled then
            self.m_FireControl = isControlEnabled("fire")
            self.m_ForwardControl = isControlEnabled("forwards")
            self.m_LeftControl = isControlEnabled("left")
            self.m_RightControl = isControlEnabled("right")
            self.m_JumpControl = isControlEnabled("jump")
            self.m_BackwardControl = isControlEnabled("backwards")
            self.m_AimControl = isControlEnabled("aim_weapon")
            self.m_CrouchControl = isControlEnabled("crouch")
            self.m_ActionsDisabled = true
            self:disableActions()
            return loss
        end
    else 
        if self.m_ActionsDisabled then 
            self.m_ActionsDisabled = false
            self:enableActions()
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
    if self.m_FireControl then setTimer(toggleControl, 2000, 1, "fire", true) end
    if self.m_AimControl then setTimer(toggleControl, 2000, 1, "aim_weapon", true) end
    if self.m_ForwardControl then setTimer(toggleControl, 2000, 1, "forwards", true) end
    if self.m_BackwardControl then setTimer(toggleControl, 2000, 1, "backwards", true) end
    if self.m_LeftControl then setTimer(toggleControl, 2000, 1, "left", true) end
    if self.m_RightControl then setTimer(toggleControl, 2000, 1, "right", true) end
    if self.m_JumpControl then setTimer(toggleControl, 2000, 1, "jump", true) end
    if self.m_CrouchControl then setTimer(toggleControl, 2000, 1, "crouch", true) end
end