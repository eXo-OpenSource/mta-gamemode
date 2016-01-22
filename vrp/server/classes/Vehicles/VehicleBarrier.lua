VehicleBarrier = inherit(Object)

function VehicleBarrier:constructor(pos, rot, func)
  self.m_Closed = rot.y == 90
  self.m_Barrier = createObject(968, pos, rot)
  local x, y = getPointFromDistanceRotation(pos.x, pos.y, 5, 45+(90-rot.z))
  self.m_ColShape1 = ColShape.Sphere(Vector3(x, y, pos.z) + self.m_Barrier.matrix.forward*-2.5, 2)
  local x, y = getPointFromDistanceRotation(pos.x, pos.y, 5, (90-rot.z)-45)
  self.m_ColShape2 = ColShape.Sphere(Vector3(x, y, pos.z) + self.m_Barrier.matrix.forward*2.5, 2)
  self.checkPermissions = func
  addEventHandler("onColShapeHit", self.m_ColShape1, bind(self.Event_onColShapeHit, self))
  addEventHandler("onColShapeHit", self.m_ColShape2, bind(self.Event_onColShapeHit, self))
end

function VehicleBarrier:Event_onColShapeHit(hitEle, matchingDimension)
  if hitEle:getType() == "player" and matchingDimension then
    local player = hitEle
    if self.checkPermissions(player) == true then
      if self.m_Closed then
        local rot = self.m_Barrier:getRotation()
        self.m_Barrier:move(1250, self.m_Barrier:getPosition(), Vector3(0, 0-rot.y, 0), "Linear")
        self.m_Closed = false

        --outputDebug("Opening: "..(0-rot.y).." ["..rot.y.."; 0]")
      else
        local rot = self.m_Barrier:getRotation()
        self.m_Barrier:move(1250, self.m_Barrier:getPosition(), Vector3(0, -rot.y+90, 0), "Linear")
        self.m_Closed = true

        --outputDebug("Closing: "..(-rot.y+90).." ["..rot.y.."; 90]")
      end
    end
  end
end
