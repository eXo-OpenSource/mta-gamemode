-- Copyright (c) 2008, Alberto Alonso
--
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without modification,
-- are permitted provided that the following conditions are met:
--
--     * Redistributions of source code must retain the above copyright notice, this
--       list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright notice, this
--       list of conditions and the following disclaimer in the documentation and/or other
--       materials provided with the distribution.
--     * Neither the name of the superman script nor the names of its contributors may be used
--       to endorse or promote products derived from this software without specific prior
--       written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
-- LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
-- A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
-- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
-- EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
-- PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
-- LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
-- NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- Settings

local ZERO_TOLERANCE = 0.00001
local MAX_ANGLE_SPEED = 6
local MAX_SPEED = 1.0
local EXTRA_SPEED_FACTOR = 1.95
local LOW_SPEED_FACTOR = 0.40
local ACCELERATION = 0.025
local EXTRA_ACCELERATION_FACTOR = 2
local LOW_ACCELERATION_FACTOR = 0.85
local TAKEOFF_VELOCITY = 1.75
local TAKEOFF_FLIGHT_DELAY = 750
local SMOKING_SPEED = 1000
local GROUND_ZERO_TOLERANCE = 0.18
local LANDING_DISTANCE = 3.2
local FLIGHT_ANIMLIB = "swim"
local FLIGHT_ANIMATION = "Swim_Dive_Under"
local FLIGHT_ANIM_LOOP = false
local IDLE_ANIMLIB = "cop_ambient"
local IDLE_ANIMATION = "Coplook_loop"
local IDLE_ANIM_LOOP = true
local MAX_Y_ROTATION = 70
local ROTATION_Y_SPEED = 3.8
local thisResource = getThisResource()
local rootElement = getRootElement()
local localPlayer = getLocalPlayer()
local serverGravity = getGravity()
local flyingPlayers = {}

local function isPlayerFlying(player)
  local data = getElementData(player, "superman:flying") and isSupermanEnabled
  if not data or data == false then return false
  else return true end
end

local function setPlayerFlying(player, state)
  if state and isSupermanEnabled then 
	state = true 
  else state = false
  end
  flyingPlayers[player] = (state and true or nil)
  setElementData(player, "superman:flying", state)
end

local function iterateFlyingPlayers()
  local current = 1
  local allPlayers = getElementsByType("player")
  return function()
    local player
    repeat
      player = allPlayers[current]
      current = current + 1
    until not player or (isPlayerFlying(player) and isElementStreamedIn(player))
    return player
  end
end

local function Superman_restorePlayer(player)
  setPlayerFlying(player, false)
  setPedAnimation(player, false)
  setElementVelocity(player, 0, 0, 0)
  setElementRotation(player, 0, 0, 0)
  --setPedRotation(player, getPedRotation(player))
  setElementCollisionsEnabled(player, true)
  rotations[player] = nil
  previousVelocity[player] = nil
end

function angleDiff(angle1, angle2)
  angle1, angle2 = angle1 % 360, angle2 % 360
  local diff = (angle1 - angle2) % 360
  if diff <= 180 then
    return diff
  else
    return -(360 - diff)
  end
end

local function isElementInWater(ped)
  local pedPosition = Vector3D:new(getElementPosition(ped))
  if pedPosition.z <= 0 then return true end

  local waterLevel = getWaterLevel(pedPosition.x, pedPosition.y, pedPosition.z)
  if not isElementStreamedIn(ped) or not waterLevel or waterLevel < pedPosition.z then
    return false
  else
    return true
  end
end

local function isnan(x)
	math.inf = 1/0
	if x == math.inf or x == -math.inf or x ~= x then
		return true
	end
	return false
end

local function getVector2DAngle(vec)
  if vec.x == 0 and vec.y == 0 then return 0 end
  local angle = math.deg(math.atan(vec.x / vec.y)) + 90
  if vec.y < 0 then
    angle = angle + 180
  end
  return angle
end

