MStealWeaponTruck = inherit(Singleton)
local TIME_UNTIL_CLOSE = 30*1000
--local TIME_BETWEEN_ACTION = 1*60*60*1000
local TIME_BETWEEN_ACTION = 20*1000

function MStealWeaponTruck:constructor()
  self.m_Gate1 = createObject(975, Vector3(2720.5, -2405.5, 13.60))
  self.m_Gate1:setRotation(0, 0, 90)
  self.m_Gate2 = createObject(975, Vector3(2720.5, -2503.9, 13.60))
  self.m_Gate2:setRotation(0, 0, 90)
  self.m_Gate3 = createObject(980, Vector3(2774.4, -2455.7, 14.4))
  self.m_Gate3:setRotation(0, 0, 90)
  self.m_GateState = {true, true, true}

  self:respawnGuardPed1()
  self:respawnGuardPed2()

  self.m_CloseStarted = false

  self.m_Area = ColShape.Cuboid(Vector3(2685.642, -2513.948, 12.142), 120, 130, 15)
  addEventHandler("onColShapeHit", self.m_Area, bind(self.onZoneHit, self))
  addEventHandler("onColShapeLeave", self.m_Area, bind(self.onZoneLeft, self))

  self.m_Truck = false
  self.m_Trailer = false
end

function MStealWeaponTruck:destructor()

end

function MStealWeaponTruck:onZoneHit(ele, matchingDimension)
    if not matchingDimension then return end
    if ele:getType() == "player" then
        if self.m_CloseStarted then
            ele:triggerEvent("Countdown", math.floor((TIME_UNTIL_CLOSE-(getTickCount()-self.m_CloseStarted))/1000), "Truck Diebstahl")
        end
    end
end

function MStealWeaponTruck:onZoneLeft(ele, matchingDimension)
    if not matchingDimension then return end
    if ele:getType() == "player" then
        ele:triggerEvent("CountdownStop", "Truck Diebstahl")

        local Truck = ele:getOccupiedVehicle()
        if Truck then
            if Truck == self.m_Truck then
                WeaponTruck:new(self.m_Truck, ele)

                self.m_Truck = false
                self.m_Trailer = false
            end
        end
    end
end

function MStealWeaponTruck:reset()
  self:respawnGuardPed1()
  self:respawnGuardPed2()
end

function MStealWeaponTruck:delayedClose()
  if self.m_CloseStarted then return end
  self.m_CloseStarted = getTickCount()
  setTimer(bind(self.close, self), TIME_UNTIL_CLOSE, 1)

  for i, v in pairs(self.m_Area:getElementsWithin()) do
    if v:getType() == "player" then
      v:triggerEvent("Countdown", TIME_UNTIL_CLOSE/1000)
    end
  end

  -- Spawn Guard Peds
  self:respawnGuardPed3()
  self:respawnGuardPed4()

  -- Create the Truck
  self:createTruck()
end

function MStealWeaponTruck:close()
  self.m_CloseStarted = false

  if self.m_GateState[1] == false then
    self:toggleGate1()
  end
  if self.m_GateState[2] == false then
    self:toggleGate2()
  end
  if self.m_GateState[3] == false then
    self:toggleGate3()
  end
  if isElement(self.m_GuardPed1) then
		self.m_GuardPed1:destroy()
  end
  if isElement(self.m_GuardPed2) then
		self.m_GuardPed2:destroy()
  end
  if isElement(self.m_GuardPed3) then
      self.m_GuardPed3:destroy()
  end
  if isElement(self.m_GuardPed4) then
      self.m_GuardPed4:destroy()
  end

  -- Destroy the Truck
  self:destroyTruck()

  -- Reset it in an hour
  setTimer(bind(self.reset, self), TIME_BETWEEN_ACTION, 1)
end

function MStealWeaponTruck:toggleGate1()
  if self.m_GateState[1] == true then
    self.m_Gate1:move(2000, self.m_Gate1:getPosition() + self.m_Gate1.matrix.right*9)
    self.m_GateState[1] = false
  else
    self.m_Gate1:move(2000, self.m_Gate1:getPosition() + self.m_Gate1.matrix.right*-9)
    self.m_GateState[1] = true
  end
end

function MStealWeaponTruck:toggleGate2()
  if self.m_GateState[2] == true then
    self.m_Gate2:move(2000, self.m_Gate2:getPosition() + self.m_Gate2.matrix.right*9)
    self.m_GateState[2] = false
  else
    self.m_Gate2:move(2000, self.m_Gate2:getPosition() + self.m_Gate2.matrix.right*-9)
    self.m_GateState[2] = true
  end
