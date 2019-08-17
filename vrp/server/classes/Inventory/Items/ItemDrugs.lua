-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemDrugs.lua
-- *  PURPOSE:     Drugs Super class
-- *
-- ****************************************************************************
ItemDrugs = inherit(ItemNew)

ItemDrugs.Settings = {
	["weed"] = {
		["Text"] = "raucht Weed",
		["Model"] = 3027,
		["Animation"] = {"smoking", "M_smkstnd_loop", 13500},
		["AnimationProgress"] = 0.4,
		["AnimationDuration"] = 2000,
		["ModelScale"] = Vector3(2, 2, 3),
		["Attach"] = {11, 0, -0.02, 0.15, 0, -90, 90},
		["CustomEvent"] = "smokeEffect"
	},
	["shrooms"] = {
		["Text"] = "isst einen Magic Mushroom",
		["Model"] = 1882,
		["Animation"] = {"FOOD", "EAT_Burger", 2000}
	},
	["heroin"] = {
		["Text"] = "spritzt sich Heroin",
		["Model"] = 0,
		["Animation"] = {"FOOD", "EAT_Burger", 2000}
	},
	["cocaine"] = {
		["Text"] = "schnupft Kokain",
		["Model"] = 0,
		["Animation"] = {"FOOD", "EAT_Burger", 2000}
	}
}

function ItemDrugs:constructor()

end

function ItemDrugs:destructor()

end

function ItemDrugs:use()
	local player = self.m_Inventory:getPlayer()

	if not player then return false end
	if player.isTasered then return false end
	if player.m_IsConsuming then player:sendError(_("Du konsumierst bereits etwas!", player)) return false end
	if player:isInGangwar() and player:getArmor() == 0 then player:sendError(_("Du hast keine Schutzweste mehr!", player)) return false end
	if JobBoxer:getSingleton():isPlayerBoxing(player) == true then player:sendError(_("Du darfst dich während des Boxkampfes nicht heilen!", player)) return false end
	if math.round(math.abs(player.velocity.z*100)) ~= 0 and not player.vehicle then player:sendError(_("Du kannst in der Luft nichts essen!", player)) return false end

	local itemSettings = ItemDrugs.Settings[self:getTechnicalName()]

	player:meChat(true, itemSettings["Text"].."!")
	StatisticsLogger:getSingleton():addDrugUse(player, self:getTechnicalName())

	local block, animation, time = unpack(itemSettings["Animation"])

	player.m_IsConsuming = true
	if not player.vehicle then
		player:setAnimation(block, animation, time, true, false, false)
		if itemSettings["AnimationProgress"] then
			setTimer(function()
				setPedAnimationProgress(player, animation, itemSettings["AnimationProgress"])
			end, 10, 1)
		end

		if itemSettings["Model"] and itemSettings["Model"] ~= 0 then
			item = createObject(itemSettings["Model"], 0, 0, 0)
			item:setDimension(player:getDimension())
			item:setInterior(player:getInterior())
			if itemSettings["ModelScale"] then item:setScale(itemSettings["ModelScale"]) end
			if itemSettings["Attach"] then
				exports.bone_attach:attachElementToBone(item, player, unpack(itemSettings["Attach"]))
			else
				exports.bone_attach:attachElementToBone(item, player, 12, 0, 0, 0, 0, -90, 0)
			end
		end
	end

	if itemSettings["CustomEvent"] then
		triggerClientEvent(itemSettings["CustomEvent"], player, item)
	end

	if itemSettings["AnimationDuration"] then
		time = itemSettings["AnimationDuration"]
	end

	setTimer(
		function()
			if isElement(item) then item:destroy() end
			if not isElement(player) or getElementType(player) ~= "player" then return false end
			player.m_IsConsuming = false
			player:setAnimation()
			DrugManager:getSingleton():use(player, self:getTechnicalName())
		end, time, 1
	)

	player:giveAchievement(73)

	return true, true
end