function Superman_Start()
  addEvent("superman:toggle", true)
  -- Register events
  addEventHandler("onClientResourceStop", getResourceRootElement(thisResource), Superman_Stop, false)
  addEventHandler("onPlayerJoin", rootElement, Superman_onJoin)
  addEventHandler("onPlayerQuit", rootElement, Superman_onQuit)
  addEventHandler("onClientRender", rootElement, Superman_processControls)
  addEventHandler("onClientRender", rootElement, Superman_processFlight)
  addEventHandler("onClientPlayerDamage", localPlayer, Superman_onDamage, false)
  addEventHandler("onClientElementDataChange", rootElement, Superman_onDataChange)
  addEventHandler("onClientElementStreamOut", rootElement, Superman_onStreamOut)
  addEventHandler("superman:toggle", localPlayer, Superman_Toggle)
  bindKey("lctrl","up", Superman_endFlightKey)
  rotations = {}
  previousVelocity = {}
end
addEventHandler("onClientResourceStart", getResourceRootElement(thisResource), Superman_Start, false)

function Superman_endFlightKey() 
	if isSupermanEnabled then 
		setGravity(serverGravity)
		Superman_restorePlayer(localPlayer)
	end
end

function Superman_Toggle( bool ) 
	isSupermanEnabled = bool
	if not bool then 
	   setElementData(localPlayer, "superman:flying", false)
	  setGravity(serverGravity)
	  Superman_restorePlayer(localPlayer)
	end
end

function Superman_Stop()
  setGravity(serverGravity)
  -- Restore all players animations, collisions, etc
  for player in pairs(flyingPlayers) do
    if not isElement(player) or getElementType(player) ~= "player" then
      flyingPlayers[player] = nil
    else
      Superman_restorePlayer(player)
    end
  end
end

function Superman_onJoin(player)
  local self = Superman
  local player = player or source

  setPlayerFlying(player, false)
end

function Superman_onQuit(reason, player)
  local player = player or source

  if isPlayerFlying(player) then
    Superman_restorePlayer(player)
  end
end

function Superman_onDamage()
  if isPlayerFlying(localPlayer) then
    cancelEvent()
  end
end

function Superman_onStreamOut()
  if source and isElement(source) and getElementType(source) == "player" and isPlayerFlying(source) then
    rotations[source] = nil
    previousVelocity[source] = nil
  end
end

-- Used for sync-purposes rather than flying
function Superman_onDataChange(dataName, oldValue)

  if dataName == "superman:flying" then 
	if isElement(source) and getElementType(source) == "player" and oldValue ~= getElementData(source, dataName) and oldValue == true and getElementData(source, dataName) == false then
		Superman_restorePlayer(source)
	end
	if oldValue == false and source == localPlayer and getElementData(source,dataName) then 
		if not isSupermanEnabled then 
			cancelEvent()
		end
	end
  end
end

function Superman_onJump(key, keyState)
  if not isSupermanEnabled then return end 
  local task = getPedSimplestTask(localPlayer)
  if not isPlayerFlying(localPlayer) then
    if task == "TASK_SIMPLE_IN_AIR" then
      setElementVelocity(localPlayer, 0, 0, TAKEOFF_VELOCITY)
      setTimer(Superman_startFlight, 100, 1)
    end
  end
end

function Superman_startFlight()
  if isPlayerFlying(localPlayer) then return end
  triggerServerEvent("superman:start", rootElement)
  setPlayerFlying(localPlayer, true)
  setElementVelocity(localPlayer, 0, 0, 0)
  currentSpeed = 0
  extraVelocity = { x = 0, y = 0, z = 0 }
end

