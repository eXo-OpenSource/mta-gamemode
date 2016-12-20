-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemAlcohol.lua
-- *  PURPOSE:     Alcohol Item Super class
-- *
-- ****************************************************************************
ItemAlcohol = inherit(Item)

ItemAlcohol.Settings = {
	["Bier"] = {["Health"] = 0, ["Model"] = 1486, ["Text"] = "trinkt ein Bier", ["Animation"] = {"BAR", "dnk_stndM_loop", 4500}, ["Alcohol"] = 0.25},
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
		exports.bone_attach:attachElementToBone(item, player, 12, 0, 0, 0, 0, -90, 0)
	end

	player:meChat(true, " "..ItemSettings["Text"].."!")
	if ItemSettings["Health"] > 0 then
		StatisticsLogger:getSingleton():addHealLog(client, ItemSettings["Health"], "Item "..self:getName())
	end
	player:incrementAlcoholLevel(ItemSettings["Alcohol"])

	if ItemSettings["CustomEvent"] then
		triggerClientEvent(ItemSettings["CustomEvent"], player, item)
	end

	local block, animation, time = unpack(ItemSettings["Animation"])
	player:setAnimation(block, animation, time, true, false, false)
	setTimer(function()
		item:destroy()
		if ItemSettings["Health"] > 0 then
			player:setHealth(player:getHealth()+ItemSettings["Health"])
		end
		player:setAnimation()
	end, time, 1)

end
