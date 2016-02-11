VehicleBarrier = inherit(Object)

function VehicleBarrier:constructor(pos, rot, customOffset)
  self.m_Closed = rot.y == 90
  self.m_Barrier = createObject(968, pos, rot)
  local x, y = getPointFromDistanceRotation(pos.x, pos.y, 5, 45+(90-rot.z))
  self.m_ColShape1 = ColShape.Sphere(Vector3(x, y, pos.z) + self.m_Barrier.matrix.forward*(customOffset and -customOffset or -2.5), 3)
  local x, y = getPointFromDistanceRotation(pos.x, pos.y, 5, (90-rot.z)-45)
  self.m_ColShape2 = ColShape.Sphere(Vector3(x, y, pos.z) + self.m_Barrier.matrix.forward*(customOffset or 2.5), 3)
  addEventHandler("onColShapeHit", self.m_ColShape1, bind(self.Event_onColShapeHit, self))
  addEventHandler("onColShapeHit", self.m_ColShape2, bind(self.Event_onColShapeHit, self))
end

function VehicleBarrier:Event_onColShapeHit(hitEle, matchingDimension)
    if hitEle:getType() == "player" and matchingDimension then
        local player = hitEle
        if player:isInVehicle() and player:getOccupiedVehicleSeat() ~= 0 then
            return
        end
        if self.m_Timer and isTimer(self.m_Timer) then
            killTimer(self.m_Timer)
        end
        if self.onBarrierHit and self.onBarrierHit(player) == false then
            return
        end
        if self.m_Closed then
            local rot = self.m_Barrier:getRotation()
            self.m_Barrier:move(1250, self.m_Barrier:getPosition(), Vector3(0, 0-rot.y, 0), "Linear")
            self.m_Closed = false

            self.m_Timer = setTimer(bind(self.Event_onColShapeHit, self, player, true), 10000, 1)
            --outputDebug("Opening: "..(0-rot.y).." ["..rot.y.."; 0]")
        else
            local rot = self.m_Barrier:getRotation()
            self.m_Barrier:move(1250, self.m_Barrier:getPosition(), Vector3(0, -rot.y+90, 0), "InQuad")
            self.m_Closed = true
            --outputDebug("Closing: "..(-rot.y+90).." ["..rot.y.."; 90]")
         end
     end
end