local jump, oldJump = false, false
function Superman_processControls()
  if not isPlayerFlying(localPlayer) then
    jump, oldJump = getPedControlState("jump"), jump
    if isSupermanEnabled and not oldJump and jump then 
      Superman_onJump()
    end
    return
  end

  local Direction = Vector3D:new(0, 0, 0)
  if getPedControlState("forwards") then
    Direction.y = 1
  elseif getPedControlState("backwards") then
    Direction.y = -1
  end

  if getPedControlState("left") then
    Direction.x = 1
  elseif getPedControlState("right") then
    Direction.x = -1
  end
  Direction:Normalize()

  -- Calculate the sight direction
  local cameraX, cameraY, cameraZ, lookX, lookY, lookZ = getCameraMatrix()
  local SightDirection = Vector3D:new((lookX - cameraX), (lookY - cameraY), (lookZ - cameraZ))
  SightDirection:Normalize()
  if getPedControlState("look_behind") then
    SightDirection = SightDirection:Mul(-1)
  end

  -- Calculate the current max speed and acceleration values
  local maxSpeed = MAX_SPEED
  local acceleration = ACCELERATION
  if getPedControlState("sprint") then
    maxSpeed = MAX_SPEED * EXTRA_SPEED_FACTOR
    acceleration = acceleration * EXTRA_ACCELERATION_FACTOR
  elseif getPedControlState("walk") then
    maxSpeed = MAX_SPEED * LOW_SPEED_FACTOR
    acceleration = acceleration * LOW_ACCELERATION_FACTOR
  end

  local DirectionModule = Direction:Module()

  -- Check if we must change the gravity
  if DirectionModule == 0 and currentSpeed ~= 0 then
    setGravity(0)
  else
    setGravity(serverGravity)
  end

  -- Calculate the new current speed
  if currentSpeed ~= 0 and (DirectionModule == 0 or currentSpeed > maxSpeed) then
    -- deccelerate
    currentSpeed = ( currentSpeed or 0 )- acceleration
    if currentSpeed < 0 then currentSpeed = 0 end

  elseif DirectionModule ~= 0 and currentSpeed < maxSpeed then
    -- accelerate
    currentSpeed = currentSpeed + acceleration
    if currentSpeed > maxSpeed then currentSpeed = maxSpeed end

  end

  -- Calculate the movement requested direction
  if DirectionModule ~= 0 then
    Direction = Vector3D:new(SightDirection.x * Direction.y - SightDirection.y * Direction.x,
                             SightDirection.x * Direction.x + SightDirection.y * Direction.y,
                             SightDirection.z * Direction.y)
    -- Save the last movement direction for when player releases all direction keys
    lastDirection = Direction
  else
    -- Player is not specifying any direction, use last known direction or the current velocity
    if lastDirection then
      Direction = lastDirection
      if currentSpeed == 0 then lastDirection = nil end
    else
      Direction = Vector3D:new(getElementVelocity(localPlayer))
    end
  end
  Direction:Normalize()
  Direction = Direction:Mul(currentSpeed)

  -- Applicate a smooth direction change, if moving
  if currentSpeed > 0 then
    local VelocityDirection = Vector3D:new(getElementVelocity(localPlayer))
    VelocityDirection:Normalize()

    if math.sqrt(VelocityDirection.x^2 + VelocityDirection.y^2) > 0 then
      local DirectionAngle = getVector2DAngle(Direction)
      local VelocityAngle = getVector2DAngle(VelocityDirection)

      local diff = angleDiff(DirectionAngle, VelocityAngle)
      local calculatedAngle

      if diff >= 0 then 
        if diff > MAX_ANGLE_SPEED then
          calculatedAngle = VelocityAngle + MAX_ANGLE_SPEED
	else
	  calculatedAngle = DirectionAngle
	end
      else
        if diff < MAX_ANGLE_SPEED then
          calculatedAngle = VelocityAngle - MAX_ANGLE_SPEED
	else
          calculatedAngle = DirectionAngle
        end
      end
      calculatedAngle = calculatedAngle % 360

      local DirectionModule2D = math.sqrt(Direction.x^2 + Direction.y^2)
      Direction.x = -DirectionModule2D*math.cos(math.rad(calculatedAngle))
      Direction.y = DirectionModule2D*math.sin(math.rad(calculatedAngle))
    end
  end

  if Direction:Module() == 0 then
	extraVelocity = { x = 0, y = 0, z = 0 }
  end
  
  -- Set the new velocity
  setElementVelocity(localPlayer, Direction.x + extraVelocity.x,
                                  Direction.y + extraVelocity.y,
								  Direction.z + extraVelocity.z)

  if extraVelocity.z > 0 then
    extraVelocity.z = extraVelocity.z - 1
	if extraVelocity.z < 0 then extraVelocity.z = 0 end
  elseif extraVelocity.z < 0 then
	extraVelocity.z = extraVelocity.z + 1
	if extraVelocity.z > 0 then extraVelocity.z = 0 end
  end
end

