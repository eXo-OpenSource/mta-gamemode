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
	self.m_PlayerId = player:getId()
	self.m_Model = model 
	self.m_Type = self:getTypeFromModel(self:getModel())
	self.m_PhysicModel = dummy or ThrowObject.DummyType[self.m_Type]
	self.m_OffsetMatrix = self:assertTransformMatrix(offsetMatrix)
	if self:initialise() then 
		self:attach()
	end
	player:setThrowingObject(self)
	bindKey(player, "aim_weapon", "both", ThrowObjectManager:getSingleton():getBind())
	ThrowObjectManager:getSingleton():addThrowObjectToPlayer(self:getPlayerId(), self)
end

function ThrowObject:destructor()
	self:syncRemoval()

	if isValidElement(self:getDummyEntity(), "object") then self:getDummyEntity():destroy() end
	if self:getEntity() and isElement(self:getEntity()) and self:getEntity():getType() ~= "player" then 
		self:getEntity():destroy() 
	end
	ThrowObjectManager:getSingleton():removeThrowObjectFromPlayer(self:getPlayerId(), self)
	self.Deleted = true
end

function ThrowObject:updateCollision(bool, everyone)
	if isValidElement(self:getPlayer(), "player") then
		self:getPlayer():triggerEvent("Throw:updateCollision", self:getDummyEntity(), bool)
	end
	if everyone then 
		for key, player in pairs(PlayerManager:getSingleton():getReadyPlayers()) do 
			if isValidElement(player, "player") and player ~= self:getPlayer() then
				player:triggerEvent("Throw:updateCollision", self:getDummyEntity(), bool, true)
			end
		end
	end
	return self
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
	setTimer(function() 
		if isValidElement(self:getDummyEntity(), "object") then
			self:getDummyEntity():setAngularVelocity(Vector3(0, 0, 0)) -- stop the movement after one second | todo use calculations to determine a better time
		end 
	end, 1000, 1)
	if isValidElement(self:getEntity(), "player") then 
		setTimer(function()
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
	self:syncCreation() -- we only need to sync on push since we do not need any collision detection whilst the object is in the hand of the throwing player
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
	self.m_DummyEntity:setData("Throw:responsiblePlayer", self:getPlayer(), true)
	self.m_DummyEntity.m_ThrowInstance = self
	self:setDamage(3)
	
	return isValidElement(self.m_Entity, self:getType()) and isValidElement(self.m_Entity, self:getType())
end

function ThrowObject:syncCreation() 
	if not isValidElement(self:getPlayer(), "player") then return end
	for index, player in ipairs(PlayerManager:getSingleton():getReadyPlayers()) do
		if isValidElement(player, "player") then
			player:triggerEvent("Throw:syncObject", self:getPlayer(), self:getEntity(), self:getDummyEntity(), self:getCustomBoundingBox())
		end
	end
end

function ThrowObject:syncRemoval() 
	for index, player in ipairs(PlayerManager:getSingleton():getReadyPlayers()) do
		if isValidElement(player, "player") then
			player:triggerEvent("Throw:deleteObject", self:getDummyEntity())
		end
	end
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
	self:getDummyEntity():setData("Throw:entityDamageDisabled", bool, true)
	return self
end

function ThrowObject:setThrowCallback(callback)
	if callback and type(callback) == "function" then
		self.m_ThrowCallback = callback
	end
	return self
end


function ThrowObject:setContactCallback(callback)
	if callback and type(callback) == "function" then
		self.m_ContactCallback = callback
	end
	return self
end

function ThrowObject:setDamageCallback(callback)
	if callback and type(callback) == "function" then
		self.m_DamageCallback = callback
	end
	return self
end

function ThrowObject:setSkillBased(bool)
	self.m_SkillBased = bool
	return self
end

function ThrowObject:setDamage(damage) 
	self.m_Damage = damage or 3
	return self
end

function ThrowObject:setEntityOffsetMatrix(offset) -- necessary when the dummy entity is not fitting right onto the visible entity (ie. collision is not in place correctly)
	self:getEntity():attach(self:getDummyEntity(), 
		offset.position.x, 
		offset.position.y, 
		offset.position.z, 
		offset.rotation.x, 
		offset.rotation.y, 
		offset.rotation.z)
	return self
end

function ThrowObject:setScale(scale) 
	if self:getEntity() then 
		self:getEntity():setScale(scale or Vector3(1, 1, 1))
	end
	return self
end

function ThrowObject:setCustomBoundingBox(bound) -- set bounding box size / used for client detection of collision
	self.m_CustomBound = bound 
	return self
end

function ThrowObject:getTypeFromModel(model) 
	local skin = isValidPedModel(model)
	local vehicle = getVehicleNameFromModel (model)
	local object = not skin and not vehicle 
	local type = (skin and "ped") or (vehicle and "vehicle") or (object and "object")
	return type
end

function ThrowObject:getPlayer() return self.m_Player end
function ThrowObject:getPlayerId() return self.m_PlayerId end
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
function ThrowObject:getDamage() return self.m_Damage end
function ThrowObject:getThrowCallback() return self.m_ThrowCallback end
function ThrowObject:getContactCallback() return self.m_ContactCallback end 
function ThrowObject:getDamageCallback() return self.m_DamageCallback end 
function ThrowObject:getCustomBoundingBox() return self.m_CustomBound end 