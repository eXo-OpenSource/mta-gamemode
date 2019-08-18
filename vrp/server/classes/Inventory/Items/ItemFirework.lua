-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemFirework.lua
-- *  PURPOSE:     Firework items Class
-- *
-- ****************************************************************************
ItemFirework = inherit(ItemNew)

ItemFirework.Cooldown = { -- in Seconds
	["fireworksRomanBattery"] = 20,
	["fireworksBattery"] = 20,
	["fireworksRocket"] = 1,
	["fireworksRoman"] = 5,
	["fireworksPipeBomb"] = 5,
	["fireworksBomb"] = 5,
}

function ItemFirework:use()
	local player = self.m_Inventory:getPlayer()

	if not player then return false end

	if not FIREWORK_ENABLED then
		player:sendError("Das Feuerwerk ist zurzeit deaktiviert!")
		return false
	end

	if player.isTasered then player:sendError(_("Du bist gerade getasert!", player)) return false end
	if player.m_IsConsuming then player:sendError(_("Du konsumierst gerade etwas!", player)) return false end
	if player:isInGangwar() then player:sendError(_("Du bist im Gangwar!", player)) return false end
	if player:getInterior() ~= 0 or player:getDimension() ~= 0 then
		player:sendError("Du kannst kein Feuerwerk in einem Interior zünden!")
		return false
	end

	if player.vehicle then
		player:sendError("Du kannst kein Feuerwerk in einem Fahrzeug zünden!")
		return false
	end

	local cooldown = ItemFirework.Cooldown[self:getTechnicalName()]

	if ItemFirework.Cooldown[self:getTechnicalName()] then
		if not player.m_FireworkCooldown then player.m_FireworkCooldown = {} end
		if player.m_FireworkCooldown[self:getTechnicalName()] then
			if not timestampCoolDown(player.m_FireworkCooldown[self:getTechnicalName()], ItemFirework.Cooldown[self:getTechnicalName()]) then
				player:sendError(_("Du kannst die %s nicht so knapp hintereinander nutzen!", player, self:getName()))
				return
			end
		end
		player.m_FireworkCooldown[self:getTechnicalName()] = getRealTime().timestamp
	end

	local rnd = 0

	if self:getTechnicalName() == "fireworksBattery" then
		rnd = math.random(5, 8)
	elseif self:getTechnicalName() == "fireworksRoman" then
		rnd = math.random(10, 15)
	elseif self:getTechnicalName() == "fireworksRomanBattery" then
		rnd = math.random(7, 12)
	end

	player:meChat(true, _("zündet eine/n %s!", player, self:getName()))

	triggerClientEvent(root, "onClientFireworkStart", player, self:getTechnicalName(), serialiseVector(player:getPosition()), rnd)
	return true, true
end
