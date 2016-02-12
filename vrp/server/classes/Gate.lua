Gate = inherit(Object)

function Gate:constructor(model, pos, rot, openPos, customOffset)
  self.m_ClosedPos = pos
  self.m_OpenPos = openPos
  self.m_Gate = createObject(model, pos, rot)
  local x, y = getPointFromDistanceRotation(pos.x, pos.y, 4, 90+(90-rot.z))
  self.m_ColShape1 = ColShape.Sphere(Vector3(x, y, pos.z) + self.m_Gate.matrix.forward*(customOffset and -customOffset or 2.5), 5)
  local x, y = getPointFromDistanceRotation(pos.x, pos.y, 4, (90-rot.z)-75)
  self.m_ColShape2 = ColShape.Sphere(Vector3(x, y, pos.z) + self.m_Gate.matrix.forward*(customOffset or 2.5), 5)
  addEventHandler("onColShapeHit", self.m_ColShape1, bind(self.Event_onColShapeHit, self))
  addEventHandler("onColShapeHit", self.m_ColShape2, bind(self.Event_onColShapeHit, self))
end

function Gate:Event_onColShapeHit(hitEle, matchingDimension)
    if hitEle:getType() == "player" and matchingDimension then
        local player = hitEle
        if player:isInVehicle() and player:getOccupiedVehicleSeat() ~= 0 then
            return
        end
        if self.m_Timer and isTimer(self.m_Timer) then
            killTimer(self.m_Timer)
        end
        if self.onGateHit and self.onGateHit(player) == false then
            return
        end
        if self.m_Closed then
            self.m_Gate:move(1250, self.m_OpenPos)
            self.m_Closed = false

            self.m_Timer = setTimer(bind(self.Event_onColShapeHit, self, player, true), 10000, 1)
            --outputDebug("Opening: "..(0-rot.y).." ["..rot.y.."; 0]")
        else
            self.m_Gate:move(1250, self.m_ClosedPos)
            self.m_Closed = true
            --outputDebug("Closing: "..(-rot.y+90).." ["..rot.y.."; 90]")
         end
     end
end
