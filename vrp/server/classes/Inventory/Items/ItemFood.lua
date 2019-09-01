-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemFood.lua
-- *  PURPOSE:     Food Item Super class
-- *
-- ****************************************************************************
ItemFood = inherit(ItemNew)

ItemFood.Settings = {
	["burger"] = {["Health"] = 80, ["Model"] = 2880, ["Text"] = "isst einen Burger", ["Animation"] = {"FOOD", "EAT_Burger", 4500}},
	["pizza"] = {["Health"] = 80, ["Model"] = 2881, ["Text"] = "isst ein Stück Pizza", ["Animation"] = {"FOOD", "EAT_Pizza", 4500}},
	["mushroom"] = {["Health"] = 10, ["Model"] = 1882, ["ModelScale"] = 0.7, ["Text"] = "isst einen Pilz", ["Animation"] = {"FOOD", "EAT_Burger", 4500}, ["Attach"] = {12, 0, 0.05, 0.05, 0, -90, 0}},
	["cigarette"] = {["Health"] = 10, ["Model"] = 3027, ["Text"] = "raucht eine Zigarette", ["Animation"] = {"smoking", "M_smkstnd_loop", 13500}, ["ModelScale"] = 2, ["Attach"] = {11, 0, -0.02, 0.15, 0, -90, 90}, ["CustomEvent"] = "smokeEffect"},
	["donut"] = {["Health"] = 25, ["Model"] = 1915, ["ModelScale"] = 1.2, ["Text"] = "isst einen Donut", ["Animation"] = {"FOOD", "EAT_BURGER", 4500}, ["Attach"] = {12, 0, 0.05, 0.15, 0, -90, 90}},
	["cookie"] = {["Health"] = 100, ["Model"] = 1915, ["ModelScale"] = 0, ["Text"] = "isst einen Keks", ["Animation"] = {"FOOD", "EAT_BURGER", 4500}},
	["apple"] = {["Health"] = 80, ["Model"] = 1915, ["ModelScale"] = 0, ["Text"] = "isst einen Apfel", ["Animation"] = {"FOOD", "EAT_BURGER", 4500}},
	["zombieBurger"] = {["Health"] = 80, ["Model"] = 2880, ["Text"] = "isst einen Zombie-Burger", ["Animation"] = {"FOOD", "EAT_Burger", 4500, ["CustomEvent"] = "bloodFx"}},
	["cowUdderWithFries"] = {["Health"] = 80, ["Model"] = 0, ["Text"] = "isst Kuheuter mit Pommes", ["Animation"] = {"FOOD", "EAT_Burger", 4500}, ["CustomEvent"] = "bloodFx"},
	["candies"] = {["Health"] = 15, ["Model"] = 0, ["Text"] = "nascht leckere Süßigkeiten", ["Animation"] = {"FOOD", "EAT_Burger", 4500}},
	["candyCane"] = {["Health"] = 15, ["Model"] = 0, ["Text"] = "nascht eine Zuckerstange", ["Animation"] = {"FOOD", "EAT_Burger", 4500}},
	["sousage"] = {["Health"] = 80, ["Model"] = 0, ["Text"] = "isst heiße Würstchen vom Grill", ["Animation"] = {"FOOD", "EAT_Burger", 4500}},
	["gingerbread"] = {["Health"] = 40, ["Model"] = 0, ["Text"] = "isst Lebkuchen", ["Animation"] = {"FOOD", "EAT_Burger", 4500}},
	["bait"] = {["Health"] = 2, ["Model"] = 0, ["Text"] = "isst einen Wurm", ["Animation"] = {"FOOD", "EAT_Burger", 4500}},
}

function ItemFood:use()
	local player = self.m_Inventory:getPlayer()

	if not player then return false end
	if player.isTasered then return false end
	if player.m_IsConsuming then player:sendError(_("Du konsumierst bereits etwas!", player)) return false end
	if player:isInGangwar() and player:getArmor() == 0 then player:sendError(_("Du hast keine Schutzweste mehr!", player)) return false end
	if JobBoxer:getSingleton():isPlayerBoxing(player) == true then player:sendError(_("Du darfst dich während des Boxkampfes nicht heilen!", player)) return false end
	if math.round(math.abs(player.velocity.z*100)) ~= 0 and not player.vehicle then player:sendError(_("Du kannst in der Luft nichts essen!", player)) return false end

	local itemSettings = ItemFood.Settings[self:getTechnicalName()]

	player:meChat(true, string.format("%s!", itemSettings["Text"]))
	StatisticsLogger:getSingleton():addHealLog(player, itemSettings["Health"], string.format("Item %s", self:getTechnicalName()))

	player.m_IsConsuming = true
	local block, animation, time = unpack(itemSettings["Animation"])
	local item = nil
	if not player.vehicle then
		player:setAnimation(block, animation, time, true, false, false)

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

	setTimer(
		function()
			if isElement(item) then item:destroy() end
			if not isElement(player) or getElementType(player) ~= "player" then return false end
			player:setHealth(player:getHealth() + itemSettings["Health"])
			player.m_IsConsuming = false
			player:setAnimation()
		end, time, 1
	)

	return true, true
end
