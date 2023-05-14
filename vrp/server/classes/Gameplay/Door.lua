-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Door.lua
-- *  PURPOSE:     Door class
-- *
-- ****************************************************************************
Door = inherit(Object)
Door.Map = {}
function Door:constructor(model, pos, rot, customOffset)
  self.m_Closed = rot.z
  self.m_Doors = {}
  self.m_Door = createObject(model, pos, rot)
  self.m_Door:setFrozen(true)
  self.m_ColShape1 = ColShape.Sphere(self.m_Door.matrix:transformPosition(Vector3(Vector3(2, -0.5, 1))), 1)
  self.m_ColShape2 = ColShape.Sphere(self.m_Door.matrix:transformPosition(Vector3(Vector3(-2, -0.5, 1))), 1)
  addEventHandler("onColShapeHit", self.m_ColShape1, bind(self.Event_onColShapeHit, self))
  addEventHandler("onColShapeHit", self.m_ColShape2, bind(self.Event_onColShapeHit, self))
end


function Door:addDoor(model, pos, rot, customOffset, interior, dimension, scale) 
	local id = #self.m_Doors+1
    self.m_Doors[id] = createObject(model, pos, rot)
    setObjectScale(self.m_Doors[id], scale or 1)
    self.m_Doors[id].m_Closed = rot.z
    self.m_Doors[id]:setFrozen(true)
	self.m_Doors[id].m_Super = self
    self.m_Doors[id].m_Id = id
    self.m_Doors[id]:setInterior(interior or 0 )
    self.m_Doors[id]:setDimension(dimension or 0)
    Door.Map[#Door.Map+1] = self.m_Doors[id]
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
		if self.m_Moving then return end
        if self.m_Closed then
			local rot = self.m_Door:getRotation()
            self.m_Door:setFrozen(false)
            self.m_Door:move(2000, self.m_Door:getPosition(), Vector3(0, 0, -90), "InQuad")
            self.m_Moving = true
            for index, door in pairs(self.m_Doors) do
                door:move(2000, self.m_Door:getPosition(), Vector3(0, 0, -90), "InQuad")
			end
            setTimer(function(door)
                door:setFrozen(true)
				self.m_Closed = false
				self.m_Moving = false
            end,2000,1,self.m_Door)
            


            self.m_Timer = setTimer(bind(self.Event_onColShapeHit, self, player, true), 6000, 1)
            --outputDebug("Opening: "..(0-rot.y).." ["..rot.y.."; 0]")
        else
            local rot = self.m_Door:getRotation()
            self.m_Door:setFrozen(false)
			self.m_Moving = true
            self.m_Door:move(2000, self.m_Door:getPosition(), Vector3(0, 0, 90), "InQuad")
            for index, door in pairs(self.m_Doors) do
                door:move(2000, self.m_Door:getPosition(), Vector3(0, 0, 90), "InQuad")
			end
            setTimer(function(door)
                door:setFrozen(true)
				self.m_Closed = true
				self.m_Moving = false
            end,2000,1,self.m_Door)

            --outputDebug("Closing: "..(-rot.y+90).." ["..rot.y.."; 90]")
         end
     end
end

function Door:setDoorScale(scale)
    self.m_Door:setScale(scale)
end
