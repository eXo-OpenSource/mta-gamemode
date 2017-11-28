-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemFood.lua
-- *  PURPOSE:     Food Item Super class
-- *
-- ****************************************************************************
ItemFood = inherit(Item)

ItemFood.Settings = {
	["Burger"] = {["Health"] = 80, ["Model"] = 2880, ["Text"] = "isst einen Burger", ["Animation"] = {"FOOD", "EAT_Burger", 4500}},
	["Pizza"] = {["Health"] = 80, ["Model"] = 2881, ["Text"] = "isst ein Stück Pizza", ["Animation"] = {"FOOD", "EAT_Pizza", 4500}},
	["Pilz"] = {["Health"] = 10, ["Model"] = 1882, ["ModelScale"] = 0.7, ["Text"] = "isst einen Pilz", ["Animation"] = {"FOOD", "EAT_Burger", 4500}, ["Attach"] = {12, 0, 0.05, 0.05, 0, -90, 0}},
	["Zigarette"] = {["Health"] = 10, ["Model"] = 3027, ["Text"] = "raucht eine Zigarette", ["Animation"] = {"smoking", "M_smkstnd_loop", 13500},
		["ModelScale"] = 2,
		["Attach"] = {11, 0, -0.02, 0.15, 0, -90, 90},
		["CustomEvent"] = "smokeEffect"
	},
	["Donut"] = {["Health"] = 25, ["Model"] = 1915, ["ModelScale"] = 1.2, ["Text"] = "isst einen Donut", ["Animation"] = {"FOOD", "EAT_BURGER", 4500}, ["Attach"] = {12, 0, 0.05, 0.15, 0, -90, 90}},
	["Keks"] = {["Health"] = 100, ["Model"] = 1915, ["ModelScale"] = 0, ["Text"] = "isst einen Keks", ["Animation"] = {"FOOD", "EAT_BURGER", 4500}},
	["Apfel"] = {["Health"] = 80, ["Model"] = 1915, ["ModelScale"] = 0, ["Text"] = "isst einen Apfel", ["Animation"] = {"FOOD", "EAT_BURGER", 4500}},
	["Zombie-Burger"] = {["Health"] = 80, ["Model"] = 2880, ["Text"] = "isst einen Zombie-Burger", ["Animation"] = {"FOOD", "EAT_Burger", 4500,
		["CustomEvent"] = "bloodFx"}},
	["Kuheuter mit Pommes"] = {["Health"] = 80, ["Model"] = 2880, ["Text"] = "isst Kuheuter mit Pommes", ["Animation"] = {"FOOD", "EAT_Burger", 4500},
		["CustomEvent"] = "bloodFx"},
	["Suessigkeiten"] = {["Health"] = 15, ["Model"] = 2880, ["Text"] = "nascht leckere Süßigkeiten", ["Animation"] = {"FOOD", "EAT_Burger", 4500}},
	["Zuckerstange"] = {["Health"] = 15, ["Model"] = 2880, ["Text"] = "nascht eine Zuckerstange", ["Animation"] = {"FOOD", "EAT_Burger", 4500}},

}

function ItemFood:constructor()

end

function ItemFood:destructor()

end

function ItemFood:use(player)
	if player.isTasered then return false end

	local ItemSettings = ItemFood.Settings[self:getName()]
	local block, animation, time = unpack(ItemSettings["Animation"])

	player:meChat(true, ""..ItemSettings["Text"].."!")
	StatisticsLogger:getSingleton():addHealLog(client, ItemSettings["Health"], "Item "..self:getName())

	if ItemSettings["CustomEvent"] then
		triggerClientEvent(ItemSettings["CustomEvent"], player, item)
	end

	local block, animation, time = unpack(ItemSettings["Animation"])
	if not player.vehicle then player:setAnimation(block, animation, time, true, false, false) end
	setTimer(function()
		if isElement(item) then item:destroy() end
		if not isElement(player) or getElementType(player) ~= "player" then return false end
		player:setHealth(player:getHealth()+ItemSettings["Health"])
		player:setAnimation()
	end, time, 1)
end
