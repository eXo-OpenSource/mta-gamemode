-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Minigames/InjurySystem/DamageManager.lua
-- *  PURPOSE:     DamageManager
-- *
-- ****************************************************************************

DamageManager = inherit(Singleton)

addRemoteEvents{"Damage:getPlayerDamage", "Damage:onTryTreat"}
function DamageManager:constructor() 
	self.m_Data = {}
	self.m_Players = {}
	self.m_IdCount = 0
	self.m_TreatQueue = {}
	addEventHandler("Damage:getPlayerDamage", root, bind(self.Event_GetPlayerDamage, self))
	addEventHandler("Damage:onTryTreat", root, bind(self.Event_TreatPlayer, self))
end

function DamageManager:Event_GetPlayerDamage(player)
	local send ={}
	if self.m_Players[player] then 
		for id, instance in pairs(self.m_Players[player]) do 
			send[id] = {instance:getBodypart(), instance:getWeapon(), instance:getAmount()}
		end
	end
	client:triggerEvent("Damage:sendPlayerDamage", send, player)
end

function DamageManager:Event_TreatPlayer(player, data)
	self:cancelQueue(player)
	if not self:validate(player, client) then return end
	local sumTimeCount = 0
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
					sumTimeCount = sumTimeCount + timeCount 
					first = true
					outputChatBox(timeCount)
				end
			end
			if not self.m_TreatQueue[player] then self.m_TreatQueue[player] = {} end
			local timer = setTimer(bind(self.treat, self, instances, client), sumTimeCount*1000, 1) 
			self.m_TreatQueue[player][timer] = true
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

function DamageManager:cancelQueue(player)
	if self.m_TreatQueue[player] then 
		for timer, k in pairs(self.m_TreatQueue[player]) do 
			if timer and isTimer(timer) then 
				killTimer(timer)
			end
		end
		player:sendInfo(_("Deine Behandlung wurde abgebrochen!", player))
	end
end

function DamageManager:treat(data, healer)
	local healSum = 0
	local player
	for id, instance in pairs(data) do 
		player = instance:getPlayer()
		healSum = healSum + instance:getAmount()
	end
	if healSum > 0 then 
		local health = player:getHealth() 
		if health < 100 then 
			player:setHealth(health+healSum)
			StatisticsLogger:getSingleton():addHealLog(player, healSum, ("Wundbehandlung von %s"):format(healer:getName()))
		end
	end
end

function DamageManager:getInjuryByTextBody(player, bodypart, text)
	local damageInstances = {}
	if self.m_Players[player] then
		for id, instance in pairs(self.m_Players[player]) do 
			local instanceText = INJURY_WEAPON_TO_CAUSE[instance:getWeapon()]
			
			if instanceText == text and bodypart == instance:getBodypart() then 
				outputChatBox(bodypart..";"..text)
				damageInstances[id] = instance
			end
		end
	end
	return damageInstances
end

function DamageManager:addDamage(bodypart, weapon, amount, player)
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

function DamageManager:destructor() 

end