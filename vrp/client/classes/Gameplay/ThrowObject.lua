-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/ThrowObject.lua
-- *  PURPOSE:     Client ThrowObject Class
-- *
-- ****************************************************************************
ThrowObject = inherit(Singleton)

function ThrowObject:constructor() 
	addRemoteEvents{"Throw:prepareThrow", "Throw:updateCollision", "Throw:throwPlayer"}
	addEventHandler("Throw:prepareThrow", localPlayer, bind(self.prepareThrow, self))
	addEventHandler("Throw:updateCollision", localPlayer, bind(self.Event_updateCollision, self))
	addEventHandler("Throw:throwPlayer", localPlayer, bind(self.Event_onThrowPlayer, self))
	self.m_ThrowRenderBind = bind(self.renderThrowPreparation, self) 
	self.m_ThrowHandleBind = bind(self.handleThrowBind, self)
end

function ThrowObject:destructor() 

end

function ThrowObject:Event_updateCollision(object, bool, everyone)
	object:setCollidableWith(localPlayer, bool)
	if everyone then 
		for k, player in pairs(getElementsByType("player")) do 
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
	triggerServerEvent("Throw:executeThrow", localPlayer, x, y, z, force)
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

function ThrowObject:prepareThrow(state)
	if state == true then
		bindKey("fire", "both", self.m_ThrowHandleBind)
	else
		unbindKey("fire", "both", self.m_ThrowHandleBind)
		if isEventHandlerAdded("onClientRender", root, self.m_ThrowRenderBind) then
			removeEventHandler("onClientRender", root, self.m_ThrowRenderBind)
		end
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