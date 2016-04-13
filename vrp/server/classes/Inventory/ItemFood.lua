-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemFood.lua
-- *  PURPOSE:     Food Item Super class
-- *
-- ****************************************************************************
ItemFood = inherit(Item)

ItemFood.Settings = {
	["Burger"] = {["Health"] = 80, ["Model"] = 2880, ["Text"] = "einen Burger", ["Animation"] = {"FOOD", "EAT_Burger", 4500}},
	["Pizza"] = {["Health"] = 80, ["Model"] = 2881, ["Text"] = "ein Stück Pizza", ["Animation"] = {"FOOD", "EAT_Pizza", 4500}}
}

function ItemFood:constructor()

end

function ItemFood:destructor()

end

function ItemFood:use(player)
	local ItemSettings = ItemFood.Settings[self:getName()]

	local item = createObject(ItemSettings["Model"], 0, 0, 0)
	exports.bone_attach:attachElementToBone(item, player, 12, 0, 0, 0, 0, -90, 0)

	player:meChat(true, "isst "..ItemSettings["Text"].."!")

	local block, animation, time = unpack(ItemSettings["Animation"])
	player:setAnimation(block, animation, time, false, false, false)
	setTimer(function()
		item:destroy()
		player:setHealth(player:getHealth()+ItemSettings["Health"])
	end, time, 1)
end
