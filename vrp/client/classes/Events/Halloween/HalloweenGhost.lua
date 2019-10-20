-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Events/Halloween/HalloweenGhost.lua
-- *  PURPOSE:     Halloween Ghost class
-- *
-- ****************************************************************************

HalloweenGhost = inherit(Object)
HalloweenGhost.Map = {}

function HalloweenGhost:constructor(pos, rot)
    HalloweenGhost.Map[#HalloweenGhost.Map+1] = self
    self.m_Ped = createPed(260, pos+Vector3(0,0,-50), rot)
    self.m_Ped:setAlpha(0)
    self.m_Ped.m_isClientSided = true
    self.m_Ped:setData("NPC:Immortal", true)
    self.m_MoveObject = createObject(1337, pos+Vector3(0,0,-50), 0, 0, rot)
    self.m_MoveObject:setAlpha(0)
    self.m_MoveObject:setCollisionsEnabled(false)
    self.m_Ped:attach(self.m_MoveObject)
    self.m_SpawnPosition = pos
    self.m_SpawnRotation = rot
    nextframe(
        function()
            self.m_MoveObject:setPosition(self.m_SpawnPosition)
        end
    )
    self.m_DamageBind = bind(self.onDamage, self)
    addEventHandler("onClientPedDamage", self.m_Ped, self.m_DamageBind)
end

function HalloweenGhost:destructor()
    self.m_Ped:destroy()
    self.m_MoveObject:destroy()
    if isEventHandlerAdded("onClientRender", root, self.m_RenderBind) then
        removeEventHandler("onClientRender", root, self.m_RenderBind)
    end
    if isEventHandlerAdded("onClientPedDamage", self.m_Ped, self.m_DamageBind) then
        removeEventHandler("onClientPedDamage", self.m_Ped, self.m_DamageBind)
    end
    if isTimer(self.m_KillTimer) then
        killTimer(self.m_KillTimer)
    end
    self.m_SpawnPosition = nil
    self.m_SpawnRotation = nil
    local idx = table.find(HalloweenGhost.Map, self)
	if idx then
		table.remove(HalloweenGhost.Map, idx)
	end
end

function HalloweenGhost:move(units)
    self.m_VisibleStartTime = getTickCount()
    self.m_VisibleEndTime = getTickCount() + 750
    self.m_MoveTime = math.random(3, 12) * 1000
    self.m_InvisibleStartTime = getTickCount() + self.m_MoveTime - 750
    self.m_InvisibleEndTime = getTickCount() + self.m_MoveTime

    self.m_MoveObject:move(self.m_MoveTime, self.m_MoveObject.position + self.m_MoveObject.matrix.forward*units)

    self.m_RenderBind = bind(self.render, self)
    addEventHandler("onClientRender", root, self.m_RenderBind)

    self.m_KillTimer = setTimer(bind(self.destroy, self), self.m_MoveTime, 1)
end

function HalloweenGhost:render()
    if getTickCount() <= self.m_VisibleEndTime then
        local now = getTickCount()
	    local elapsedTime = now - self.m_VisibleStartTime
	    local duration = self.m_VisibleEndTime - self.m_VisibleStartTime
	    local progress = elapsedTime / duration
        alpha = interpolateBetween(0, 0, 0, 255, 0, 0, progress, "Linear")
        if alpha > 0 and alpha < 255 then
            self.m_Ped:setAlpha(alpha)
        end
    elseif getTickCount() > self.m_InvisibleStartTime then
        local now = getTickCount()
	    local elapsedTime = now - self.m_InvisibleStartTime
	    local duration = self.m_InvisibleEndTime - self.m_InvisibleStartTime
	    local progress = elapsedTime / duration
        alpha = interpolateBetween(255, 0, 0, 0, 0, 0, progress, "Linear")
        if alpha > 0 and alpha < 255 then
            self.m_Ped:setAlpha(alpha)
        end
        if alpha < 1 then
            self:destroy()
        end
    end
end

function HalloweenGhost:kill()
    self.m_InvisibleStartTime = getTickCount()
    self.m_InvisibleEndTime = getTickCount() + 750
    removeEventHandler("onClientPedDamage", self.m_Ped, self.m_DamageBind)
end

function HalloweenGhost:onDamage(attacker, weapon)
    if attacker == localPlayer then
        if weapon == 27 then
            self:kill()
        end
    end
end

function HalloweenGhost:destroy()
    delete(self)
end