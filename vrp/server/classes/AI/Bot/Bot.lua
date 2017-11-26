Bot = inherit(Object)

Bot.Animations = {
	["Punch"] = {block = "fight_b", anim = "fightb_1"},
	["Walk"] = {block = "ped", anim = "walk_player"},
	["Run"] = {block = "ped", anim = "run_player"},
	["Damage"] = {block = "fight_b", anim = "hitb_1"}
}

function Bot:new(npcSettings)
	outputChatBox("new")
	local ped = Ped.create(npcSettings.skinID, npcSettings.pos, npcSettings.rot.z, true)
	enew(ped, self, npcSettings)
	return ped
end

function Bot:constructor(npcSettings)
	outputChatBox("con")
	self.m_Id = npcSettings.id
	self.m_Position = npcSettings.pos
	self.m_Rotation = npcSettings.rot


	self.m_MaxLife = npcSettings.life
	self.m_CurrentLife = npcSettings.life

	self.m_Name = npcSettings.name

	self.skinID = npcSettings.skinID
	self.m_Dimension = 0

	self.m_MinDistance = 0
	self.m_Distance = 0
	self.m_Tolerance = 3.0

	self.m_State = "idle"

	self.m_ActionRadius = 20
	self.m_FollowTarget = nil

	self.m_isAlive = true

	self:init()

	outputDebugString("Bot " .. self.m_Id .. " was loaded.")
end


function Bot:init()
	self.m_ActionCol = createColSphere (self.m_Position, self.m_ActionRadius)

	if (self) and (self.m_ActionCol) then
		self.m_OnColShapeHit = bind(self.onColShapeHit, self)
		self.m_OnColShapeLeave = bind(self.onColShapeLeave, self)

		addEventHandler("onColShapeHit", self.m_ActionCol, self.m_OnColShapeHit)
		addEventHandler("onColShapeLeave", self.m_ActionCol, self.m_OnColShapeLeave)

		self:setDimension(self.m_Dimension)
		self.m_ActionCol:setDimension(self.m_Dimension)

		self.m_ActionCol:attach(self)

		self.m_OnPedWasted = bind(self.onPedWasted, self)
		addEvent("onPedWasted", true)
		addEventHandler("onPedWasted", self, self.m_OnPedWasted)

		self.m_MaxLife = self.m_MaxLife
		self.m_CurrentLife = self.m_MaxLife
	end
end

function Bot:update()
	if (self) and (isElement(self)) then
		if (self.m_isAlive == true) then
			self:updateCoords()
			self:updatePosition()

			if self.m_TargetPos then
				self.m_Distance = getDistanceBetweenPoints2D(self.m_Position.x, self.m_Position.y, self.m_TargetPos.x, self.m_TargetPos.y)
			end

			if (self.m_State == "runToFollowTarget") then
				self:correctPosition()
			elseif (self.m_State == "idle") then
				if (self.m_FollowTarget) then
					self:updateFollowTargetValues()
				end
			end

			if (self.m_CurrentLife <= 0) then
				self:kill()
			end
		end
	end
end


function Bot:updateCoords()
	self.m_CurrentPos = self:getPosition()

	if (self.m_CurrentPos) then
		self.m_Position = self.m_CurrentPos
	end

	self.m_CurrentRot = self:getRotation()

	if (self.m_CurrentRot) then
		self.m_Rotation = self.m_CurrentRot
	end
end

function Bot:updatePosition()
	if self.m_TargetPos then
		if (self.m_Distance <= self.m_Tolerance) then
			self:jobIdle()
		else
			local speed = self.m_Distance > 4 and 2 or 1
			self:jobRunToFollowTarget(speed)
		end
	end
end


function Bot:updateFollowTargetValues()
	if (self.m_FollowTarget) and (isElement(self.m_FollowTarget)) then
		local FollowTargetPos = self.m_FollowTarget:getPosition()

		if (FollowTargetPos) then
			self.m_TargetPos = FollowTargetPos
		end

		local rotZ = findRotation(self.m_Position.x, self.m_Position.y, self.m_TargetPos.x, self.m_TargetPos.y)
		self:setRotation(self.m_Rotation.x, self.m_Rotation.y, rotZ, "default", true)
	end
