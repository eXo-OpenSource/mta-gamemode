-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/ThrowObject.lua
-- *  PURPOSE:     Client ThrowObject Class
-- *
-- ****************************************************************************
ThrowObject = inherit(Singleton)
ThrowObject.THRESHOLD_HIT = 500
function ThrowObject:constructor() 
	addRemoteEvents{"Throw:prepareThrow", "Throw:updateCollision", "Throw:throwPlayer", "Throw:syncObject", "Throw:deleteObject"}
	addEventHandler("Throw:syncObject", localPlayer, bind(self.Event_onSyncObject, self))
	addEventHandler("Throw:deleteObject", localPlayer, bind(self.Event_onDeleteObject, self))
	addEventHandler("Throw:prepareThrow", localPlayer, bind(self.Event_onPrepareThrow, self))
	addEventHandler("Throw:updateCollision", localPlayer, bind(self.Event_updateCollision, self))
	addEventHandler("Throw:throwPlayer", localPlayer, bind(self.Event_onThrowPlayer, self))
	self.m_ThrowRenderBind = bind(self.renderThrowPreparation, self) 
	self.m_ThrowHandleBind = bind(self.handleThrowBind, self)

	self.m_ThrowFrameBind = bind(self.update, self)
	self.m_Synced = {}
	self.m_SyncedByLocal = {}
	self.m_DebugCol = {}
end

function ThrowObject:destructor() 

end

function ThrowObject:Event_updateCollision(object, bool, everyone)
	object:setCollidableWith(localPlayer, bool)
	if everyone then 
		for k, player in pairs(getElementsByType("player", root, true)) do 
			object:setCollidableWith(player, bool)
		end
	end
end

function ThrowObject:renderThrowPreparation() 
	localPlayer.m_ThrowProgress = localPlayer.m_ThrowProgress - 0.001
	setPedAnimationProgress(localPlayer, "WEAPON_throw", localPlayer.m_ThrowProgress)
	localPlayer.m_ThrowForce = localPlayer.m_ThrowForce + 0.02

	if localPlayer.m_ThrowProgress < 0.12 then 
		removeEventHandler("onClientRender", root, self.m_ThrowRenderBind) 
	end
end

function ThrowObject:throw(force)
	local bx, by, bz = getPedBonePosition(localPlayer, 25) 
	local x, y, z, x2, y2, z2 = getCameraMatrix()
	local x, y, z = normalize(x2-x, y2-y, z2-z)
	local block, anim = localPlayer:getAnimation()
	if force and anim == "WEAPON_throw"  then
		localPlayer.m_ThrowForce = nil
		triggerServerEvent("Throw:executeThrow", localPlayer, x, y, z, force)
	end
end

function ThrowObject:handleThrowBind(key, keystate)
	if keystate == "down" then
		localPlayer.m_ThrowProgress = 0.15
		localPlayer.m_ThrowForce = 0.2
		triggerServerEvent("Throw:disableThrowLeave", localPlayer)
		if not isEventHandlerAdded("onClientRender", root, self.m_ThrowRenderBind) then
			addEventHandler("onClientRender", root, self.m_ThrowRenderBind)
		end
	elseif keystate == "up" then
		if isEventHandlerAdded("onClientRender", root, self.m_ThrowRenderBind) then
			removeEventHandler("onClientRender", root, self.m_ThrowRenderBind)
		end
		self:throw(localPlayer.m_ThrowForce)
	end
end

function ThrowObject:attachBounding(object, responsible, bounding)
	local radius = object:getRadius()
	if radius then 
		object.m_Responsible = responsible
		object.m_MarkedPlayers = {}
		object.m_DebugColor = tocolor(math.random(0, 255), math.random(0, 255), math.random(0, 255))
		object.m_CustomBound = bounding
		object.m_BoundVector = {self:getBoundingBox(object)}
		object.m_PlayerBound = {self:getBoundingBox(localPlayer)}
		return true
	end
	return false
end

