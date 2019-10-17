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
	if isValidElement(self:getEntity(), self:getType()) and self:getType() ~= "ped" then 
		self:getEntity():destroy() 
	end
	ThrowObjectManager:getSingleton():removeThrowObjectFromPlayer(self:getPlayer(), self)
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
	self:getDummyEntity():setVelocity(pushVector)
	self:getDummyEntity():setAngularVelocity(Vector3(.1, 0, 0)) 
	self:setDespawnTime(getTickCount()+ThrowObjectManager.DESPAWN_TIME)
	if not self:isPersistent() then 
		ThrowObjectManager:getSingleton():addToDespawnList(self)
	end
	self.m_Pushed = true
end

function ThrowObject:initialise() 
	self.m_Entity = ThrowObject.TypeLexicon[self:getType()](self:getModel(), self:getPlayer():getPosition())
	self.m_Entity:setDimension(self:getPlayer():getDimension())
	self.m_Entity:setInterior(self:getPlayer():getInterior()) 
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
end

function ThrowObject:setDespawnTime(despawnTime)
	self.m_DespawnTime = despawnTime
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