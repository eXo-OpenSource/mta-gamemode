-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************

FerrisGond = inherit(Object)
FerrisGond.Map = {}
FerrisGond.DistToWheel = 11.75
addRemoteEvents{"onFerrisWheelGondClicked"}

function FerrisGond:constructor(wheel, id)
    if not FerrisGond.Map[wheel] then
        FerrisGond.Map[wheel] = {}
    end
    self.m_Wheel = wheel
    self.m_Id = id
    self.m_Offset = (360/FerrisWheelManager.GondAmount * id) + 18
    self.m_ClientGondHandler = bind(FerrisGond.clientGond, self)
    self.m_Occupants = {}
    self:createObject()
end

function FerrisGond:createObject()
    if not self.m_Object then
        local wheel = self.m_Wheel.m_WheelObj
        self.m_Object = createObject(FERRIS_IDS.Gond, self:getAttachedPositionVertical(), wheel.rotation)
        addEventHandler("onFerrisWheelGondClicked", self.m_Object, self.m_ClientGondHandler)
    end
end

function FerrisGond:update(rot, time, movingState)
    local wheel = self.m_Wheel.m_WheelObj
    self.m_Offset = (self.m_Offset - rot) % 360
    self.m_Object:move(time, self:getAttachedPositionVertical(), Vector3(0,0,0), movingState)
end

function FerrisGond:clientGond()
    if self.m_Wheel.m_MovingState then
        return client:sendWarning(_("Warte, bis die Gondel anhält!",client))
    end
    if client.m_FerrisGond then 
        return client.m_FerrisGond:removePlayer(client)
    elseif table.size(self.m_Occupants) > 2 then 
        return client:sendWarning(_("Diese Gondel ist bereits voll!",client))
    elseif client:getMoney() < 10 then
        return client:sendError(_("Du benötigst 10$!",client))
    end

    client:transferMoney(FerrisWheelManager:getSingleton():getBankAccount(), 10, "Riesenrad", "Gameplay", "FerrisWheel")
    client:sendShortMessage(_("Bewege deine Kamera mit der Maus, zoome mit dem Mausrad. Du kannst frühzeitig aussteigen, wenn du bei angehaltenem Riesenrad auf eine Gondel klickst.", client), _("Riesenrad", client), {0, 50, 100}, 10000)
    self.m_Occupants[client] = getTickCount()
    client.m_FerrisGond = self
    client:attach(self.m_Object, 0, table.size(self.m_Occupants) == 1 and 0.4 or -0.4, -1.4)
    client:triggerEvent("startCenteredFreecam", self.m_Object, 20)
    self.m_Wheel:startMoving()
end

function FerrisGond:removePlayer(player)
    if self.m_Occupants[player] then
        self.m_Occupants[player] = nil
        player.m_FerrisGond = nil
        if isElement(player) then
            player:detach(self.m_Object)
            player:triggerEvent("stopCenteredFreecam")
            self.m_Wheel:setPlayerToExitPosition(player, self.m_Id)
            triggerEvent("onFerrisWheelRide", player) -- For Quest
            player:sendShortMessage(_("Vielen Dank für die Mitfahrt, auf wiedersehen!", player), _("Riesenrad", player), {0, 50, 100})
        end
        if not self.m_Wheel:isWheelInUse() then
            self.m_Wheel:abortMovingStart()
        end
    else
        outputDebugString("gond for player "..inspect(player).." not found!")
    end
end

function FerrisGond:forceRemovePlayers()
    for i,v in pairs(self.m_Occupants) do
        self:removePlayer(i)
    end
end



function FerrisGond:getAttachedPositionVertical()
    local wheel = self.m_Wheel.m_WheelObj
    local rot = wheel.rotation
    local angleAttached = rot.x + self.m_Offset
  
    local dx = math.sin(math.rad(angleAttached))* FerrisGond.DistToWheel
    local dy = math.cos(math.rad(angleAttached))* FerrisGond.DistToWheel

    return wheel.matrix:transformPosition(Vector3(0, dx, dy))
end