function ThrowObject:adjustRenderEvent() 
	if isEventHandlerAdded("onClientPreRender", root, self.m_ThrowFrameBind) then 
		if table.size(self.m_SyncedByLocal) == 0 then 
			removeEventHandler("onClientPreRender", root, self.m_ThrowFrameBind) 
			if DEBUG then 
				for k, col in pairs(self.m_DebugCol) do 
					col:destroy()
				end
				self.m_DebugCol = {}
			end
		end
	else 
		if table.size(self.m_SyncedByLocal) > 0 then 
			addEventHandler("onClientPreRender", root, self.m_ThrowFrameBind)
		end
	end
end

function ThrowObject:update()
	if DEBUG then 
		for k, col in pairs(self.m_DebugCol) do 
			col:destroy()
		end
		self.m_DebugCol = {}
	end
	local streamedPlayers = getElementsByType("player", root, true)
	for k, player in pairs(streamedPlayers) do 
		if player ~= localPlayer then 
			for entity, object in pairs(self.m_SyncedByLocal) do 
				if entity.m_BoundVector and entity:getVelocity():getLength() > 0 then 
					local centerOfBase = player:getDistanceFromCentreOfMassToBaseOfModel()
					local min, max = entity.m_BoundVector[1], entity.m_BoundVector[2]
  					local minVector = entity:getMatrix():transformPosition(Vector3(min.x, min.y, min.z))
					local maxVector = entity:getMatrix():transformPosition(Vector3(max.x, max.y, max.z))
					local boxPoints = {}
					boxPoints[1] = entity:getMatrix():transformPosition(min.x, min.y, max.z)
					boxPoints[2] = entity:getMatrix():transformPosition(max.x, min.y, max.z)
					boxPoints[3] = entity:getMatrix():transformPosition(min.x, max.y, max.z)
					boxPoints[4] = entity:getMatrix():transformPosition(max.x, max.y, max.z)				
					boxPoints[5] = entity:getMatrix():transformPosition(min.x, min.y, min.z)
					boxPoints[6] = entity:getMatrix():transformPosition(max.x, min.y, min.z)
					boxPoints[7] = entity:getMatrix():transformPosition(min.x, max.y, min.z)
					boxPoints[8] = entity:getMatrix():transformPosition(max.x, max.y, min.z)
					if DEBUG then
						if not self.m_DebugCol[player] then
							self.m_DebugCol[player] = ColShape.Tube(Vector3(player:getPosition() + (player:getMatrix():getUp()*-centerOfBase)), player:getRadius()*.4, (not player:isDucked() and centerOfBase*2) or centerOfBase)
						end
						self:drawBounding(entity.m_DebugColor, unpack(boxPoints))						
					end
					for index, point in pairs(boxPoints) do 
						if self:pointInSphere(point, Vector3(player:getPosition() + (player:getMatrix():getUp()*-centerOfBase)), player:getRadius()*.4) or
							(not player:isDucked() and self:pointInSphere(point, Vector3(player:getPosition() + (player:getMatrix():getUp()*centerOfBase)), player:getRadius()*.4)) or
							self:pointInSphere(point, player:getPosition(), player:getRadius()*.4) then
							self:drawTextOnWorldPosition("X", point, tocolor(math.random(0, 255), math.random(0, 255), math.random(0, 255)))
							if not entity.m_MarkedPlayers[player] then
								entity.m_MarkedPlayers[player] = true
								triggerServerEvent("Throw:reportContact", localPlayer, player, entity)
							end
						end
					end
				end
			end
		end
	end
end

function ThrowObject:drawTextOnWorldPosition(text, vecPosition, color)
    local x, y = getScreenFromWorldPosition(vecPosition)
    if x and y then
        dxDrawText(text, x, y, nil, nil, color or 0xFFFFFFFF, 2, "default-bold", "center", "center")
    end
end

function ThrowObject:pointInSphere(point, sphere, radius) -- point in sphere collision detection
  	local distance = math.sqrt((point.x - sphere.x) * (point.x - sphere.x) +
        (point.y - sphere.y) * (point.y - sphere.y) +
    	(point.z - sphere.z) * (point.z - sphere.z))
  		return distance < radius;
end 

