Gate = inherit(Object)
Gate.Map = {}
function Gate:constructor(model, pos, rot, openPos, customOffset)
    self.m_Gates = {}
	self.m_Closed = true

	self:addGate(model, pos, rot, openPos)
    --self:createColshapes(model, pos, rot, customOffset)

    --addEventHandler("onColShapeHit", self.m_ColShape1, bind(self.Event_onColShapeHit, self))
    --addEventHandler("onColShapeHit", self.m_ColShape2, bind(self.Event_onColShapeHit, self))
end

function Gate:addGate(model, pos, rot, openPos)
	local id = #self.m_Gates+1
	self.m_Gates[id] = createObject(model, pos, rot)
	self.m_Gates[id].openPos = openPos
	self.m_Gates[id].closedPos = pos
	self.m_Gates[id].m_Super = self
	self.m_Gates[id].m_Id = id
	Gate.Map[#Gate.Map+1] = self.m_Gates[id]
end

function Gate:createColshapes(model, pos, rot, customOffset)
    local x, y, x1, y1
    if model == 980 then
        x1, y1 = getPointFromDistanceRotation(pos.x, pos.y, 4, -rot.z+180)
        x2, y2 = getPointFromDistanceRotation(pos.x, pos.y, -4, rot.z)
    elseif model == 971 then
        x1, y1 = getPointFromDistanceRotation(pos.x, pos.y, 4, -rot.z+180)
        x2, y2 = getPointFromDistanceRotation(pos.x, pos.y, 4, rot.z)
    elseif model == 9093 then
        x1, y1 = getPointFromDistanceRotation(pos.x, pos.y, 4, -rot.z+80)
        x2, y2 = getPointFromDistanceRotation(pos.x, pos.y, 4, rot.z+60)
	elseif model == 2938 then
		x1, y1 = getPointFromDistanceRotation(pos.x+2, pos.y, 4, rot.z-90)
        x2, y2 = getPointFromDistanceRotation(pos.x-2, pos.y-1, 4, rot.z+90)
	elseif model == 7657 then
		x1, y1 = getPointFromDistanceRotation(pos.x+4, pos.y, 4, rot.z-90)
        x2, y2 = getPointFromDistanceRotation(pos.x-2, pos.y, 4, rot.z+90)
	elseif model == 10558 then
		x1, y1 = getPointFromDistanceRotation(pos.x-4, pos.y+6, 3.5, rot.z)
        x2, y2 = getPointFromDistanceRotation(pos.x-4, pos.y-6, 3.5, rot.z)
    end
   -- self.m_Marker1 = createMarker(Vector3(x1, y1, pos.z - 1.75) + self.m_Gates[1].matrix.forward*(customOffset and -customOffset or -2),"cylinder",1) -- Developement Test
    --self.m_Marker2 = createMarker(Vector3(x2, y2, pos.z - 1.75) + self.m_Gates[1].matrix.forward*(customOffset or 2),"cylinder",1,255) -- Developement Test
    self.m_ColShape1 = ColShape.Sphere(Vector3(x1, y1, pos.z - 1.75) + self.m_Gates[1].matrix.forward*(customOffset and -customOffset or -2), 5)
    self.m_ColShape2 = ColShape.Sphere(Vector3(x2, y2, pos.z - 1.75) + self.m_Gates[1].matrix.forward*(customOffset or 2), 5)
end

function Gate:addCustomShapes(pos1, pos2)
	--self.m_ColShape1:setPosition(pos1)
	--self.m_Marker1:setPosition(pos1)
	--self.m_ColShape2:setPosition(pos2)
	--self.m_Marker2:setPosition(pos2)
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
        if self.onGateHit and self.onGateHit(player, self) == false then
            return
        end
        if self.m_Closed then
            for index, gate in pairs(self.m_Gates) do
				gate:move((gate.position - gate.openPos).length * 800, gate.openPos, 0, 0, 0, "InOutQuad")
				triggerClientEvent("itemRadioChangeURLClient", gate, "files/audio/gate_open.mp3")
			end

			self.m_Closed = false
            self.m_Timer = setTimer(bind(self.Event_onColShapeHit, self, player, true), 22000, 1)
            --outputDebug("Opening: "..(0-rot.y).." ["..rot.y.."; 0]")
        else
           for index, gate in pairs(self.m_Gates) do
				gate:move((gate.position - gate.closedPos).length * 800, gate.closedPos, 0, 0, 0, "InOutQuad")
				triggerClientEvent("itemRadioChangeURLClient", gate, "files/audio/gate_open.mp3")
			end

            self.m_Closed = true
            --outputDebug("Closing: "..(-rot.y+90).." ["..rot.y.."; 90]")
         end
     end
end

function Gate:getGateObjects()
    return self.m_Gates
end

function Gate:setGateScale(scale)
     for index, gate in pairs(self.m_Gates) do
		gate:setScale(scale)
	end
end

function Gate:setOwner(owner)
     self.m_Owner = owner
end

function Gate:getOwner()
     return self.m_Owner or false
end
