MStealWeaponTruck = inherit(Singleton)
local TIME_UNTIL_CLOSE = 120*1000
--local TIME_BETWEEN_ACTION = 1*60*60*1000
local TIME_BETWEEN_ACTION = 20*1000

function MStealWeaponTruck:constructor()
  self.m_Gate1 = createObject(975, Vector3(2720.5, -2405.5, 13.60))
  self.m_Gate1:setRotation(0, 0, 90)
  self.m_Gate2 = createObject(975, Vector3(2720.5, -2503.9, 13.60))
  self.m_Gate2:setRotation(0, 0, 90)
  self.m_GateState = {true, true}

  self:respawnGuardPed1()
  self:respawnGuardPed2()

  self.m_CanBeStarted = true
  self.m_ResetInProgress = false

  self.m_Area = ColShape.Cuboid(Vector3(2685.642, -2513.948, 12.142), 120, 130, 15)
  addEventHandler("onColShapeLeave", self.m_Area,
  function(ele, matchingDimension)
    if not matchingDimension then return end
    if ele:getType() ~= "player" then return end
    ele:triggerEvent("bankRobberyCountdownStop")
  end)
end

function MStealWeaponTruck:destructor()

end

function MStealWeaponTruck:reset()
  self:respawnGuardPed1()
  self:respawnGuardPed2()
end

function MStealWeaponTruck:delayedClose(delay)
  if self.m_ResetInProgress then return end
  self.m_CloseInProgress = true
  setTimer(bind(self.close, self), delay, 1)

  for i, v in pairs(self.m_Area:getElementsWithin()) do
    if v:getType() == "player" then
      v:triggerEvent("bankRobberyCountdown", delay/1000)
    end
  end
end

function MStealWeaponTruck:close()
  self.m_CloseInProgress = false

  if self.m_GateState[1] == false then
    self:toggleGate1()
  end
  if self.m_GateState[2] == false then
    self:toggleGate2()
  end
  if isElement(self.m_GuardPed1) then
		self.m_GuardPed1:destroy()
	end
  if isElement(self.m_GuardPed2) then
		self.m_GuardPed2:destroy()
	end

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

function MStealWeaponTruck:GuardPed1_Wasted(totalAmmo, killer)
  -- Report the kill crime, but do not report jailbreak yet
  killer:reportCrime(Crime.Kill)

	self:toggleGate1()
  self:delayedClose(TIME_UNTIL_CLOSE)
  self.m_CanBeStarted = false
end

function MStealWeaponTruck:GuardPed2_Wasted(totalAmmo, killer)
  -- Report the kill crime, but do not report jailbreak yet
  killer:reportCrime(Crime.Kill)

	self:toggleGate2()
  self:delayedClose(TIME_UNTIL_CLOSE)
  self.m_CanBeStarted = false
end

function MStealWeaponTruck:checkRequirements(player)
  if self.m_CanBeStarted then
    if player:getFaction() and player:getFaction():isEvil() then
      return true
    end
  end
  return false
end
