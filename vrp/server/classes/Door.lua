Door = inherit(Object)

function Door:constructor(model, pos, rot, customOffset)
  self.m_Closed = rot.z
  self.m_Door = createObject(model, pos, rot)
  self.m_Door:setFrozen(true)
  local x, y = getPointFromDistanceRotation(pos.x, pos.y, 4, -rot.z+180)
  self.m_ColShape1 = ColShape.Sphere(Vector3(x, y, pos.z - 1.75) + self.m_Door.matrix.forward*(customOffset and -customOffset or -1.5), 1)
  local x, y = getPointFromDistanceRotation(pos.x, pos.y, 4, rot.z)
  self.m_ColShape2 = ColShape.Sphere(Vector3(x, y, pos.z - 1.75) + self.m_Door.matrix.forward*(customOffset or 1.5), 1)
  addEventHandler("onColShapeHit", self.m_ColShape1, bind(self.Event_onColShapeHit, self))
  addEventHandler("onColShapeHit", self.m_ColShape2, bind(self.Event_onColShapeHit, self))
end

function Door:Event_onColShapeHit(hitEle, matchingDimension)
    if hitEle:getType() == "player" and matchingDimension then
        local player = hitEle
        if player:isInVehicle() and player:getOccupiedVehicleSeat() ~= 0 then
            return
        end
        if self.m_Timer and isTimer(self.m_Timer) then
            killTimer(self.m_Timer)
        end
        if self.onDoorHit and self.onDoorHit(player) == false then
            return
        end
        if self.m_Closed then
            local rot = self.m_Door:getRotation()
            self.m_Door:setFrozen(false)
            self.m_Door:move(1250, self.m_Door:getPosition(), Vector3(0, 0, 0-rot.z), "InQuad")
            setTimer(function(door)
                door:setFrozen(true)
            end,1250,1,self.m_Door)

            self.m_Closed = false

            self.m_Timer = setTimer(bind(self.Event_onColShapeHit, self, player, true), 10000, 1)
            --outputDebug("Opening: "..(0-rot.y).." ["..rot.y.."; 0]")
        else
            local rot = self.m_Door:getRotation()
            self.m_Door:setFrozen(false)
            self.m_Door:move(1250, self.m_Door:getPosition(), Vector3(0, 0, 0,-rot.z+90), "InQuad")
            setTimer(function(door)
                door:setFrozen(true)
            end,1250,1,self.m_Door)
            self.m_Closed = true
            --outputDebug("Closing: "..(-rot.y+90).." ["..rot.y.."; 90]")
         end
     end
end

function Door:setDoorScale(scale)
    self.m_Door:setScale(scale)
end
