-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/ThrowObjectManager.lua
-- *  PURPOSE:     Server ThrowObjectManager Class
-- *
-- ****************************************************************************
ThrowObjectManager = inherit(Singleton)
ThrowObjectManager.DESPAWN_TIME = 20000
ThrowObjectManager.PULSE_TIME = 5000 -- time in ms to pulse for a despawn
function ThrowObjectManager:constructor() 
	addRemoteEvents{"Throw:disableThrowLeave", "Throw:executeThrow", "Throw:playerWasThrown", "Throw:reportDamage"}
	addEventHandler("Throw:disableThrowLeave", root, bind(self.Event_onDisableThrowLeave, self))
	addEventHandler("Throw:executeThrow", root, bind(self.Event_onExecuteThrow, self))
	addEventHandler("Throw:playerWasThrown", root, bind(self.Event_onPlayerIsThrown, self)) -- This is only called when a player throws another player and the thrown player has been thrown
	addEventHandler("Throw:reportDamage", root, bind(self.Event_onPlayerDamage, self))
	self.m_ThrowBind = bind(self.Bind_onThrowKey, self)
	self.m_ThrowContactBind = bind(self.Event_onContactWithThrowable, self) -- detecting colshape hits
	self.m_ThrownObjects = {}
	self.m_SortedDespawnObjects = {} -- a list sorted by the despawn time to provide more efficient cleanup by minimizing indexing

	setTimer(bind(self.pulse, self), ThrowObjectManager.PULSE_TIME, 0)

	PlayerManager:getSingleton():getQuitHook():register(bind(self.Event_onPlayerQuit, self))
end

function ThrowObjectManager:destructor() 

end

function ThrowObjectManager:pulse() -- check in a given interval for despawns 
	local now = getTickCount()
	local removeIndexes = {} -- pack them into this table to remove them afterwards in order to avoid any access-violation
	for index, instance in ipairs(self.m_SortedDespawnObjects) do 
		if  now > instance:getDespawnTime() then 
			removeIndexes[index] = instance
		else 
			break
		end
	end
	for index, instance in pairs(removeIndexes) do 
		table.remove(self.m_SortedDespawnObjects, index)
		instance:delete()
	end
end

function ThrowObjectManager:getSkillFactor(player) 
	local thrownCount = player:getStatistics("ThrownObject") or 0
	local skill = (-3.04518*(10^-19) * thrownCount^2) + (0.004*thrownCount) + 0.38
	if skill > 1.5 then skill = 1.5 end 
	return skill
end

function ThrowObjectManager:addToDespawnList(instance)
	local inserted
	for index, data in ipairs(self.m_SortedDespawnObjects) do 
		if data:getDespawnTime() > instance:getDespawnTime() then
			table.insert(self.m_SortedDespawnObjects, index, instance)
			inserted = true
		end
	end
	if not inserted then 
		table.insert(self.m_SortedDespawnObjects, instance)
	end
end

function ThrowObjectManager:addThrowObjectToPlayer(player, instance)
	if not self.m_ThrownObjects[player] then self.m_ThrownObjects[player] = {} end 
	if not self:hasPlayerInstance(player, instance) then 
		table.insert(self.m_ThrownObjects[player], instance) -- we need ipairs to be able to cut off from bottom
	end
end

function ThrowObjectManager:removeThrowObjectFromPlayer(player, instance) 
	local index = self:hasPlayerInstance(player, instance) 
	if index then 
		table.remove(self.m_ThrownObjects[player], index)
	end 
end

function ThrowObjectManager:hasPlayerInstance(player, searchInstance)
	for index, instance in ipairs(self.m_ThrownObjects[player]) do 
		if instance == searchInstance then 
			return index
		end
	end
	return false
end

