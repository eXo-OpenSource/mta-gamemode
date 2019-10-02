-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Minigames/InjurySystem/DamageManager.lua
-- *  PURPOSE:     DamageManager
-- *
-- ****************************************************************************

DamageManager = inherit(Singleton)

addRemoteEvents{"Damage:getPlayerDamage", "Damage:onTryTreat", "Damage:onCancelTreat", "Damage:onDeclineTreat", "Damage:onTreat"}
function DamageManager:constructor() 
	self.m_Data = {}
	self.m_Players = {}
	self.m_IdCount = 0
	self.m_TreatQueue = {}
	addEventHandler("Damage:getPlayerDamage", root, bind(self.Event_GetPlayerDamage, self))
	addEventHandler("Damage:onTryTreat", root, bind(self.Event_requestTreat, self))
	addEventHandler("Damage:onTreat", root, bind(self.Event_TreatPlayer, self))
	addEventHandler("Damage:onCancelTreat", root, bind(self.Event_OnCancelTreat, self))
	addEventHandler("Damage:onDeclineTreat", root, bind(self.Event_OnDeclineTreat, self))
end

function DamageManager:Event_GetPlayerDamage(player)
	local send ={}
	if self.m_Players[player] then 
		for id, instance in pairs(self.m_Players[player]) do 
			send[id] = {instance:getBodypart(), instance:getWeapon(), instance:getAmount()}
		end
	end
	client:triggerEvent("Damage:sendPlayerDamage", send, player, self:getHealerType(player, client))
end

function DamageManager:Event_requestTreat(player, data)
	if player ~= client then
		ShortMessageQuestion:new(client, player, ("Der Spieler %s möchte deine Wunden behandeln!"):format(client:getName()), "Damage:onTreat", "Damage:onDeclineTreat", nil, client, player, data)
		client:sendInfo(_("Deine Anfrage wurde an den Spieler gesendet!", client))
	else
		if table.size(data) > 0 then 
			self:Event_TreatPlayer(client, player, data)
		else
			client:sendError(_("Wähle eine oder mehrere Wunden zur Behandlung aus!", client))
		end
	end
end

function DamageManager:Event_OnDeclineTreat(healer) 
	healer:sendInfo("Der Spieler hat eine Behandlung abgelehnt!")
end


function DamageManager:Event_TreatPlayer(healer, player, data)
	local client = healer
	if not healer then return end 
	if not player then return end
	if player.m_TreatedBy then
		if isElement(player.m_TreatedBy) then 
			return client:sendInfo(_("Dieser Spieler wird bereits behandelt!", client))
		end
	end
	if player.m_Treating then 
		if isElement(player.m_Treating) then 
			return client:sendInfo(_("Dieser Spieler behandelt zurzeit jemanden!", client))
		end
	end
	if not self:validate(player, client) then return end
	self:cancelQueue(player, player.m_TreatedBy,  true)
	local firstTimer = false
	local sumTimeCount = 0
	player.m_TreatedBy = client
	local playerAnimation = TREAT_ANIMATION_PATIENT[self:getHealerType(player, client)]
	player:setFrozen(true)
	player:setAnimation(playerAnimation[1], playerAnimation[2], -1, true, false, false, false, 250, true)
	setPedAnimationSpeed(player, playerAnimation[2], playerAnimation[3])
	toggleAllControls(player, false)
	setElementData(player, "Damage:isTreating", true)
	client.m_Treating = player

	if client ~= player then
		toggleAllControls(client, false)
		client:setFrozen(true)
		local healerAnimation = TREAT_ANIMATION_HEALER[self:getHealerType(player, client)]
		client:setAnimation(healerAnimation[1], healerAnimation[2], -1, true, false, false, false, 250, true)
		setPedAnimationSpeed(client, healerAnimation[2], healerAnimation[3])
		setElementData(client, "Damage:isTreating", true)
	end
	local healerType = self:getHealerType(player, client)
	for i, item in ipairs(data) do 
		local instances = self:getInjuryByTextBody(player, item.bodypart, item.text)
		local count = table.size(instances)
		local timeCount = 0
		local first = false
		if instances ~= {} then 
			for id, inst in pairs(instances) do 
				if not first then
					local partTime = TIME_FOR_TREAT_BODYPART[inst:getBodypart()] or 1 
					local damageTime = TIME_FOR_TREAT_DAMAGE[INJURY_WEAPON_TO_CAUSE[inst:getWeapon()] or 30] or 1 
					timeCount = (partTime*(damageTime*count))
					sumTimeCount = sumTimeCount + (timeCount * TIME_FOR_HEALERS[healerType]) 
					first = true
				end
			end
			
			sumTimeCount = sumTimeCount
			if not self.m_TreatQueue[player] then self.m_TreatQueue[player] = {} end

			local timer = setTimer(bind(self.treat, self, instances, client), sumTimeCount*1000, 1) 
			table.insert(self.m_TreatQueue[player],  {timer, sumTimeCount})
			if not firstTimer then 
				client:triggerEvent("Damage:startTreatment", sumTimeCount, true)
				if client ~= player then
					player:triggerEvent("Damage:startTreatment", sumTimeCount)
				end
				firstTimer = true
			end
		end
	end
