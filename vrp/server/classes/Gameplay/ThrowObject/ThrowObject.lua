-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/ThrowObject.lua
-- *  PURPOSE:     Server ThrowObject Class
-- *
-- ****************************************************************************
ThrowObject = inherit(Object)
ThrowObject.TypeLexicon =
{
	["ped"] = createPed, 
	["vehicle"] = createVehicle, 
	["object"] = createObject, 
}

ThrowObject.DummyType = 
{
	["ped"] = 3092,
	["object"] = 1598, 
	["vehicle"] = 1598,
}

function ThrowObject:constructor(player, model, dummy, offsetMatrix) 
	self.m_Pushed = false
	self.m_Player = player
	self.m_Model = model 
	self.m_Type = self:getTypeFromModel(self:getModel())
	self.m_PhysicModel = dummy or ThrowObject.DummyType[self.m_Type]
	self.m_OffsetMatrix = self:assertTransformMatrix(offsetMatrix)
	if self:initialise() then 
		self:attach()
	end
	player:setThrowingObject(self)
	bindKey(player, "aim_weapon", "both", ThrowObjectManager:getSingleton():getBind())
	ThrowObjectManager:getSingleton():addThrowObjectToPlayer(self:getPlayer(), self)
end

function ThrowObject:destructor()
	if isValidElement(self:getDummyEntity(), "object") then self:getDummyEntity():destroy() end
	if self:getEntity() and isElement(self:getEntity()) and self:getEntity():getType() ~= "player" then 
		self:getEntity():destroy() 
	end
	ThrowObjectManager:getSingleton():removeThrowObjectFromPlayer(self:getPlayer(), self)
end

function ThrowObject:updateCollision(bool)
	self:getPlayer():triggerEvent("Throw:updateCollision", self:getDummyEntity(), bool)
	if self:isDamageDisabled() then 
		for k, player in ipairs(getElementsByType("player")) do 
			player:triggerEvent("Throw:updateCollision", self:getDummyEntity(), bool, true)
		end
	end
end

function ThrowObject:assertTransformMatrix(offsetMatrix) 
	if not offsetMatrix then 
		return {position={x=0,y=0,z=0}, rotation={x=0,y=0,z=0}}
	end
	return offsetMatrix
end

function ThrowObject:attach()
	local offsetMatrix = self:getOffset()
	exports.bone_attach:attachElementToBone(self:getDummyEntity(), self:getPlayer(), 12, 
		offsetMatrix.position.x, 
		offsetMatrix.position.y, 
		offsetMatrix.position.z, 
		offsetMatrix.rotation.x,
		offsetMatrix.rotation.y,
		offsetMatrix.rotation.z)
	
	self:getEntity():attach(self:getDummyEntity())
	self:getEntity():setCollisionsEnabled(false)
end

function ThrowObject:detach() 
	exports.bone_attach:detachElementFromBone(self:getDummyEntity())
end

function ThrowObject:push(pushVector)
	unbindKey(self:getPlayer(), "aim_weapon", "both", ThrowObjectManager:getSingleton():getBind())
	self:detach()
	local skillFactor = (not self:isSkillBased() and 1) or ThrowObjectManager:getSingleton():getSkillFactor(self:getPlayer()) 
	self:getDummyEntity():setVelocity(pushVector * skillFactor)
	self:getDummyEntity():setAngularVelocity(pushVector:getNormalized()*.1)
	setTimer(function() self:getDummyEntity():setAngularVelocity(Vector3(0, 0, 0)) end, 1000, 1) -- stop the movement after one second | todo use calculations to determine a better time
	if isValidElement(self:getEntity(), "player") then 
		setTimer(function()
			StatisticsLogger:getSingleton():addAdminAction(self:getPlayer(), "Spielerwurf", self:getEntity())
			self:getEntity():setCollisionsEnabled(true)
			self:getDummyEntity():setData("Throw:dummyEntity", true, true)
			self:getEntity():setData("Throw:throwEntity", true, true)
			self:getEntity():triggerEvent("Throw:throwPlayer", self:getDummyEntity())
			self:getEntity().m_ThrowInstance = self -- used to detach from dummy when the player was thrown to avoid any desync
		end, 400, 1)
	end
	self:setDespawnTime(getTickCount()+ThrowObjectManager.DESPAWN_TIME)
	if not self:isPersistent() then 
		ThrowObjectManager:getSingleton():addToDespawnList(self)
	end
	self.m_Pushed = true
	if self:getThrowCallback() then
		self:getThrowCallback()(self:getPlayer(), self)
	end
end

function ThrowObject:initialise() 
	self.m_Entity = ThrowObject.TypeLexicon[self:getType()](self:getModel(), self:getPlayer():getPosition())
	self.m_Entity:setDimension(self:getPlayer():getDimension())
	self.m_Entity:setInterior(self:getPlayer():getInterior())
	self.m_Entity:setDoubleSided(true)
	self.m_Entity:setCollisionsEnabled(false)

	self.m_DummyEntity = createObject(self:getPhysicsModel(), self:getPlayer():getPosition())
	self.m_DummyEntity:setDimension(self:getPlayer():getDimension())
	self.m_DummyEntity:setInterior(self:getPlayer():getInterior())
	self.m_DummyEntity:setAlpha(0)
	self.m_DummyEntity:setCollisionsEnabled(false)
	return isValidElement(self.m_Entity, self:getType()) and isValidElement(self.m_Entity, self:getType())
end

function ThrowObject:setPersistent(bool)
	self.m_Persistent = bool
	return self
end

function ThrowObject:setDespawnTime(despawnTime)
	self.m_DespawnTime = despawnTime
	return self
end

function ThrowObject:replaceEntity(entity) 
	if entity and isElement(entity) then
		if self:getEntity() and isElement(self:getEntity()) then 
			self:getEntity():destroy() 
		end
		self.m_Entity = entity 
		self:getEntity():attach(self:getDummyEntity())
		if entity:getType() == "player" then 
			entity:setPosition(self:getDummyEntity():getPosition())
			entity:setCollisionsEnabled(false)
		end
	end
	return self
end

function ThrowObject:setDamageDisabled(bool)
	self.m_DamageDisabled = bool
	return self
end

function ThrowObject:setThrowCallback(callback)
	if callback and type(callback) == "function" then
		self.m_ThrowCallback = callback
	end
	return self
end

function ThrowObject:setSkillBased(bool)
	self.m_SkillBased = bool
end

function ThrowObject:getTypeFromModel(model) 
	local skin = isValidPedModel(model)
	local vehicle = getVehicleNameFromModel (model)
	local object = not skin and not vehicle 
	local type = (skin and "ped") or (vehicle and "vehicle") or (object and "object")
	return type
end

function ThrowObject:getPlayer() return self.m_Player end
function ThrowObject:getModel() return self.m_Model end 
function ThrowObject:getPhysicsModel() return self.m_PhysicModel end
function ThrowObject:getEntity() return self.m_Entity end 
function ThrowObject:getDummyEntity() return self.m_DummyEntity end 
function ThrowObject:getOffset() return self.m_OffsetMatrix end
function ThrowObject:isActive() return isValidElement(self:getDummyEntity(), self:getType()) end 
function ThrowObject:getType() return self.m_Type end
function ThrowObject:isPersistent() return self.m_Persistent end 
function ThrowObject:getDespawnTime() return self.m_DespawnTime end
function ThrowObject:isPushed() return self.m_Pushed end
function ThrowObject:isDamageDisabled() return self.m_DamageDisabled end
function ThrowObject:isSkillBased() return self.m_SkillBased end
function ThrowObject:getThrowCallback() return self.m_ThrowCallback end