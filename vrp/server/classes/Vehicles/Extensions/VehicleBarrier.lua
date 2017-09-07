VehicleBarrier = inherit(Object)

function VehicleBarrier:constructor(pos, rot, customOffset, customBarrierId, timeout)
  self.m_Timeout = timeout
  self.m_Closed = rot.y == 90
  self.m_Barrier = createObject(968, pos, rot)
  if not customBarrierId or customBarrierId == 1 then
      local x, y = getPointFromDistanceRotation(pos.x, pos.y, 5, 45+(90-rot.z))
      self.m_ColShape1 = ColShape.Sphere(Vector3(x, y, pos.z) + self.m_Barrier.matrix.forward*(customOffset and -customOffset or -2.5), 3)
      addEventHandler("onColShapeHit", self.m_ColShape1, bind(self.Event_onColShapeHit, self))
  end
  if not customBarrierId or customBarrierId == 2 then
      local x, y = getPointFromDistanceRotation(pos.x, pos.y, 5, (90-rot.z)-45)
      self.m_ColShape2 = ColShape.Sphere(Vector3(x, y, pos.z) + self.m_Barrier.matrix.forward*(customOffset or 2.5), 3)
      addEventHandler("onColShapeHit", self.m_ColShape2, bind(self.Event_onColShapeHit, self))
  end
end

function VehicleBarrier:Event_onColShapeHit(hitEle, matchingDimension, force)
    if hitEle:getType() == "player" and matchingDimension then
        local player = hitEle
        if not force then
            --if player:isInVehicle() and player:getOccupiedVehicleSeat() ~= 0 then
            --    return
            --end
            if self.m_Timer and isTimer(self.m_Timer) then
                killTimer(self.m_Timer)
            end
            if self.onBarrierHit and self.onBarrierHit(player) == false then
                return
            end
        end

        -- Open the Barriers
        return self:toggleBarrier(player)
     end
end

function VehicleBarrier:toggleBarrier(player)
    if self.m_Closed then
        local rot = self.m_Barrier:getRotation()
        self.m_Barrier:move(1250, self.m_Barrier:getPosition(), Vector3(0, 0-rot.y, 0), "InOutQuad")
        self.m_Closed = false

        self.m_Timer = setTimer(bind(self.Event_onColShapeHit, self, player, true, true), self.m_Timeout or 10000, 1)
        --outputDebug("Opening: "..(0-rot.y).." ["..rot.y.."; 0]")
    else
        setTimer(function() -- Cause of long vehicles (trucks and bus)
            local rot = self.m_Barrier:getRotation()
            self.m_Barrier:move(1250, self.m_Barrier:getPosition(), Vector3(0, -rot.y+90, 0), "InOutQuad")
            self.m_Closed = true
            --outputDebug("Closing: "..(-rot.y+90).." ["..rot.y.."; 90]")
        end, 2000, 1)
     end
end

function VehicleBarrier:open()
    if self.m_Closed then
        local rot = self.m_Barrier:getRotation()
        self.m_Barrier:move(1250, self.m_Barrier:getPosition(), Vector3(0, 0-rot.y, 0), "InOutQuad")
        self.m_Closed = false
    end
end

function VehicleBarrier:close()
    if not self.m_Closed then
        local rot = self.m_Barrier:getRotation()
        self.m_Barrier:move(1250, self.m_Barrier:getPosition(), Vector3(0, -rot.y+90, 0), "InOutQuad")
        self.m_Closed = true
    end
end