end

function DamageManager:Event_OnCancelTreat(isHealer) 
	if isHealer and client.m_Treating and isElement(client.m_Treating) then 
		self:cancelQueue(client.m_Treating, client)
	elseif not isHealer then 
		self:cancelQueue(client, client.m_TreatedBy)
	end
	if not isHealer then
		local healer = client.m_TreatedBy
		if healer and isElement(healer) then
			healer:triggerEvent("Damage:cancelTreatment")
			toggleAllControls(healer, true)
			healer:setFrozen(false)
			healer:setAnimation(nil)
			setElementData(healer, "Damage:isTreating", false)
			healer.m_Treating = nil
		end
		client.m_TreatedBy = nil
		if client ~= healer then
			toggleAllControls(client, true)
			client:setFrozen(false)
			client:setAnimation(nil)
			setElementData(client, "Damage:isTreating", false)
			client:triggerEvent("Damage:cancelTreatment")
		end
	else 
		local patient = client.m_Treating
		client:triggerEvent("Damage:cancelTreatment")
		client.m_Treating = nil

		patient.m_TreatedBy = nil
		if patient ~= client then
			patient:triggerEvent("Damage:cancelTreatment")
			patient:setFrozen(false)
			patient:setAnimation(nil)
			toggleAllControls(patient, true)
			setElementData(patient, "Damage:isTreating", false)
		end
	end

end
function DamageManager:validate(player, healer)
	if player:isLoggedIn() and healer:isLoggedIn() then 
		if Vector3(player:getPosition() - healer:getPosition()):getLength() < 6 and (player:getInterior() == healer:getInterior() and player:getDimension() == healer:getDimension()) then 
			return true
		else 
			return false
		end
	end
end

function DamageManager:cancelQueue(player, healer, noOutput)
	if self.m_TreatQueue[player] then 
		for i, data in ipairs(self.m_TreatQueue[player]) do 
			if data[1] and isTimer(data[1]) then 
				killTimer(data[1])
			end
		end
		if healer ~= player and not noOutput then
			player:sendInfo(_("Deine Behandlung wurde abgebrochen!", player))
		end
		if healer and isElement(healer)  then 
			if not noOutput then
				healer:sendInfo(_("Die Behandlung wurde abgebrochen!", healer))
			end
		end
		if healer and isElement(healer) then 
			healer:setFrozen(false)
			toggleAllControls(healer, true)
			healer:setAnimation(nil)
			setElementData(healer, "Damage:isTreating", false)
		end
		if player and isElement(player) then 
			player:setFrozen(false)
			toggleAllControls(player, true)
			player:setAnimation(nil)
			setElementData(player, "Damage:isTreating", false)
		end
		self.m_TreatQueue[player] = {}
	end
end

