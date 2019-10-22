-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemAlcohol.lua
-- *  PURPOSE:     Alcohol Item Super class
-- *
-- ****************************************************************************
ItemAlcohol = inherit(Item)

ItemAlcohol.Settings = {
	["Bier"] =
		{	["Health"] = 0, ["Model"] = 1486, ["Text"] = "trinkt ein Bier", ["Animation"] = {"BAR", "dnk_stndM_loop", 4500}, ["Alcohol"] = 0.25,
			["Attach"] = {12, -0.05, 0.05, 0.09, 0, -90, 0},
		},
	["Whiskey"] =			{["Health"] = 0, ["Model"] = 1455, ["Text"] = "trinkt einen Whiskey", ["Animation"] = {"BAR", "dnk_stndM_loop", 4500}, ["Alcohol"] = 1.2},
	["Sex on the Beach"] =	{["Health"] = 0, ["Model"] = 1455, ["Text"] = "trinkt einen Sex on the Beach", ["Animation"] = {"BAR", "dnk_stndM_loop", 4500}, ["Alcohol"] = 0.5,},
	["Whiskey"] =		{["Health"] = 0, ["Model"] = 1455, ["Text"] = "trinkt einen Whiskey", ["Animation"] = {"BAR", "dnk_stndM_loop", 4500}, ["Alcohol"] = 1.2},
	["Pina Colada"] =	{["Health"] = 0, ["Model"] = 1455, ["Text"] = "trinkt einen Pina Colada", ["Animation"] = {"BAR", "dnk_stndM_loop", 4500}, ["Alcohol"] = 0.7},
	["Monster"] =		{["Health"] = 0, ["Model"] = 1455, ["Text"] = "trinkt einen Monster Cocktail", ["Animation"] = {"BAR", "dnk_stndM_loop", 4500}, ["Alcohol"] = 2.1},
	["Shot"] =			{["Health"] = 0, ["Model"] = 1455, ["Text"] = "trinkt einen Shot", ["Animation"] = {"BAR", "dnk_stndM_loop", 4500}, ["Alcohol"] = 1.4},
	["Cuba-Libre"] =	{["Health"] = 0, ["Model"] = 1455, ["Text"] = "trinkt einen Cuba Libre", ["Animation"] = {"BAR", "dnk_stndM_loop", 4500}, ["Alcohol"] = 0.8},
	["Gluehwein"] =		{["Health"] = 0, ["Model"] = 1455, ["Text"] = "trinkt einen Glühwein", ["Animation"] = {"BAR", "dnk_stndM_loop", 4500}, ["Alcohol"] = 0.4},
}

function ItemAlcohol:constructor()

end

function ItemAlcohol:destructor()

end

function ItemAlcohol:use(player)
	local ItemSettings = ItemAlcohol.Settings[self:getName()]

	local item = createObject(ItemSettings["Model"], 0, 0, 0)
	item:setDimension(player:getDimension())
	item:setInterior(player:getInterior())

	if ItemSettings["ModelScale"] then item:setScale(ItemSettings["ModelScale"]) end
	if ItemSettings["Attach"] then
		exports.bone_attach:attachElementToBone(item, player, unpack(ItemSettings["Attach"]))
	else
		exports.bone_attach:attachElementToBone(item, player, 12, 0, 0.05, 0.1, 0, -90, 0)
	end

	player:meChat(true, " "..ItemSettings["Text"].."!")
	if ItemSettings["Health"] > 0 then
		StatisticsLogger:getSingleton():addHealLog(client, ItemSettings["Health"], "Item "..self:getName())
		client:checkLastDamaged() 
	end
	player:incrementAlcoholLevel(ItemSettings["Alcohol"])

	if ItemSettings["CustomEvent"] then
		triggerClientEvent(ItemSettings["CustomEvent"], player, item)
	end

	local block, animation, time = unpack(ItemSettings["Animation"])
	player:setAnimation(block, animation, time, true, false, false)
	setTimer(function()
		item:destroy()
		if self:getName() == "Bier" then
			player:getInventory():giveItem("Flasche", 1)
			player:sendInfo(_("Du hast eine leere Flasche erhalten!", player))
		end
		if ItemSettings["Health"] > 0 then
			player:setHealth(player:getHealth()+ItemSettings["Health"])
		end
		player:setAnimation()
	end, time, 1)

end