end

function MStealWeaponTruck:toggleGate3()
  if self.m_GateState[3] == true then
    self.m_Gate3:move(2000, self.m_Gate3:getPosition() + self.m_Gate3.matrix.up*-4.5)
    self.m_GateState[3] = false
  else
    self.m_Gate3:move(2000, self.m_Gate3:getPosition() + self.m_Gate3.matrix.up*4.5)
    self.m_GateState[3] = true
  end
end

function MStealWeaponTruck:respawnGuardPed1()
	if isElement(self.m_GuardPed1) then
		self.m_GuardPed1:destroy()
	end
	self.m_GuardPed1 = GuardActor:new(Vector3(2719.264, -2405.328, 13.467))
	self.m_GuardPed1:setRotation(0, 0, 90)
	self.m_GuardPed1:setFrozen(true)
	addEventHandler("onPedWasted", self.m_GuardPed1, bind(self.GuardPed1_Wasted, self))
end

function MStealWeaponTruck:respawnGuardPed2()
	if isElement(self.m_GuardPed2) then
		self.m_GuardPed2:destroy()
	end
	self.m_GuardPed2 = GuardActor:new(Vector3(2719.264, -2503.763, 13.467))
	self.m_GuardPed2:setRotation(0, 0, 90)
	self.m_GuardPed2:setFrozen(true)
	addEventHandler("onPedWasted", self.m_GuardPed2, bind(self.GuardPed2_Wasted, self))
end

function MStealWeaponTruck:respawnGuardPed3()
	if isElement(self.m_GuardPed3) then
		self.m_GuardPed3:destroy()
	end
	self.m_GuardPed3 = GuardActor:new(Vector3(2773.834, -2461.304, 13.637))
	self.m_GuardPed3:setRotation(0, 0, 90)
	self.m_GuardPed3:setFrozen(true)
	addEventHandler("onPedWasted", self.m_GuardPed3, bind(self.GuardPed3_Wasted, self))
end

function MStealWeaponTruck:respawnGuardPed4()
	if isElement(self.m_GuardPed4) then
		self.m_GuardPed4:destroy()
	end
	self.m_GuardPed4 = GuardActor:new(Vector3(2773.835, -2450.368, 13.637))
	self.m_GuardPed4:setRotation(0, 0, 90)
	self.m_GuardPed4:setFrozen(true)
	addEventHandler("onPedWasted", self.m_GuardPed4, bind(self.GuardPed4_Wasted, self))
end

function MStealWeaponTruck:GuardPed1_Wasted(totalAmmo, killer)
  -- Report the kill crime, but do not report jailbreak yet
  killer:reportCrime(Crime.Kill)

  self:toggleGate1()
  self:delayedClose()
end

function MStealWeaponTruck:GuardPed2_Wasted(totalAmmo, killer)
  -- Report the kill crime, but do not report jailbreak yet
  killer:reportCrime(Crime.Kill)

  self:toggleGate2()
  self:delayedClose()
end

function MStealWeaponTruck:GuardPed3_Wasted(totalAmmo, killer)
  -- Report the kill crime, but do not report jailbreak yet
  killer:reportCrime(Crime.Kill)

  self.m_Truck:setLocked(false)
end

function MStealWeaponTruck:GuardPed4_Wasted(totalAmmo, killer)
  -- Report the kill crime, but do not report jailbreak yet
  killer:reportCrime(Crime.Kill)

  self:toggleGate3()
end

function MStealWeaponTruck:createTruck()
    if self.m_Truck then return false end

    self.m_Truck = TemporaryVehicle.create(515, 2784.753, -2456.110, 14.651, 90)
    self.m_Truck:setData("WeaponTruck", true)
    self.m_Truck:setColor(0, 0, 0)
    self.m_Truck:setLocked(true)
    self.m_Trailer = TemporaryVehicle.create(435, 2794.614, -2456.069, 13.632 , 90)
    self.m_Trailer:setData("WeaponTruck", true)
    self.m_Trailer:setVariant(1, 1)
    self.m_Trailer:setParent(self.m_Truck)
    attachTrailerToVehicle(self.m_Truck, self.m_Trailer)
end

function MStealWeaponTruck:destroyTruck()
    if not self.m_Truck then return false end
    destroyElement(self.m_Truck) -- Trailer gets automatically destroyed!
    self.m_Truck = false
    self.m_Trailer = false
end

function MStealWeaponTruck:checkRequirements(player)
  if self.m_CanBeStarted then
    if player:getFaction() and player:getFaction():isEvil() then
      return true
    end
  end
  return false
end