end


function Bot:correctPosition()
	if (self) and (isElement(self)) then
		if (self.m_Distance <= self.m_MinDistance) then
			self.m_MinDistance = self.m_Distance
		else
			local rotZ = findRotation(self.m_Position.x, self.m_Position.y, self.m_TargetPos.x, self.m_TargetPos.y)
			self:setRotation(self.m_Rotation.x, self.m_Rotation.x, rotZ, "default", true)
		end
	end
end


function Bot:setTargetPosition()
	if (self.m_FollowTarget) and (isElement(self.m_FollowTarget)) then

		local FollowTargetPos = self.m_FollowTarget:getPosition()

		if (FollowTargetPos) then
			self.m_TargetPos = FollowTargetPos

			local rotZ = findRotation(self.m_Position.x, self.m_Position.y, self.m_TargetPos.x, self.m_TargetPos.y)
			self:setRotation(self.m_Rotation.x, self.m_Rotation.y, rotZ, "default", true)

			self.m_Distance = getDistanceBetweenPoints2D(self.m_Position.x, self.m_Position.y, self.m_TargetPos.x, self.m_TargetPos.y)
			self.m_MinDistance = getDistanceBetweenPoints2D(self.m_Position.x, self.m_Position.y, self.m_TargetPos.x, self.m_TargetPos.y)
			local speed = self.m_Distance > 4 and 2 or 1
			self:jobRunToFollowTarget()
		end
	end
end


function Bot:jobIdle()
	if (self.m_State ~= "idle") then
		if (self) and (isElement(self)) then
			self:setAnimation()
			self.m_State = "idle"
		end
	end
end


function Bot:jobRunToFollowTarget(speed)
	if (self.m_State ~= "runToFollowTarget") then
		if (self) and (isElement(self)) then
			local anim = speed == 1 and "Walk" or "Run"
			self:setAnimation(Bot.Animations[anim].block, Bot.Animations[anim].anim, -1, true, true, true, false, 250)
			self.m_State = "runToFollowTarget"
		end
	end
end


function Bot:onColShapeHit(element, dimension)
	if (isElement(element)) and (not self.m_FollowTarget) then
		if (element:getType() == "player") then
			self.m_FollowTarget = element
			self:setTargetPosition()
		end
	end
end


function Bot:onColShapeLeave(element, dimension)
	if (isElement(element)) and (self.m_FollowTarget) then
		if (element:getType() == "player") then
			if (self.m_FollowTarget == element) then
				self.m_FollowTarget = nil
			end
		end
	end
end


function Bot:onPedWasted()
	if (self.m_isAlive == true) then
		self.m_isAlive = false
	end
end


function Bot:changeLife(value)
	if (value) then
		self.m_CurrentLife = self.m_CurrentLife + value

		if (self.m_CurrentLife > self.m_MaxLife) then
			self.m_CurrentLife = self.m_MaxLife
		end

		if (self.m_CurrentLife < 0) then
			self.m_CurrentLife = 0
		end
	end
end


function Bot:setLife(value)
	if (value) then
		self.m_CurrentLife = value

		if (self.m_CurrentLife > self.m_MaxLife) then
			self.m_CurrentLife = self.m_MaxLife
		end

		if (self.m_CurrentLife < 0) then
			self.m_CurrentLife = 0
		end
	end
end


function Bot:getLife()
	return self.m_CurrentLife
end

function Bot:isPedAlive()
	return self.m_isAlive
end

function Bot:clear()
	self:jobIdle()

	if (self.m_ActionCol) then
		removeEventHandler("onColShapeHit", self.m_ActionCol, self.m_OnColShapeHit)
		removeEventHandler("onColShapeLeave", self.m_ActionCol, self.m_OnColShapeLeave)

		self.m_ActionCol:destroy()
		self.m_ActionCol = nil
	end

	if (self) then
		removeEventHandler("onPedWasted", self, self.m_OnPedWasted)
	end
end


function Bot:destructor()
	self:clear()

	outputDebugString("Bot " .. self.m_Id .. " was deleted.")
end
