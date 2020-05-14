-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Guns/DesertEagle.lua
-- *  PURPOSE:     Client Desert Eagle Class
-- *
-- ****************************************************************************

DesertEagle = inherit(Singleton)

function DesertEagle:constructor()
    self.m_HandleAimBind = bind(self.handleAim, self)
    self.m_WeaponFireBind = bind(self.onWeaponFire, self)
    self.m_WeaponSwitchBind = bind(self.onWeaponSwitch, self)
    self.m_UpdateBind = bind(self.update, self)

    self.m_LastShot = 0

    addEventHandler("onClientPlayerWeaponFire", localPlayer, self.m_WeaponFireBind)
    addEventHandler("onClientPlayerWeaponSwitch", localPlayer, self.m_WeaponSwitchBind)
end

function DesertEagle:destructor()

end

function DesertEagle:onWeaponFire(weapon)
    if weapon == 24 then
        self:bindKeys()
        if not isPedDucked(localPlayer) then
            self.m_LastShot = getTickCount()

            if not self.m_Aiming then
                toggleControl("crouch", false)
        
                if isTimer(self.m_CrouchTimer) then
                    self.m_CrouchTimer:destroy()
                end

                self.m_CrouchTimer = setTimer(
                    function()
                        toggleControl("crouch", true)
                    end
                , 700, 1)
            end
        end
    end
end

function DesertEagle:onWeaponSwitch(prev, current)
    if localPlayer:getWeapon(newSlot) == 24 then
        addEventHandler("onClientPreRender", root, self.m_UpdateBind)
        self:bindKeys()
    else
        if isEventHandlerAdded("onClientPreRender", root, self.m_UpdateBind) then
            removeEventHandler("onClientPreRender", root, self.m_UpdateBind)
            toggleControl("aim_weapon", true)
            self:unbindKeys()
        end
    end
end

function DesertEagle:handleAim(key, state)
    if state == "down" then 
        self.m_isAiming = true
    else
        self.m_isAiming = false
    end
end

function DesertEagle:update()
    toggleControl("aim_weapon", false)
    
    if self.m_isAiming then
        setPedControlState(localPlayer, "aim_weapon", true)
    else
        if getTickCount() - self.m_LastShot > 700 then
            setPedControlState(localPlayer, "aim_weapon", false)
        end
    end
end

function DesertEagle:bindKeys()
    self:unbindKeys()
    for key, state in pairs(getBoundKeys("aim_weapon")) do
        bindKey(key, "both", self.m_HandleAimBind)
    end
end

function DesertEagle:unbindKeys()
    for key, state in pairs(getBoundKeys("aim_weapon")) do
        unbindKey(key, "both", self.m_HandleAimBind)
    end
end