function ThrowObjectManager:getPlayerThrowCount(player)
	return (self.m_ThrownObjects[player] and #self.m_ThrownObjects[player]) or 0
end

function ThrowObjectManager:Bind_onThrowKey(player, key, keystate, dontCancelAnimation) 
	if not player:getThrowingObject() then return end
	if keystate == "down" then
		player:getThrowingObject():updateCollision(false)
		setPedWeaponSlot(player, 0)
		if not player.isTasered then
			local x, y, z = getElementVelocity(player)
			if z == 0 then
				self:lockControl(player)
				setPedAnimation(player, "GRENADE", "WEAPON_throw", -1, false, false, false, false)
				player.m_Thrown = false
				player.m_isInThrowAnim = true
				nextframe(
					function()
						setPedAnimationSpeed(player, "WEAPON_throw", 0.0)
						setPedAnimationProgress(player, "WEAPON_throw", 0.15)
						player:triggerEvent("startCenteredBonecam", 2, false, 25)
					end
				)
				player:triggerEvent("Throw:prepareThrow", true)
			end
		end
	elseif keystate == "up" then
		if not player.m_Thrown then
			if player.m_isInThrowAnim then
				player.m_isInThrowAnim = false 
				nextframe(function() player:triggerEvent("stopCenteredBonecam") end)
				player:triggerEvent("Throw:prepareThrow", false)
				if not player.isTasered then
					self:unlockControl(player)
					if not dontCancelAnimation then
						setPedAnimation(player)
					end
				end
			end
		end
	end
end

function ThrowObjectManager:Event_onContactWithThrowable(element, dimension)
	if true then 
		outputChatBox(tostring(element))
	end
end

function ThrowObjectManager:Event_onPlayerDamage(target, object, bodypart)
	if object.m_ThrowInstance and object.m_ThrowInstance:isPushed() then
		local loss = object.m_ThrowInstance:getDamage() or 3 
		Guns:getSingleton():damagePlayer(target, loss, client, 56, bodypart)
		target:triggerEvent("clientBloodScreen")
	end
end

function ThrowObjectManager:Event_onExecuteThrow(velx, vely, velz, force) 
	if client:getThrowingObject() then
		if not client.m_LastGrenadeThrow then
			client.m_LastGrenadeThrow = 0
		end
		if client.m_Thrown then
			if getTickCount() - client.m_LastGrenadeThrow > 1000 then
				client.m_LastGrenadeThrow = getTickCount()
				setPedAnimationSpeed(client, "WEAPON_throw", 1)
				client:getThrowingObject():push(Vector3(velx*force, vely*force, velz*force))
				setTimer(function(player) 
					player.m_Thrown = false 
					if not player:getThrowingObject():isDamageDisabled() then
						player:getThrowingObject():updateCollision(true)
					end
					self:Bind_onThrowKey(player, false, "up", true) 
					player:setThrowingObject(nil)
				end, 400, 1, client)
			end
		end
	end
end

function ThrowObjectManager:Event_onPlayerIsThrown() 
	client:setData("throwEntity", nil)
	if client.m_ThrowInstance then 
		client.m_ThrowInstance:delete()
		client:setCollisionsEnabled(true)
	end
end


function ThrowObjectManager:Event_onPlayerQuit() 
	if source:getThrowingObject() then 
		if not source:getThrowingObject():isPushed() then -- if it is pushed let the despawn-manager handle it 
			source:getThrowingObject():delete()
		end
	end
end

function ThrowObjectManager:lockControl(player) 
	toggleControl(player, "next_weapon", false)
	toggleControl(player, "previous_weapon", false)
	toggleControl(player, "forwards", false)
	toggleControl(player, "backwards", false)
	toggleControl(player, "left", false)
	toggleControl(player, "right", false)
	toggleControl(player, "sprint", false)
	toggleControl(player, "fire", false)
end

function ThrowObjectManager:unlockControl(player) 
	toggleControl(player, "next_weapon", true)
	toggleControl(player, "previous_weapon", true)
	toggleControl(player, "forwards", true)
	toggleControl(player, "backwards", true)
	toggleControl(player, "left", true)
	toggleControl(player, "right", true)
	toggleControl(player, "sprint", true)
	toggleControl(player, "fire", true)
end

function ThrowObjectManager:Event_onDisableThrowLeave()
	client.m_Thrown = true
end

function ThrowObjectManager:getBind() return self.m_ThrowBind end
function ThrowObjectManager:getContactBind() return self.m_ThrowContactBind end