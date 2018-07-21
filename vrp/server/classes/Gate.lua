Gate = inherit(Object)
Gate.Map = {}
function Gate:constructor(model, pos, rot, openPos, openRot, playSound, interior , dimension)
    self.m_Gates = {}
	self.m_Closed = true
	self:addGate(model, pos, rot, openPos, openRot, playSound, interior, dimension)
end

function Gate:addGate(model, pos, rot, openPos, openRot, playSound, interior, dimension, scale)
	local id = #self.m_Gates+1
    self.m_Gates[id] = createObject(model, pos, rot)
    setObjectScale(self.m_Gates[id], scale or 1)
	self.m_Gates[id].openPos = openPos
	self.m_Gates[id].closedPos = pos
	self.m_Gates[id].openRot = openRot or rot
	self.m_Gates[id].closedRot = rot
	self.m_Gates[id].playSound = (playSound == nil and true or playSound) --default true
	self.m_Gates[id].m_Super = self
    self.m_Gates[id].m_Id = id
    self.m_Gates[id]:setInterior(interior or 0)
    self.m_Gates[id]:setDimension(dimension or 0)
    Gate.Map[#Gate.Map+1] = self.m_Gates[id]
end

function Gate:triggerMovement(hitEle)
    local function rotationDifference(isRotation, targetRotation)
        if math.round(isRotation) == math.round(targetRotation) then return 0 end
        local diff = ((targetRotation - isRotation) + 180) % 360 - 180
        --outputDebug(isRotation, targetRotation, diff, "----", math.round(isRotation), math.round(targetRotation))
        if math.abs(math.round(diff)) == 180 then return 0 end
        return diff
    end
    if not hitEle or not isElement(hitEle) then return false end
    if hitEle:getType() == "player" then
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
                gate:stop()
                local targetRot = Vector3(
                    rotationDifference(gate.rotation.x, gate.openRot.x),
                    rotationDifference(gate.rotation.y, gate.openRot.y),
                    rotationDifference(gate.rotation.z, gate.openRot.z)
                )
                gate:move((gate.position - gate.openPos).length * 800 + targetRot.length * 50, gate.openPos, targetRot, "InOutQuad")
                if gate.playSound then triggerClientEvent("itemRadioChangeURLClient", gate, "files/audio/gate_open.mp3") end
			end

			self.m_Closed = false
            self.m_Timer = setTimer(bind(self.triggerMovement, self, player, true), 22000, 1)
        else
           for index, gate in pairs(self.m_Gates) do
                gate:stop()
                local targetRot = Vector3(
                    rotationDifference(gate.rotation.x, gate.closedRot.x),
                    rotationDifference(gate.rotation.y, gate.closedRot.y),
                    rotationDifference(gate.rotation.z, gate.closedRot.z) 
                )
				gate:move((gate.position - gate.closedPos).length * 800 + targetRot.length * 50, gate.closedPos, targetRot, "InOutQuad")
				if gate.playSound then triggerClientEvent("itemRadioChangeURLClient", gate, "files/audio/gate_open.mp3") end
			end

            self.m_Closed = true
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
