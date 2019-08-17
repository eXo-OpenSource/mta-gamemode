-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/DrugManager.lua
-- *  PURPOSE:     DrugManager
-- *
-- ****************************************************************************
DrugManager = inherit(Singleton)

DrugManager.Settings = {
	weed = {
		effectInterval = 5000,
		effectCount = 12, -- (60 * 1000) / 5000 - expireTime / effectInterval
		healValue = 5,
		expireTime = 60 * 1000
	},
	shrooms = {
		expireTime = 60 * 1000
	},
	heroin = {
		expireTime = 50 * 1000
	},
	cocaine = {
		expireTime = 60 * 1000
	}
}

function DrugManager:constructor()
	self.m_EffectFunc = bind(self.effect, self)
	self.m_ExpireFunc = bind(self.expire, self)
end

function DrugManager:use(player, drug)
	player:triggerEvent("onClientDrugEffect", drug, DrugManager.Settings[drug].expireTime)

	if not player.m_DrugExpireTimers then
		player.m_DrugExpireTimers = {}
	end

	if player.m_DrugExpireTimers[drug] and isTimer(player.m_DrugExpireTimers[drug]) then
		killTimer(player.m_DrugExpireTimers[drug])
	end

	if player.m_DrugOverdose then
		player.m_DrugOverdose = player.m_DrugOverdose + 1
	else
		player.m_DrugOverdose = 1
	end

	player.m_DrugExpireTimers[drug] = setTimer(self.m_EffectFunc, DrugManager.Settings[drug].expireTime, 1, player, drug)

	if DrugManager.Settings[drug].effectInterval then
		setTimer(self.m_EffectFunc, DrugManager.Settings[drug].effectInterval, DrugManager.Settings[drug].effectCount, player, drug)
	end
end

function DrugManager:effect(player, drug)
	if not isElement(player) or getElementType(player) ~= "player" then return false end

	if drug == "weed" then
		local health = getElementHealth(player)

		if health < 100 then
			setElementHealth(player, health + DrugManager.Settings[drug].healValue)
		end
	end
end

function DrugManager:expire(player, drug)
	if not isElement(player) or getElementType(player) ~= "player" then return false end

	if player.m_DrugOverDose then
		player.m_DrugOverDose = player.m_DrugOverDose - 1
	end

	player:triggerEvent("onClientItemExpire", drug)
end
