-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Guns/DesertEagle.lua
-- *  PURPOSE:     Client Desert Eagle Class
-- *
-- ****************************************************************************

DesertEagle = inherit(Singleton)
DesertEagle.AimLockTime = 600
DesertEagle.NoScopeCrouchBlockTime = 700

function DesertEagle:constructor()
    self.m_HandleAimBind = bind(self.handleAim, self)
    self.m_WeaponFireBind = bind(self.onWeaponFire, self)
    self.m_WeaponSwitchBind = bind(self.onWeaponSwitch, self)
    self.m_StandUpBind = bind(self.onStandUp, self)
    self.m_UpdateBind = bind(self.update, self)

    self.m_LastShot = 0

    bindKey("crouch", "down", self.m_StandUpBind)
    bindKey("sprint", "down", self.m_StandUpBind)
    bindKey("jump", "down", self.m_StandUpBind)

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
            self.m_AllowRelease = false
            self.m_ForceAllowRelease = false

            if not self.m_isAiming then
                toggleControl("crouch", false)
        
                if isTimer(self.m_CrouchTimer) then
                    self.m_CrouchTimer:destroy()
                end

                self.m_CrouchTimer = setTimer(
                    function()
                        toggleControl("crouch", true)
                    end
                , DesertEagle.NoScopeCrouchBlockTime, 1)
            end
        end
    end
end

function DesertEagle:onWeaponSwitch(prev, current)
    if localPlayer:getWeapon(newSlot) == 24 then
        self.m_isAiming = false
        addEventHandler("onClientPreRender", root, self.m_UpdateBind)
        self:bindKeys()
        if getPedTask(localPlayer, "secondary", 0) == "TASK_SIMPLE_FIGHT" then
            self:onWeaponFire(24)
        end
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
    local timeSinceLastShot = getTickCount() - self.m_LastShot
    toggleControl("aim_weapon", false)


    if timeSinceLastShot > DesertEagle.AimLockTime then
        self.m_AllowRelease = true
    else
        --Check for Object near player that would abort the animation
        if not isPedDucked(localPlayer) then
            local x, y, z = getElementPosition(localPlayer)
            local mX, mY, mZ = getPedWeaponMuzzlePosition(localPlayer)
            local distance = getDistanceBetweenPoints3D(x, y, z, mX, mY, mZ)
            if distance > 0.6 and distance < 0.8 then
                self.m_ForceAllowRelease = true
            end
        end
    end
    
    if self.m_isAiming then
        setPedControlState(localPlayer, "aim_weapon", true)
    else
        if self.m_AllowRelease or self.m_ForceAllowRelease then
            setPedControlState(localPlayer, "aim_weapon", false)
        end
    end
end

function DesertEagle:onStandUp()
    --Prevent a sync bug when pressing left or right instantly after pressing the button to stand up
    if getPedWeapon(localPlayer) == 24 then
        if self:isPlayerCrouching() then
            toggleControl("left", false)
            toggleControl("right", false)

            setTimer(
                function()
                    toggleControl("left", true)
                    toggleControl("right", true)
                end
            , 200, 1)
        end
    end
end

function DesertEagle:isPlayerCrouching() 
    --hacky way to really check if a player is crouching
    if isPedDucked(localPlayer) then
        local x, y, z = getPedBonePosition(localPlayer, 1)
        local fX, fY, fZ = getPedBonePosition(localPlayer, 53)
        local distance = getDistanceBetweenPoints3D(x, y, z, fX, fY, fZ)
        if distance < 0.4 then
            return true
        end
    end
    return false
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