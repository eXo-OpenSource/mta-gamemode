-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Events/Halloween/HalloweenGhost.lua
-- *  PURPOSE:     Halloween Ghost class
-- *
-- ****************************************************************************

HalloweenGhost = inherit(Object)
HalloweenGhost.Map = {}
HalloweenGhost.MarkerSpeed = 750
HalloweenGhost.AttackCooldown = 2500
HalloweenGhost.MarkerSize = 2.5

function HalloweenGhost:constructor(pos, rot, int, dim, isAmbientGhost, callbackOnKill)
    HalloweenGhost.Map[#HalloweenGhost.Map+1] = self
    self.m_Ped = createPed(260, pos+Vector3(0,0,-50), rot)
    self.m_Ped:setInterior(int)
    self.m_Ped:setDimension(dim)
    if isAmbientGhost then
        self.m_Ped:setAlpha(0)
    end
    self.m_Ped.m_isClientSided = true
    self.m_Ped:setData("NPC:Immortal", true)
    self.m_MoveObject = createObject(1337, pos+Vector3(0,0,-50), 0, 0, rot)
    self.m_MoveObject:setInterior(int)
    self.m_MoveObject:setDimension(dim)
    self.m_MoveObject:setAlpha(0)
    self.m_MoveObject:setCollisionsEnabled(false)
    self.m_Ped:attach(self.m_MoveObject)
    self.m_SpawnPosition = pos
    self.m_SpawnRotation = rot
    self.m_SpawnInterior = int
    self.m_SpawnDimension = dim
    self.m_IsAmbientGhost = isAmbientGhost
    self.m_CallBack = callbackOnKill

    self.m_Health = 3
    self.m_Alpha = 255
    nextframe(
        function()
            self.m_MoveObject:setPosition(self.m_SpawnPosition)
        end
    )
    self.m_DamageBind = bind(self.onDamage, self)
    addEventHandler("onClientPedDamage", self.m_Ped, self.m_DamageBind)
    self.m_RenderBind = bind(self.render, self)
    self.m_PreRenderBind = bind(self.preRender, self)
    self.m_MarkerHitBind = bind(self.onMarkerHit, self)
end

function HalloweenGhost:virtual_destructor()
    if isEventHandlerAdded("onClientRender", root, self.m_RenderBind) then
        removeEventHandler("onClientRender", root, self.m_RenderBind)
    end
    if isEventHandlerAdded("onClientPedDamage", self.m_Ped, self.m_DamageBind) then
        removeEventHandler("onClientPedDamage", self.m_Ped, self.m_DamageBind)
    end
    if isEventHandlerAdded("onClientPreRender", root, self.m_PreRenderBind) then
        removeEventHandler("onClientPreRender", root, self.m_PreRenderBind)
    end
    if self.m_Ped and isElement(self.m_Ped) then
        self.m_Ped:destroy()
    end
    if self.m_MoveObject and isElement(self.m_MoveObject) then
        self.m_MoveObject:destroy()
    end
    if self.m_Marker and isElement(self.m_Marker) then
        self.m_Marker:destroy()
    end
    if isTimer(self.m_KillTimer) then
        killTimer(self.m_KillTimer)
    end
    local idx = table.find(HalloweenGhost.Map, self)
    if idx then
        table.remove(HalloweenGhost.Map, idx)
	end
end

function HalloweenGhost.destroyAll()
    for i = #HalloweenGhost.Map, 1, -1 do
        if not HalloweenGhost.Map[i].m_IsAmbientGhost then
            HalloweenGhost.Map[i]:destroy()
        end
    end
end

function HalloweenGhost:move(units)
    if isElement(self.m_MoveObject) then
        self.m_VisibleStartTime = getTickCount()
        self.m_VisibleEndTime = getTickCount() + 750
        self.m_MoveTime = math.random(3, 12) * 1000
        self.m_InvisibleStartTime = getTickCount() + self.m_MoveTime - 750
        self.m_InvisibleEndTime = getTickCount() + self.m_MoveTime

        self.m_MoveObject:move(self.m_MoveTime, self.m_MoveObject.position + self.m_MoveObject.matrix.forward*units)

        addEventHandler("onClientRender", root, self.m_RenderBind)

        self.m_KillTimer = setTimer(bind(self.destroy, self), self.m_MoveTime, 1)
    end
end

function HalloweenGhost:render()
    if isElementOnScreen(self.m_Ped) then
        if getTickCount() > self.m_InvisibleStartTime then
            local now = getTickCount()
	        local elapsedTime = now - self.m_InvisibleStartTime
	        local duration = self.m_InvisibleEndTime - self.m_InvisibleStartTime
	        local progress = elapsedTime / duration
            alpha = interpolateBetween(self.m_Alpha, 0, 0, 0, 0, 0, progress, "Linear")
            if alpha > 0 and alpha < self.m_Alpha then
                self.m_Ped:setAlpha(alpha)
            end
            if alpha < 1 then
                self:destroy()
            end
        elseif getTickCount() <= self.m_VisibleEndTime then
            local now = getTickCount()
	        local elapsedTime = now - self.m_VisibleStartTime
	        local duration = self.m_VisibleEndTime - self.m_VisibleStartTime
	        local progress = elapsedTime / duration
            alpha = interpolateBetween(0, 0, 0, self.m_Alpha, 0, 0, progress, "Linear")
            if alpha > 0 and alpha < self.m_Alpha then
                self.m_Ped:setAlpha(alpha)
            end
        end
    end
end

function HalloweenGhost:kill()
    self.m_InvisibleStartTime = getTickCount()
    self.m_InvisibleEndTime = getTickCount() + 750
    if not isEventHandlerAdded("onClientRender", root, self.m_RenderBind) then
        addEventHandler("onClientRender", root, self.m_RenderBind)
    end
    removeEventHandler("onClientPedDamage", self.m_Ped, self.m_DamageBind)
    if self.m_CallBack then
        self.m_CallBack()
    end
end

function HalloweenGhost:onDamage(attacker, weapon)
    if attacker == localPlayer then
        if weapon == 27 then
            self.m_Health = self.m_Health - 1
            if self.m_Health == 0 then
                self:kill()
            end
        end
    end
end

function HalloweenGhost:destroy()
    delete(self)
end

function HalloweenGhost:setAttackMode(state)
    if state then
        addEventHandler("onClientPreRender", root, self.m_PreRenderBind)
        self.m_LastAttack = 0
    else
        removeEventHandler("onClientPreRender", root, self.m_PreRenderBind)
        if isElement(self.m_Marker) then
            self.m_Marker:destroy()
        end
    end
end

function HalloweenGhost:preRender()
    local x1, y1, z1 = getElementPosition(self.m_Ped)
    local x2, y2, z2 = getElementPosition(localPlayer)
    if getDistanceBetweenPoints3D(x1, y1, z1, x2, y2, z2) > 50 then
        return
    end

    local rotation = findRotation(x1, y1, x2, y2)
    local position = self.m_Ped.position + self.m_Ped.matrix.forward * 1.5 + Vector3(0,0,0.15)

    self.m_Ped:setRotation(0, 0, rotation)

    if getTickCount() - self.m_LastAttack > HalloweenGhost.AttackCooldown then
        if not isElement(self.m_Marker) then
            if isLineOfSightClear(x1, y1, z1, x2, y2, z2, true, true, false, true, true, true, false) then
                self.m_Marker = createMarker(position, "corona", 0, 255, 255, 255, 250)
                self.m_Marker:setInterior(self.m_SpawnInterior)
                self.m_Marker:setDimension(self.m_SpawnDimension)
                addEventHandler("onClientMarkerHit", self.m_Marker, self.m_MarkerHitBind)
                self.m_MarkerVisibleStartTime = getTickCount()
                self.m_MarkerVisibleEndTime = self.m_MarkerVisibleStartTime + 1000
                self.m_IsMarkerMoving = false
            end
        end
    end

    if isElement(self.m_Marker) then
        if not self.m_IsMarkerMoving then
            self.m_Marker:setPosition(position)
        end

        if self.m_Marker:getSize() < HalloweenGhost.MarkerSize then
            if getTickCount() > self.m_MarkerVisibleStartTime then
                local now = getTickCount()
	            local elapsedTime = now - self.m_MarkerVisibleStartTime
	            local duration = self.m_MarkerVisibleEndTime - self.m_MarkerVisibleStartTime
	            local progress = elapsedTime / duration
                size = interpolateBetween(0.0, 0, 0, HalloweenGhost.MarkerSize, 0, 0, progress, "InQuad")
                self.m_Marker:setSize(size)
            end
        else
            if not self.m_IsMarkerMoving then
                self.m_IsMarkerMoving = true
                self.m_MarkerMoveStartTime = getTickCount()
                self.m_MarkerMoveEndTime = self.m_MarkerMoveStartTime + HalloweenGhost.MarkerSpeed
                self.m_MarkerPosition = position
                self.m_PlayerPosition = localPlayer:getPosition()
                self.m_NormalVector = Vector3(self.m_PlayerPosition - self.m_MarkerPosition)
                self.m_NormalVector:normalize()
            else
                if getTickCount() < self.m_MarkerMoveEndTime then
                    local now = getTickCount()
                    local elapsedTime = now - self.m_MarkerMoveStartTime
                    local duration = self.m_MarkerMoveEndTime - self.m_MarkerMoveStartTime
                    local progress = elapsedTime / duration
                    local x, y, z = interpolateBetween(self.m_MarkerPosition.x, self.m_MarkerPosition.y, self.m_MarkerPosition.z, self.m_PlayerPosition.x+(self.m_NormalVector.x*4), self.m_PlayerPosition.y+(self.m_NormalVector.y*4), self.m_PlayerPosition.z+(self.m_NormalVector.z*4), progress, "InQuad")
                    self.m_Marker:setPosition(x, y, z)
                else
                    self.m_Marker:destroy()
                    self.m_LastAttack = getTickCount()
                end
            end
        end
    end
end

function HalloweenGhost:onMarkerHit(hitElement)
    if hitElement == localPlayer then
        localPlayer:setHealth(localPlayer:getHealth()-20)
        Guns:getSingleton():bloodScreen()
    end
end

function HalloweenGhost:setAlpha(alpha)
    self.m_Alpha = alpha
    self.m_Ped:setAlpha(alpha)
end

function HalloweenGhost:setModel(model)
    self.m_Ped:setModel(model)
end

function HalloweenGhost:setHealth(health)
    self.m_Health = health
end