function DamageManager:treat(data, healer)
	local healSum = 0
	local player
	for id, instance in pairs(data) do 
		player = instance:getPlayer()
		healSum = healSum + instance:getAmount()
		self:removeDamage(instance:getId())
		instance:delete()
	end
	if not player then return end 
	if not self:validate(player, healer) then return self:cancelQueue(player, healer)  end
	local nextTimer = self:getNextTimer(player, sourceTimer)
	if healSum > 0 then 
		local health = player:getHealth() 
		local armor = player:getArmor()
		local giveHealth = health + healSum
		if health < 100 then
			if giveHealth <= 100 then 
				player:setHealth(health+healSum)
			else 
				player:setHealth(100)
				player:setArmor((healSum - (100-health)) + armor)
			end
		else 
			player:setArmor(armor + healSum)
		end
		StatisticsLogger:getSingleton():addHealLog(player, healSum, ("Wundbehandlung von %s"):format(healer:getName()))
	end
	if not nextTimer then 
		healer:triggerEvent("Damage:finishTreatment")
		healer:setFrozen(false)
		toggleAllControls(healer, true)
		healer:setAnimation(nil)
		setElementData(healer, "Damage:isTreating", false)
		if player ~= healer then 
			player:setFrozen(false)
			player:setAnimation(nil)
			setElementData(player, "Damage:isTreating", false)
			toggleAllControls(player, true)
			player:triggerEvent("Damage:finishTreatment")
		end
		healer.m_Treating = nil 
		player.m_TreatedBy = nil
	else
		local timeLeft = getTimerDetails(nextTimer[1])
		healer:triggerEvent("Damage:startTreatment", timeLeft/1000, true)
		if healer ~= player then
			player:triggerEvent("Damage:startTreatment", timeLeft/1000)
		end
	end
end


function DamageManager:getNextTimer(player, timer)
	if self.m_TreatQueue[player] then 
		for i = 1, #self.m_TreatQueue[player] do 
			if self.m_TreatQueue[player][i][1] == timer then 
				if self.m_TreatQueue[player][i+1] then 
					return self.m_TreatQueue[player][i+1]
				else 
					return nil
				end
			end
		end
	end
	return nil
end

function DamageManager:getInjuryByTextBody(player, bodypart, text)
	local damageInstances = {}
	if self.m_Players[player] then
		for id, instance in pairs(self.m_Players[player]) do 
			local instanceText = INJURY_WEAPON_TO_CAUSE[instance:getWeapon()]
			
			if instanceText == text and bodypart == instance:getBodypart() then 
				damageInstances[id] = instance
			end
		end
	end
	return damageInstances
end

function DamageManager:addDamage(bodypart, weapon, amount, player)
	if not player or (not isElement(player) or player:isDead()) then return end
	self.m_IdCount = self.m_IdCount + 1
	local instance = Damage:new(self.m_IdCount, bodypart, weapon, amount, player)
	if not self.m_Players[player] then self.m_Players[player] = {} end
	self.m_Players[player][self.m_IdCount] = instance
	self.m_Data[self.m_IdCount] = instance
end

function DamageManager:getDamageByWeapon(player, weapon)
	if not self.m_Players[player] then return 0 end
	local count = 0
	local maxDamage = 0
	local maxInstance
	for id, inst in pairs(self.m_Players[player]) do 
		if inst:getWeapon() == weapon then 
			count = count + 1
			if maxDamage < inst:getAmount() then 
				maxInstance = inst
			end
		end
	end
	return count, maxInstance
end

function DamageManager:clearPlayer(player) 
	self.m_Players[player] = {}
end

function DamageManager:removeDamage(id)
	for dId, inst in pairs(self.m_Data) do 
		if dId == id then 
			local player = inst:getPlayer()
			self.m_Players[player][id] = nil
			self.m_Data[id] = nil
			inst:delete()
		end
	end
end

function DamageManager:loadPlayer(player, data)
	data = fromJSON(data or "") or {}
	for i, subdata in pairs(data) do
		local id, bodypart, weapon, amount = unpack(subdata)
		self:addDamage(bodypart, weapon, amount, player)
	end
end

function DamageManager:serializePlayer(player) 
	if self.m_Players[player] then
		local serialize = {}
		for id, inst in pairs(self.m_Players[player]) do 
			serialize[id] = {id, inst:getBodypart(), inst:getWeapon(), inst:getAmount()}
		end
		return toJSON(serialize)
	end
	return toJSON({})
end

function DamageManager:getHealerType(player, healer)
	if player == healer then 
		return "SELF_TREATMENT"
	else 
		if healer.getFaction and healer:getFaction() and healer:getFaction():isRescueFaction() then 
			return "RESCUE_PLAYER"
		elseif healer.m_IsTrainedInTreatment then --todo 
			return "TRAINED_NON_RESCUE"
		else 
			return "NON_RESCUE_PLAYER"
		end
	end
end

function DamageManager:destructor() 

end