function Superman_processFlight()
  for player in pairs(flyingPlayers) do
    if not isElement(player) or getElementType(player) ~= "player" then
      flyingPlayers[player] = nil
    else
      local Velocity = Vector3D:new(getElementVelocity(player))
      local distanceToBase = getElementDistanceFromCentreOfMassToBaseOfModel(player)
      local playerPos = Vector3D:new(getElementPosition(player))
      playerPos.z = playerPos.z - distanceToBase

      local distanceToGround
      if playerPos.z > 0 then
        local hit, hitX, hitY, hitZ, hitElement = processLineOfSight(playerPos.x, playerPos.y, playerPos.z,
                                                                    playerPos.x, playerPos.y, playerPos.z - LANDING_DISTANCE - 1,
                                                                    true, true, true, true, true, false, false, false)
        if hit then distanceToGround = playerPos.z - hitZ end
      end

      if distanceToGround and distanceToGround < GROUND_ZERO_TOLERANCE then
        Superman_restorePlayer(player)
        if player == localPlayer then
          setGravity(serverGravity)
          triggerServerEvent("superman:stop", getRootElement())
        end
      elseif distanceToGround and distanceToGround < LANDING_DISTANCE then
        Superman_processLanding(player, Velocity, distanceToGround)
      elseif Velocity:Module() < ZERO_TOLERANCE then
        Superman_processIdleFlight(player)
      else
        Superman_processMovingFlight(player, Velocity)
      end
    end
  end
end

function Superman_processIdleFlight(player)
  -- Set the proper animation on the player
  local animLib, animName = getPedAnimation(player)
  if animLib ~= IDLE_ANIMLIB or animName ~= IDLE_ANIMATION then
    setPedAnimation(player, IDLE_ANIMLIB, IDLE_ANIMATION, -1, IDLE_ANIM_LOOP, false, false)
  end

  setElementCollisionsEnabled(player, false)

  -- If this is myself, calculate the ped rotation depending on the camera rotation
  if player == localPlayer then
    local cameraX, cameraY, cameraZ, lookX, lookY, lookZ = getCameraMatrix()
    local Sight = Vector3D:new(lookX - cameraX, lookY - cameraY, lookZ - cameraZ)
    Sight:Normalize()
    if getPedControlState("look_behind") then
      Sight = Sight:Mul(-1)
    end

    Sight.z = math.atan(Sight.x / Sight.y)
    if Sight.y > 0 then
      Sight.z = Sight.z + math.pi
    end
    Sight.z = math.deg(Sight.z) + 180

    setPedRotation(localPlayer, Sight.z)
    setElementRotation(localPlayer, 0, 0, Sight.z)
  else
    local Zangle = getPedCameraRotation(player)
    setPedRotation(player, Zangle)
    setElementRotation(player, 0, 0, Zangle)
  end
end

function Superman_processMovingFlight(player, Velocity)
  -- Set the proper animation on the player
  local animLib, animName = getPedAnimation(player)
  if animLib ~= FLIGHT_ANIMLIB or animName ~= FLIGHT_ANIMATION then
    setPedAnimation(player, FLIGHT_ANIMLIB, FLIGHT_ANIMATION, -1, FLIGHT_ANIM_LOOP, true, false)
  end

  if player == localPlayer then
    setElementCollisionsEnabled(player, true)
  else
    setElementCollisionsEnabled(player, false)
  end

  -- Calculate the player rotation depending on their velocity
  local Rotation = Vector3D:new(0, 0, 0)
  if Velocity.x == 0 and Velocity.y == 0 then
    Rotation.z = getPedRotation(player)
  else
    Rotation.z = math.deg(math.atan(Velocity.x / Velocity.y))
    if Velocity.y > 0 then
      Rotation.z = Rotation.z - 180
    end
    Rotation.z = (Rotation.z + 180) % 360
  end
  Rotation.x = -math.deg(Velocity.z / Velocity:Module() * 1.2)

  -- Rotation compensation for the self animation rotation
  Rotation.x = Rotation.x - 40

  -- Calculate the Y rotation for barrel rotations
  if not rotations[player] then rotations[player] = 0 end
  if not previousVelocity[player] then previousVelocity[player] = Vector3D:new(0, 0, 0) end
  
  local previousAngle = getVector2DAngle(previousVelocity[player])
  local currentAngle = getVector2DAngle(Velocity)
  local diff = angleDiff(currentAngle, previousAngle)
  if isnan(diff) then
	diff = 0
  end
  local calculatedYRotation = -diff * MAX_Y_ROTATION / MAX_ANGLE_SPEED

  if calculatedYRotation > rotations[player] then
    if calculatedYRotation - rotations[player] > ROTATION_Y_SPEED then
      rotations[player] = rotations[player] + ROTATION_Y_SPEED
    else
      rotations[player] = calculatedYRotation
    end
  else
    if rotations[player] - calculatedYRotation > ROTATION_Y_SPEED then
      rotations[player] = rotations[player] - ROTATION_Y_SPEED
    else
      rotations[player] = calculatedYRotation
    end
  end

  if rotations[player] > MAX_Y_ROTATION then
    rotations[player] = MAX_Y_ROTATION
  elseif rotations[player] < -MAX_Y_ROTATION then
    rotations[player] = -MAX_Y_ROTATION
  elseif math.abs(rotations[player]) < ZERO_TOLERANCE then
    rotations[player] = 0
  end
  Rotation.y = rotations[player]

  -- Apply the calculated rotation
  setPedRotation(player, Rotation.z)
  setElementRotation(player, Rotation.x, Rotation.y, Rotation.z)

  -- Save the current velocity
  previousVelocity[player] = Velocity