function ThrowObject:drawBounding(color, a, b, c, d, e, f, g , h) 
	dxDrawLine3D(c, d, color)
	dxDrawLine3D(a, b, color)
	dxDrawLine3D(c, a, color)
	dxDrawLine3D(d, b, color)

	dxDrawLine3D(g, h, color)
	dxDrawLine3D(e, f, color)
	dxDrawLine3D(g, e, color)
	dxDrawLine3D(h, f, color)

	dxDrawLine3D(a, e, color)
	dxDrawLine3D(b, f, color)
	dxDrawLine3D(c, g, color)
	dxDrawLine3D(d, h, color)
end

function ThrowObject:getBoundingBox(element) -- just convert the 6 return values into two vectors min & max
	local minX, minY, minZ, maxX, maxY, maxZ = element:getBoundingBox()
	if element.m_CustomBound then
		minX, maxX = minX * element.m_CustomBound.x, maxX * element.m_CustomBound.x 
		minY, minY = minY * element.m_CustomBound.y, maxY * element.m_CustomBound.y
		minZ, maxZ = minZ * element.m_CustomBound.z, maxZ * element.m_CustomBound.z
	end
    return Vector3(minX, minY, minZ), Vector3(maxX, maxY, maxZ) 
end

function ThrowObject:getPlayerBounds(player) 
    local minX, minY, minZ, maxX, maxY, maxZ = player:getBoundingBox()
    local minVector = player:getMatrix():transformPosition(Vector3(minX, minY, minZ))
   	local maxVector = player:getMatrix():transformPosition(Vector3(maxX, maxY, maxZ))
	return minVector, maxVector
end

function ThrowObject:Event_onHitBoundingBox(element)
	if isValidElement(source.m_Entity, "object") then
		if element == localPlayer then
			if source.m_Responsible and isValidElement(source.m_Responsible, "player") then
				if element:getDimension() == source.m_Responsible:getDimension() and element:getInterior() == source.m_Responsible:getInterior() then 
					if not source.m_AlreadyTriggered and source.m_LastHit + ThrowObject.THRESHOLD_HIT < getTickCount() then 
						source.m_LastHit = getTickCount()
						source.m_MarkedPlayers[element] = true
						if source.m_Entity:getVelocity():getLength() > 0 then
							triggerServerEvent("Throw:reportContact", localPlayer, element, source.m_Entity)
						end
					end
				end
			end
		end
	else 
		self:removeGarbage(source.m_Entity)
	end
end

function ThrowObject:Event_onPrepareThrow(state)
	if state == true then
		bindKey("fire", "both", self.m_ThrowHandleBind)
	else
		unbindKey("fire", "both", self.m_ThrowHandleBind)
		if isEventHandlerAdded("onClientRender", root, self.m_ThrowRenderBind) then
			removeEventHandler("onClientRender", root, self.m_ThrowRenderBind)
		end
	end
end

function ThrowObject:removeGarbage(element) 
	if isValidElement(element.m_BoundingBox, "colshape") then 	
		element.m_BoundingBox:destroy()
		self.m_Synced[element] = nil
	end
end

function ThrowObject:Event_onThrowPlayer(entityDummy) 
	if entityDummy:getData("Throw:dummyEntity") and localPlayer:getData("Throw:throwEntity") then
		localPlayer:detach(entityDummy)
		localPlayer:setPosition(entityDummy:getPosition())
		localPlayer:setRotation(entityDummy:getRotation())
		localPlayer:setVelocity(entityDummy:getVelocity())
		triggerServerEvent("Throw:playerWasThrown", localPlayer)
	end
end

function ThrowObject:Event_onSyncObject(player, entity, entityDummy, bounding) 
	if isValidElement(entityDummy, "object") then 
		if not self.m_Synced[entityDummy] then 
			self.m_Synced[entityDummy] = entity
			if self:attachBounding(entityDummy, player, bounding) then 
				if player == localPlayer then
					self.m_SyncedByLocal[entityDummy] = entity
					self:adjustRenderEvent()
				end
			end
		end
	end
end

function ThrowObject:Event_onDeleteObject(entityDummy) 
	if self.m_Synced[entityDummy] then 
		if isValidElement(entityDummy.m_BoundingBox, "colshape") then 
			entityDummy.m_BoundingBox:destroy()
		end
		self.m_Synced[entityDummy] = nil
		self.m_SyncedByLocal[entityDummy] = nil
		self:adjustRenderEvent()
	end
end