end

function Superman_processLanding(player, Velocity, distanceToGround)
  -- Set the proper animation on the player
  local animLib, animName = getPedAnimation(player)
  if animLib ~= FLIGHT_ANIMLIB or animName ~= FLIGHT_ANIMATION then
    setPedAnimation(player, FLIGHT_ANIMLIB, FLIGHT_ANIMATION, -1, FLIGHT_ANIM_LOOP, true, false)
  end

  if player == localPlayer then
    setElementCollisionsEnabled(player, true)
  else
    setElementCollisionsEnabled(player, false)
  end
  -- Calculate the player rotation depending on their velocity and distance to ground
  local Rotation = Vector3D:new(0, 0, 0)
  if Velocity.x == 0 and Velocity.y == 0 then
    Rotation.z = getPedRotation(player)
  else
    Rotation.z = math.deg(math.atan(Velocity.x / Velocity.y))
    if Velocity.y > 0 then
      Rotation.z = Rotation.z - 180
    end
    Rotation.z = (Rotation.z + 180) % 360
  end
  Rotation.x = -(85 - (distanceToGround * 85 / LANDING_DISTANCE))

  -- Rotation compensation for the self animation rotation
  Rotation.x = Rotation.x - 40

  -- Apply the calculated rotation
  setPedRotation(player, Rotation.z)
  setElementRotation(player, Rotation.x, Rotation.y, Rotation.z)
end

Vector3D = {
  new = function(self, _x, _y, _z)
    local newVector = { x = _x or 0.0, y = _y or 0.0, z = _z or 0.0 }
    return setmetatable(newVector, { __index = Vector3D })
  end,

  Copy = function(self)
    return Vector3D:new(self.x, self.y, self.z)
  end,

  Normalize = function(self)
    local mod = self:Module()
    if mod ~= 0 then
      self.x = self.x / mod
      self.y = self.y / mod
      self.z = self.z / mod
    end
  end,

  Dot = function(self, V)
    return self.x * V.x + self.y * V.y + self.z * V.z
  end,

  Module = function(self)
    return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
  end,

  AddV = function(self, V)
    return Vector3D:new(self.x + V.x, self.y + V.y, self.z + V.z)
  end,

  SubV = function(self, V)
    return Vector3D:new(self.x - V.x, self.y - V.y, self.z - V.z)
  end,

  CrossV = function(self, V)
    return Vector3D:new(self.y * V.z - self.z * V.y,
                        self.z * V.x - self.x * V.z,
                        self.x * V.y - self.y * V.z)
  end,

  Mul = function(self, n)
    return Vector3D:new(self.x * n, self.y * n, self.z * n)
  end,

  Div = function(self, n)
    return Vector3D:new(self.x / n, self.y / n, self.z / n)
  end,

  MulV = function(self, V)
    return Vector3D:new(self.x * V.x, self.y * V.y, self.z * V.z)
  end,

  DivV = function(self, V)
    return Vector3D:new(self.x / V.x, self.y / V.y, self.z / V.z)
  end,
}

